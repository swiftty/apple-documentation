import SwiftUI
import AppleDocumentation
import NukeUI
import SupportMacros
import UIComponent

extension EnvironmentValues {
    @Entry
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
    enum Content: Hashable {
        case paragraph(ParagraphItem)
        case unorderedList([[ListItem]])
        case aside(name: String?, style: String, contents: [Content])
        case image([ImageVariant])

        struct ParagraphItem: Hashable {
            var texts: [AttributedText]
            var options = Options()

            struct Options: Hashable {
                var headingLevel: Int?
            }
        }

        struct ListItem: Hashable {
            var block: BlockContent
            var attributes: AttributedText.Attributes
        }

        struct ImageVariant: Hashable {
            var url: URL
            var traits: Set<Trait>

            enum Trait: Hashable {
                case dark, light
            }

            func isMatching(scheme: ColorScheme) -> Bool {
                return scheme == .dark && traits.contains(.dark)
                    || scheme == .light && traits.contains(.light)
            }
        }
    }

    let block: BlockContent
    let attributes: AttributedText.Attributes

    @Environment(\.references) var references

    var body: some View {
        ContentsRenderer(contents: contents)
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
                contents.append(.paragraph(.init(texts: cursor)))
                cursor = []
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
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
            builder.insert(.paragraph(
                .init(
                    texts: [.init(string: heading.text, attributes: attributes)],
                    options: .init(headingLevel: (1...3).contains(heading.level) ? heading.level : nil)
                )
            ))

        case .aside(let aside):
            var childBuilder = ContentBuilder()
            for block in aside.contents {
                buildContents(block, attributes: attributes, into: &childBuilder)
            }
            childBuilder.commit()
            builder.insert(.aside(name: aside.name, style: aside.style, contents: childBuilder.contents))

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

            builder.insert(.paragraph(.init(texts: [.init(string: unknown.type, attributes: attributes)])))
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
            guard let ref = references[image.identifier] else { return }

            builder.insert(.image(ref.variants.map {
                .init(url: $0.url, traits: Set($0.traits.compactMap { trait in
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
    let contents: [InnerView.Content]

    var body: some View {
        ForEach(contents, id: \.self) { content in
            switch content {
            case .paragraph(let paragraph):
                Text { next in
                    for text in paragraph.texts {
                        next(text)
                    }
                }
                .headingLevel(paragraph.options.headingLevel)

            case .unorderedList(let items):
                VStack(alignment: .leading) {
                    ForEach(items, id: \.self) { items in
                        HStack(alignment: .firstTextBaseline) {
                            Text("•")
                            VStack(alignment: .leading) {
                                ForEach(items, id: \.self) { item in
                                    InnerView(block: item.block, attributes: item.attributes)
                                }
                            }
                        }
                    }
                }

            case .aside(let name, let style, let contents):
                asideView(name: name, style: style, contents: contents)

            case .image(let variants):
                HStack {
                    ImageView(variants: variants)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }

    private func asideView(name: String?, style: String, contents: [InnerView.Content]) -> some View {
        // swiftlint:disable:next large_tuple
        func parameters() -> (name: String?, fill: AnyShapeStyle, border: AnyShapeStyle) {
            switch style {
            case "important":
                return (
                    name ?? "Important",
                    AnyShapeStyle(.yellow.opacity(0.2)),
                    AnyShapeStyle(.yellow)
                )
            default:
                return (
                    name,
                    AnyShapeStyle(.tertiary.opacity(0.3)),
                    AnyShapeStyle(.quaternary)
                )
            }
        }

        let style = parameters()

        return VStack(alignment: .leading) {
            if let name = style.name {
                Text(name)
                    .foregroundStyle(.primary)
                    .font(.body.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            ContentsRenderer(contents: contents)
        }
        .padding()
        .tint(.primary)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(style.fill)
                .stroke(style.border)
        }
    }
}

private struct ImageView: View {
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme

    let variants: [InnerView.Content.ImageVariant]

    var body: some View {
        if let url = findURL() {
            LazyImage(url: url) { state in
                state.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: state.imageContainer.map { $0.image.size.width / displayScale })
            }
        } else {
            Color.clear
                .overlay {
                    Image(systemName: "exclamationmark.triangle")
                }
                .aspectRatio(CGSize(width: 3, height: 2), contentMode: .fit)
                .border(.yellow)
        }
    }

    private func findURL() -> URL? {
        for variant in variants where variant.isMatching(scheme: colorScheme) {
            return variant.url
        }
        return variants.first?.url
    }
}
