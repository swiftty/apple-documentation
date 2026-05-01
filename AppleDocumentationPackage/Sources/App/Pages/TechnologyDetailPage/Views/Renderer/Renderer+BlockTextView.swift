import SwiftUI
import AppleDocumentation
import SupportMacros
import UIComponent

extension EnvironmentValues {
    @Entry
    var references: [Technology.Identifier: TechnologyDetail.Reference] = [:]
}

// MARK: -

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
        VStack(alignment: .leading) {
            InnerView(block: block, attributes: attributes)
        }
    }
}

extension View {
    @ViewBuilder
    func headingLevel(_ level: Int?) -> some View {
        switch level {
        case 1:
            self
                .padding(.top)
                .padding(.bottom)

        case 2, 3:
            self
                .padding(.top)
                .padding(.bottom, 4)

        default:
            self
        }
    }
}

// MARK: -

private struct InnerView: View {
    let block: BlockContent
    let attributes: AttributedText.Attributes

    @Environment(\.references) var references

    var body: some View {
        ContentsRenderer(contents: contents)
    }

    private var contents: [DocumentData] {
        var builder = DocumentDataBuilder()
        buildContents(block, attributes: attributes, into: &builder)
        builder.commit()
        return builder.contents
    }

    private struct DocumentDataBuilder {
        private(set) var contents: [DocumentData] = []
        private var cursor: [AttributedText] = []

        mutating func insert(_ content: DocumentData) {
            commit()
            contents.append(content)
        }

        mutating func insert(_ values: [AttributedText], content: DocumentData? = nil) {
            cursor.append(contentsOf: values)
            if let content {
                insert(content)
            }
        }

        mutating func commit() {
            if !cursor.isEmpty {
                contents.append(.paragraph(.init(texts: cursor)))
                cursor = []
            }
        }
    }

    private func buildContents(
        _ block: BlockContent,
        attributes: AttributedText.Attributes,
        into builder: inout DocumentDataBuilder
    ) {
        switch block {
        case .paragraph(let paragraph):
            for inline in paragraph.contents {
                buildContents(inline, attributes: attributes, into: &builder)
            }

        case .heading(let heading):
            var attributes = attributes
            attributes.bold = true
            attributes.font =
                switch heading.level {
                case 1: .title
                case 2: .title2
                case 3: .title3
                default: attributes.font
                }
            builder.insert(
                .paragraph(
                    .init(
                        texts: [.init(string: heading.text, attributes: attributes)],
                        options: .init(headingLevel: (1...3).contains(heading.level) ? heading.level : nil)
                    )
                ))

        case .aside(let aside):
            var childBuilder = DocumentDataBuilder()
            for block in aside.contents {
                buildContents(block, attributes: attributes, into: &childBuilder)
            }
            childBuilder.commit()
            builder.insert(.aside(name: aside.name, style: aside.style, contents: childBuilder.contents))

        case .orderedList(let unorderedList):
            let list = unorderedList.items.map { item in
                item.content.map {
                    DocumentData.ListItem(block: $0, attributes: attributes)
                }
            }
            builder.insert(.orderedList(list))

        case .unorderedList(let unorderedList):
            let list = unorderedList.items.map { item in
                item.content.map {
                    DocumentData.ListItem(block: $0, attributes: attributes)
                }
            }
            builder.insert(.unorderedList(list))

        case .codeListing(let codeListing):
            builder.insert(.codeListing(syntax: codeListing.syntax, code: codeListing.code))

        case .links(let links):
            let items = links.items.compactMap { references[$0] }
            builder.insert(.links(style: links.style, items: items))

        case .unknown(let unknown):
            var attributes = attributes
            attributes.bold = true
            attributes.foregroundColor = .red

            builder.insert(.paragraph(.init(texts: [.init(string: unknown.type, attributes: attributes)])))
        }
    }

    private func buildContents(
        _ inline: InlineContent,
        attributes: AttributedText.Attributes,
        into builder: inout DocumentDataBuilder
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
            guard let ref = references[image.identifier] else { return }

            builder.insert(
                .image(
                    ref.variants.map {
                        .init(
                            url: $0.url,
                            traits: Set(
                                $0.traits.compactMap { trait in
                                    switch trait {
                                    case .dark: .dark
                                    case .light: .light
                                    default: nil
                                    }
                                }))
                    }))

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

// MARK: -

private struct ContentsRenderer: View {
    let contents: [DocumentData]

    var body: some View {
        ForEach(contents, id: \.self) { content in
            switch content {
            case .paragraph(let paragraph):
                ParagraphView(paragraph: paragraph, headingLevel: paragraph.options.headingLevel)

            case .orderedList(let items):
                OrderedListView(items: items) { block, attrs in
                    InnerView(block: block, attributes: attrs)
                }

            case .unorderedList(let items):
                UnorderedListView(items: items) { block, attrs in
                    InnerView(block: block, attributes: attrs)
                }

            case .aside(let name, let style, let contents):
                AsideView(name: name, style: style) {
                    ContentsRenderer(contents: contents)
                }

            case .image(let variants):
                ImageView(variants: variants)
                    .frame(maxWidth: .infinity, alignment: .center)

            case .codeListing(_, let code):
                CodeListView(syntax: nil, code: code)

            case .links(let style, let items):
                LinksView(style: style, items: items)
            }
        }
    }
}
