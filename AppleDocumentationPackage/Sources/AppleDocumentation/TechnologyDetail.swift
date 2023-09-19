import Foundation
import SupportMacros

@ImplicitInit
public struct TechnologyDetail {
    public var metadata: Metadata
    public var abstract: [InlineContent]
    public var primaryContents: [PrimaryContent]
    public var topics: [Topic]
    public var seeAlso: [SeeAlso]
    public var references: [Technology.Identifier: Reference]
    public var diffAvailability: Technology.DiffAvailability
}

public enum InlineContent: Hashable {
    case text(Text)
    case codeVoice(CodeVoice)
    case strong(Strong)
    case reference(Reference)
    case image(Image)
    case inlineHead(InlineHead)
    case unknown(Unknown)

    @ImplicitInit
    public struct Text: Hashable {
        public var text: String
    }

    @ImplicitInit
    public struct CodeVoice: Hashable {
        public var code: String
    }

    @ImplicitInit
    public struct Strong: Hashable {
        public var contents: [InlineContent]
    }

    @ImplicitInit
    public struct Reference: Hashable {
        public var identifier: Technology.Identifier
        public var isActive: Bool
    }

    @ImplicitInit
    public struct Image: Hashable {
        public var identifier: Technology.Identifier
    }

    @ImplicitInit
    public struct InlineHead: Hashable {
        public var contents: [InlineContent]
    }

    @ImplicitInit
    public struct Unknown: Hashable {
        public var type: String
    }
}

public enum BlockContent: Hashable {
    case paragraph(Paragraph)
    case heading(Heading)
    case aside(Aside)
    case unorderedList(UnorderedList)
    case unknown(Unknown)

    @ImplicitInit
    public struct Paragraph: Hashable {
        public var contents: [InlineContent]
    }

    @ImplicitInit
    public struct Heading: Hashable {
        public var level: Int
        public var anchor: String
        public var text: String
    }

    @ImplicitInit
    public struct Aside: Hashable {
        public var style: String
        public var name: String?
        public var contents: [BlockContent]
    }

    @ImplicitInit
    public struct UnorderedList: Hashable {
        public var items: [Item]

        @ImplicitInit
        public struct Item: Hashable {
            public var content: [BlockContent]
        }
    }

    @ImplicitInit
    public struct Unknown: Hashable {
        public var type: String
    }
}

extension TechnologyDetail {
    @ImplicitInit
    public struct Metadata {
        public var title: String
        public var role: String
        public var roleHeading: String
        public var platforms: [Platform]
        public var externalID: String?

        @ImplicitInit
        public struct Platform {
            public var name: String
            public var introducedAt: String
            public var current: String
            public var beta: Bool
        }
    }

    @ImplicitInit
    public struct PrimaryContent {
        public var content: [BlockContent]
    }

    public enum Topic {
        case taskGroup(TaskGroup)

        @ImplicitInit
        public struct TaskGroup {
            public var title: String
            public var identifiers: [Technology.Identifier]
            public var anchor: String
        }
    }

    @ImplicitInit
    public struct SeeAlso {
        public var title: String
        public var generated: Bool
        public var identifiers: [Technology.Identifier]
    }

    @ImplicitInit
    public struct Reference {
        public var identifier: Technology.Identifier
        public var title: String
        public var url: String
        public var kind: String?
        public var role: String?
        public var abstract: [InlineContent]
        public var fragments: [Fragment]
        public var navigatorTitle: [InlineContent]

        @ImplicitInit
        public struct Fragment {
            public var text: String
            public var kind: Kind

            public enum Kind {
                case keyword, text, identifier
            }
        }
    }
}
