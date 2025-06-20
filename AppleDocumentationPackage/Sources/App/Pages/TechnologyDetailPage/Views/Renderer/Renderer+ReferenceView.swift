import SwiftUI
import AppleDocumentation
import UIComponent

struct ReferenceView: View {
    let reference: TechnologyDetail.Reference
    var descriptionOnly = false

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func content() -> some View {
        switch reference.kind ?? "" {
        case "article":
            asArticle()

        case "symbol":
            asSymbol()

        default:
            Text("unsupported \(reference.kind ?? "")")
                .foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private func asArticle() -> some View {
        HStack(alignment: .firstTextBaseline) {
            reference.articleImage?
                .font(.body)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading) {
                Text { next in
                    var attrs = AttributedText.Attributes()
                    attrs.font = .body
                    attrs.link(using: reference)
                    next(.init(string: reference.title ?? "", attributes: attrs))
                }

                BlockTextView(reference.abstract)
            }
        }
    }

    private func asSymbol() -> some View {
        var attributes = AttributedText.Attributes()
        attributes.link(using: reference)

        return VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                if case let fragments = reference.fragments, !fragments.isEmpty, !descriptionOnly {
                    FragmentTextView(fragments: fragments, attributes: attributes) { kind, attributes in
                        if !Set([.identifier]).contains(kind) {
                            attributes.link = nil
                            attributes.foregroundColor = .secondary
                        }
                    }

                } else if let title = reference.title {
                    FragmentTextView(
                        fragments: [.init(text: title, kind: .identifier, identifier: nil)],
                        attributes: attributes
                    )
                }

                if reference.beta {
                    Text { next in
                        var attributes = attributes
                        attributes.foregroundColor = .green
                        attributes.font = .caption
                        attributes.link = nil
                        next(.init(string: "Beta", attributes: attributes))
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background {
                        Capsule()
                            .stroke()
                    }
                    .foregroundStyle(.green)
                    .offset(y: -2)
                }
            }

            if !reference.abstract.isEmpty, !descriptionOnly {
                BlockTextView(reference.abstract)
                    .padding(.leading, 28)
            }
        }
    }
}

private extension TechnologyDetail.Reference {
    var articleImage: Image? {
        switch role {
        case "article": Image(systemName: "doc.text")
        case "collectionGroup": Image(systemName: "list.bullet")
        case "sampleCode": Image(systemName: "curlybraces")
        default: nil
        }
    }
}

#Preview {
    VStack {
        ReferenceView(reference: .init(
            identifier: .init(rawValue: ""),
            title: "UIKit updates",
            url: "/documentation/updates/uikit",
            kind: "article",
            role: "article",
            abstract: [
                .text(.init(text: """
                Secure personal data, and respect user preferences for how data is used.
                """))
            ],
            fragments: [],
            navigatorTitle: [],
            variants: [],
            beta: false)
        )
        ReferenceView(reference: .init(
            identifier: .init(rawValue: ""),
            title: nil,
            url: "/documentation/updates/uikit",
            kind: "symbol",
            role: "collectionGroup",
            abstract: [
                .text(.init(text: """
                Secure personal data, and respect user preferences for how data is used.
                """))
            ],
            fragments: [
                .init(text: "Hello world", kind: .text, identifier: nil)
            ],
            navigatorTitle: [],
            variants: [],
            beta: true)
        )
    }
    .preferredColorScheme(.dark)
}
