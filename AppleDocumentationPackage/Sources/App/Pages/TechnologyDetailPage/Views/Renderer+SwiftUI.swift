import SwiftUI
import AppleDocumentation
import NukeUI
import SupportMacros

struct OpenDestinationAction {
    private let handler: (Technology.Destination.Value) -> Void

    init(perform handler: @escaping (Technology.Destination.Value) -> Void) {
        self.handler = handler
    }

    func callAsFunction(_ identifier: Technology.Destination.Value) {
        handler(identifier)
    }
}

extension EnvironmentValues {
    @SwiftUIEnvironment
    var references: [Technology.Identifier: TechnologyDetail.Reference] = [:]

    @SwiftUIEnvironment
    var openDestination: OpenDestinationAction = .init(perform: { _ in })
}

struct TextView: View {
    struct TextAttributes: Hashable {
        var font: Font = .body
        var bold: Bool = false
        var italic: Bool = false
        var monospaced: Bool = false
        var foregroundColor: Color = .primary

        var link: URL?
    }

    @Environment(\.openURL) var openURL

    let block: BlockContent
    let attributes: TextAttributes

    init(_ block: BlockContent, attributes: TextAttributes = .init()) {
        self.block = block
        self.attributes = attributes
    }

    init(_ inlines: [InlineContent], attributes: TextAttributes = .init()) {
        self.init(.paragraph(.init(contents: inlines)), attributes: attributes)
    }

    var body: some View {
        InnerView(block: block, attributes: attributes, openURL: openURL)
    }
}

extension TextView {
    private struct InnerView: View {
        private enum Content: Hashable {
            case paragraph([AttributedText])
            case unorderedList([[ListItem]])
            case image(URL)

            struct ListItem: Hashable {
                var block: BlockContent
                var attributes: TextAttributes
            }
        }

        let block: BlockContent
        let attributes: TextAttributes
        let openURL: OpenURLAction

        @Environment(\.references) var references
        @Environment(\.openDestination) var openDestination

        var body: some View {
            ForEach(contents, id: \.self) { content in
                switch content {
                case .paragraph(let texts):
                    texts.reduce(Text("")) { text, appending in
                        text + appending.render()
                    }

                case .unorderedList(let items):
                    ForEach(items, id: \.self) { items in
                        HStack(alignment: .firstTextBaseline) {
                            Text("•")
                            VStack {
                                ForEach(items, id: \.self) { item in
                                    InnerView(block: item.block, attributes: item.attributes, openURL: openURL)
                                }
                            }
                        }
                    }

                case .image(let url):
                    LazyImage(url: url) { state in
                        state.image?
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .environment(\.openURL, OpenURLAction { url in
                guard let identifier = decodeFromURL(url) else { return .discarded }
                if identifier.hasPrefix("/") {
                    openDestination(.init(rawValue: identifier))
                    return .handled
                }
                guard let url = URL(string: identifier) else { return .discarded }
                if url.scheme?.hasPrefix("http") ?? false {
                    openURL(url)
                    return .handled
                }

                openDestination(.init(rawValue: identifier))
                return .handled
            })
        }

        private var contents: [Content] {
            var builder = ContentBuilder()
            buildContents(block, attributes: attributes, into: &builder)
            builder.commit()
            return builder.contents
        }

        private struct ContentBuilder {
            private(set) var contents: [Content] = []
            private var cursor: [AttributedText] = []

            mutating func insert(_ content: Content) {
                commit()
                contents.append(content)
            }

            mutating func insert(_ values: [AttributedText], content: Content? = nil) {
                cursor.append(contentsOf: values)
                if let content {
                    insert(content)
                }
            }

            mutating func commit() {
                if !cursor.isEmpty {
                    contents.append(.paragraph(cursor))
                    cursor = []
                }
            }
        }

        private func buildContents(
            _ block: BlockContent,
            attributes: TextAttributes,
            into builder: inout ContentBuilder
        ) {
            switch block {
            case .paragraph(let paragraph):
                for inline in paragraph.contents {
                    buildContents(inline, attributes: attributes, into: &builder)
                }

            case .heading(let heading):
                var attributes = attributes
                attributes.bold = true
                attributes.font = switch heading.level {
                case 1: .title
                case 2: .title2
                case 3: .title3
                default: attributes.font
                }
                builder.insert(.paragraph([.init(string: heading.text, attributes: attributes)]))

            case .aside(let aside):
                break

            case .unorderedList(let unorderedList):
                let list = unorderedList.items.map { item in
                    item.content.map {
                        Content.ListItem(block: $0, attributes: attributes)
                    }
                }
                builder.insert(.unorderedList(list))

            case .unknown(let unknown):
                var attributes = attributes
                attributes.bold = true
                attributes.foregroundColor = .red

                builder.insert(.paragraph([.init(string: unknown.type, attributes: attributes)]))
            }
        }

        // swiftlint:disable:next cyclomatic_complexity
        private func buildContents(
            _ inline: InlineContent,
            attributes: TextAttributes,
            into builder: inout ContentBuilder
        ) {
            switch inline {
            case .text(let text):
                builder.insert([.init(string: text.text, attributes: attributes)])

            case .codeVoice(let codeVoice):
                var attributes = attributes
                attributes.monospaced = true
                builder.insert([.init(string: codeVoice.code, attributes: attributes)])

            case .strong(let strong):
                var attributes = attributes
                attributes.bold = true
                for inline in strong.contents {
                    buildContents(inline, attributes: attributes, into: &builder)
                }

            case .emphasis(let emphasis):
                var attributes = attributes
                attributes.italic = true
                for inline in emphasis.contents {
                    buildContents(inline, attributes: attributes, into: &builder)
                }

            case .reference(let reference):
                guard let ref = references[reference.identifier] else { return }
                var attributes = attributes
                attributes.link = encodeToURL(ref.url)
                if attributes.link == nil {
                    attributes.foregroundColor = .yellow
                }

                let title = ref.title ?? ref.fragments.map(\.text).joined()
                builder.insert([.init(string: title, attributes: attributes)])

            case .image(let image):
                guard let ref = references[image.identifier],
                      let url = ref.variants.last?.url else { return }
                builder.insert(.image(url))

            case .inlineHead(let inlineHead):
                var attributes = attributes
                attributes.bold = true
                attributes.font = .subheadline

                for inline in inlineHead.contents {
                    buildContents(inline, attributes: attributes, into: &builder)
                }

            case .unknown(let unknown):
                var attributes = attributes
                attributes.bold = true
                attributes.foregroundColor = .red

                builder.insert([.init(string: unknown.type, attributes: attributes)])
            }
        }
    }
}

private struct AttributedText: Hashable {
    var string: String
    var attributes: TextView.TextAttributes

    func render() -> Text {
        let text = if let link = attributes.link {
            Text(.init("[\(string)](\(link.absoluteString))"))
        } else {
            Text(verbatim: string)
        }

        return text
            .font(attributes.font)
            .bold(attributes.bold)
            .italic(attributes.italic)
            .monospaced(attributes.monospaced)
            .foregroundStyle(attributes.foregroundColor)
    }
}

private func encodeToURL(_ target: String?) -> URL? {
    guard let target else { return nil }

    var comps = URLComponents(string: "appledoc://")
    comps?.queryItems = [
        .init(name: "identifier", value: target)
    ]
    return comps?.url
}

private func decodeFromURL(_ url: URL) -> String? {
    let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
    return comps?.queryItems?.first(where: { $0.name == "identifier" })?.value
}
