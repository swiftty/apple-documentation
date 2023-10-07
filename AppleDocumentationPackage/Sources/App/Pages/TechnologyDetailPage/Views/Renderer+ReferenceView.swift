import SwiftUI
import AppleDocumentation
import UIComponent

struct ReferenceView: View {
    let reference: TechnologyDetail.Reference

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
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            reference.articleImage?
                .font(.body)
                .foregroundStyle(.secondary)

            VStack {
                Text { next in
                    var attrs = AttributedText.Attributes()
                    attrs.font = .body
                    attrs.link(using: reference)
                    next(.init(string: reference.title ?? "", attributes: attrs))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                BlockTextView(reference.abstract)
            }
        }
    }

    private func asSymbol() -> some View {
        var attributes = AttributedText.Attributes()
        attributes.link(using: reference)

        return VStack {
            FragmentTextView(fragments: reference.fragments, attributes: attributes)

            if !reference.abstract.isEmpty {
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
            variants: [])
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
            variants: [])
        )
    }
    .preferredColorScheme(.dark)
}
