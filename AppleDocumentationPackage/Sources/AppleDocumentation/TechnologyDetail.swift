import Foundation
import SupportMacros

@ImplicitInit
public struct TechnologyDetail {
    public var metadata: Metadata
    public var abstract: [InlineContent]
    public var primaryContents: [PrimaryContent]
    public var topics: [Topic]
    public var relationships: [Topic]
    public var seeAlso: [SeeAlso]
    public var references: [Technology.Identifier: Reference]
    public var diffAvailability: Technology.DiffAvailability
}

public enum InlineContent: Hashable {
    case text(Text)
    case codeVoice(CodeVoice)
    case strong(Strong)
    case emphasis(Emphasis)
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
    public struct Emphasis: Hashable {
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
        public var roleHeading: String?
        public var platforms: [Platform]
        public var externalID: String?

        @ImplicitInit
        public struct Platform {
            public var name: String
            public var introducedAt: String
            public var current: String?
            public var beta: Bool
        }
    }

    @ImplicitInit
    public struct PrimaryContent: Hashable {
        public var content: [BlockContent]
        public var declarations: [Declaration]
        public var parameters: [Parameter]

        @ImplicitInit
        public struct Declaration: Hashable {
            public var tokens: [Fragment]
        }

        @ImplicitInit
        public struct Parameter: Hashable {
            public var name: String
            public var content: [BlockContent]
        }
    }

    public enum Topic: Hashable {
        case document(Document)
        case taskGroup(TaskGroup)
        case relationships(Relationship)

        @ImplicitInit
        public struct Document: Hashable {
            public var title: String
            public var identifiers: [Technology.Identifier]
        }

        @ImplicitInit
        public struct TaskGroup: Hashable {
            public var title: String
            public var identifiers: [Technology.Identifier]
            public var anchor: String
        }

        @ImplicitInit
        public struct Relationship: Hashable {
            public var title: String
            public var identifiers: [Technology.Identifier]
            public var type: String
        }
    }

    @ImplicitInit
    public struct SeeAlso: Hashable {
        public var title: String
        public var generated: Bool
        public var identifiers: [Technology.Identifier]
    }

    @ImplicitInit
    public struct Reference: Hashable {
        public var identifier: Technology.Identifier
        public var title: String?
        public var url: String?
        public var kind: String?
        public var role: String?
        public var abstract: [InlineContent]
        public var fragments: [Fragment]
        public var navigatorTitle: [Fragment]
        public var variants: [ImageVariant]
        public var beta: Bool

        @ImplicitInit
        public struct ImageVariant: Hashable {
            public var url: URL
            public var traits: [Trait]

            public enum Trait: String, RawRepresentable, Hashable {
                case x1 = "1x", x2 = "2x"  // swiftlint:disable:this identifier_name
                case light, dark
            }
        }
    }

    @ImplicitInit
    public struct Fragment: Hashable {
        public var text: String
        public var kind: Kind
        public var identifier: Technology.Identifier?

        public enum Kind {
            case keyword, text, identifier, label, typeIdentifier, genericParameter
            case internalParam, externalParam, attribute, number
        }
    }
}
