import SwiftUI
import AppleDocumentation
import UIComponent

enum DocumentData: Hashable {
    case paragraph(ParagraphItem)
    case orderedList([[ListItem]])
    case unorderedList([[ListItem]])
    case aside(name: String?, style: String, contents: [DocumentData])
    case image([ImageVariant])
    case codeListing(syntax: String?, code: [String])
    case links(style: String, items: [TechnologyDetail.Reference])

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
