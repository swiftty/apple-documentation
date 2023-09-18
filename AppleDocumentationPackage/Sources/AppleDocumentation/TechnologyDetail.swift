import Foundation
import SupportMacros

@ImplicitInit
public struct TechnologyDetail {
    public var metadata: Metadata
    public var abstract: [Abstract]
    public var primaryContentSections: [PrimaryContent]
    public var topicSections: [Topic]
    public var seeAlso: [SeeAlso]
    public var references: [Technology.Identifier: Reference]
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

    public enum Abstract {
        case text(String)
        case reference(Reference)

        @ImplicitInit
        public struct Reference {
            public var identifier: Technology.Identifier
            public var isActive: Bool
        }
    }

    public enum PrimaryContent {
        case content([Content])

        public enum Content {
            case heading(Heading)
            case paragraph([InlineContent])
            case aside([InlineContent])
            case unorderedList([InlineContent])

            @ImplicitInit
            public struct Heading {
                public var level: Int
                public var anchor: String
                public var text: String
            }

            public enum InlineContent {
                case text(String)
                case codeVoice(String)
                case image(Technology.Identifier)
                case reference(Reference)
                case strong([InlineContent])
                case inlineHead([InlineContent])

                @ImplicitInit
                // swiftlint:disable:next nesting
                public struct Reference {
                    public var identifier: Technology.Identifier
                    public var isActive: Bool
                }
            }
        }
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
        public var abstract: [Abstract]
        public var fragments: [Fragment]
        public var navigatorTitle: [Abstract]

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
