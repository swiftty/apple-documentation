import SwiftUI
import AppleDocumentation
import NukeUI
import SupportMacros
import UIComponent

extension EnvironmentValues {
    @SwiftUIEnvironment
    var references: [Technology.Identifier: TechnologyDetail.Reference] = [:]
}

struct BlockTextView: View {
    let block: BlockContent
    let attributes: AttributedText.Attributes

    init(_ block: BlockContent, attributes: AttributedText.Attributes = .init()) {
        self.block = block
        self.attributes = attributes
    }

    init(_ inlines: [InlineContent], attributes: AttributedText.Attributes = .init()) {
        self.init(.paragraph(.init(contents: inlines)), attributes: attributes)
    }

    var body: some View {
        InnerView(block: block, attributes: attributes)
    }
}

extension BlockTextView {
    private struct InnerView: View {
        private enum Content: Hashable {
            case paragraph([AttributedText])
            case unorderedList([[ListItem]])
            case image(URL)

            struct ListItem: Hashable {
                var block: BlockContent
                var attributes: AttributedText.Attributes
            }
        }

        let block: BlockContent
        let attributes: AttributedText.Attributes

        @Environment(\.references) var references

        var body: some View {
            ForEach(contents, id: \.self) { content in
                switch content {
                case .paragraph(let texts):
                    Text { next in
                        for text in texts {
                            next(text)
                        }
                    }

                case .unorderedList(let items):
                    ForEach(items, id: \.self) { items in
                        HStack(alignment: .firstTextBaseline) {
                            Text("•")
                            VStack {
                                ForEach(items, id: \.self) { item in
                                    InnerView(block: item.block, attributes: item.attributes)
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
            attributes: AttributedText.Attributes,
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
            attributes: AttributedText.Attributes,
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
                attributes.link(using: ref)

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
