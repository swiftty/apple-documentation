import SwiftUI
import AppleDocumentation
import NukeUI

struct TextView: View, Hashable {
    struct TextAttributes: Hashable {
        var font: Font = .body
        var bold: Bool = false
        var italic: Bool = false
        var foregroundColor: Color = .primary

        var link: URL?
    }

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
        InnerView(block: block, attributes: attributes)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
    }
}

extension TextView {
    private struct InnerView: View {
        private enum Content: Hashable {
            case paragraph([AttributedText])
            case unorderedList([[TextView]])
            case image(URL)
        }

        let block: BlockContent
        let attributes: TextAttributes

        @Environment(\.references) var references

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
                                    item
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
                        TextView($0, attributes: attributes)
                    }
                }
                builder.insert(.unorderedList(list))

            case .unknown(let unknown):
                break
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
                break

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
                attributes.link = ref.url.flatMap(URL.init(string:))
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
                break
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
            .foregroundStyle(attributes.foregroundColor)
    }
}
