import Foundation
import AppleDocumentation

public func decodeTechnologyDetail(from data: Data) throws -> TechnologyDetail {
    let result = try JSONDecoder().decode(Result.self, from: data)
    return result.technologyDetail
}

private struct Result: Decodable {
    var technologyDetail: TechnologyDetail

    init(from decoder: Decoder) throws {
        let detail = try RawTechnologyDetail(from: decoder)
        technologyDetail = TechnologyDetail(
            metadata: .init(
                title: detail.metadata.title,
                role: detail.metadata.role,
                roleHeading: detail.metadata.roleHeading,
                platforms: detail.metadata.platforms?.map {
                    TechnologyDetail.Metadata.Platform(
                        name: $0.name,
                        introducedAt: $0.introducedAt,
                        current: $0.current,
                        beta: $0.beta ?? false
                    )
                } ?? [],
                externalID: detail.metadata.externalID),
            abstract: detail.abstract?.map(\.inlineContent) ?? [],
            primaryContents: detail.primaryContentSections?.map {
                .init(
                    content: $0.content?.map(\.blockContent) ?? [],
                    declarations: $0.declarations?.map(\.declaration) ?? [],
                    parameters: $0.parameters?.map(\.parameter) ?? []
                )
            } ?? [],
            topics: detail.topicSections?.map(\.topic) ?? [],
            relationships: detail.relationshipsSections?.map(\.topic) ?? [],
            seeAlso: detail.seeAlsoSections?.map {
                .init(title: $0.title, generated: $0.generated ?? false, identifiers: $0.identifiers)
            } ?? [],
            references: detail.references.mapValues {
                .init(
                    identifier: $0.identifier,
                    title: $0.title,
                    url: $0.url,
                    kind: $0.kind,
                    role: $0.role,
                    abstract: $0.abstract?.map(\.inlineContent) ?? [],
                    fragments: $0.fragments?.map(\.fragment) ?? [],
                    navigatorTitle: $0.navigatorTitle?.map(\.fragment) ?? [],
                    variants: $0.variants?.map(\.variant) ?? [],
                    beta: $0.beta ?? false
                )
            },
            diffAvailability: .init(detail.diffAvailability ?? [:])
        )
    }
}

private struct RawTechnologyDetail: Decodable {
    var metadata: RawMetadata
    var abstract: [RawInlineContent]?
    var primaryContentSections: [PrimaryContentSection]?
    var topicSections: [RawTopic]?
    var relationshipsSections: [RawTopic]?
    var seeAlsoSections: [RawSeeAlso]?
    var references: [Technology.Identifier: RawReference]
    var diffAvailability: [Technology.DiffAvailability.Key: Technology.DiffAvailability.Payload]?

    struct PrimaryContentSection: Decodable {
        var content: [RawBlockContent]?
        var declarations: [RawDeclaration]?
        var parameters: [RawParameter]?
    }
}

private struct RawMetadata: Decodable {
    var title: String
    var role: String
    var roleHeading: String?
    var platforms: [RawPlatform]?
    var externalID: String?

    struct RawPlatform: Decodable {
        var name: String
        var introducedAt: String
        var current: String?
        var beta: Bool?
    }
}

private enum RawBlockContent: Decodable {
    case paragraph(Paragraph)
    case heading(Heading)
    case aside(Aside)
    case unorderedList(UnorderedList)
    case unknown(String)

    struct Paragraph: Decodable {
        var inlineContent: [RawInlineContent]
    }

    struct Heading: Decodable {
        var level: Int
        var anchor: String
        var text: String
    }

    struct Aside: Decodable {
        var style: String
        var name: String?
        var content: [RawBlockContent]
    }

    struct UnorderedList: Decodable {
        var items: [Item]

        struct Item: Decodable {
            var content: [RawBlockContent]
        }
    }

    private enum CodingKeys: CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(String.self, forKey: .type)
        self = switch type {
        case "paragraph": try .paragraph(.init(from: decoder))
        case "heading": try .heading(.init(from: decoder))
        case "aside": try .aside(.init(from: decoder))
        case "unorderedList": try .unorderedList(.init(from: decoder))
        default: .unknown(type)
        }
    }

    var blockContent: BlockContent {
        switch self {
        case .paragraph(let paragraph):
            .paragraph(.init(contents: paragraph.inlineContent.map(\.inlineContent)))

        case .heading(let heading):
            .heading(.init(level: heading.level, anchor: heading.anchor, text: heading.text))

        case .aside(let aside):
            .aside(.init(style: aside.style, name: aside.name, contents: aside.content.map(\.blockContent)))

        case .unorderedList(let list):
            .unorderedList(.init(items: list.items.map { .init(content: $0.content.map(\.blockContent)) }))

        case .unknown(let type):
            .unknown(.init(type: type))
        }
    }
}

private enum RawInlineContent: Decodable {
    case text(Text)
    case codeVoice(CodeVoice)
    case image(Image)
    case reference(Reference)
    case strong(Strong)
    case emphasis(Emphasis)
    case inlineHead(InlineHead)
    case unknown(String)

    struct Text: Decodable {
        var text: String
    }

    struct CodeVoice: Decodable {
        var code: String
    }

    struct Image: Decodable {
        var identifier: Technology.Identifier
    }

    struct Reference: Decodable {
        var identifier: Technology.Identifier
        var isActive: Bool
    }

    struct Strong: Decodable {
        var inlineContent: [RawInlineContent]
    }

    struct Emphasis: Decodable {
        var inlineContent: [RawInlineContent]
    }

    struct InlineHead: Decodable {
        var inlineContent: [RawInlineContent]
    }

    private enum CodingKeys: CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(String.self, forKey: .type)
        self = switch type {
        case "text": try .text(.init(from: decoder))
        case "codeVoice": try .codeVoice(.init(from: decoder))
        case "image": try .image(.init(from: decoder))
        case "reference": try .reference(.init(from: decoder))
        case "strong": try .strong(.init(from: decoder))
        case "emphasis": try .emphasis(.init(from: decoder))
        case "inlineHead": try .inlineHead(.init(from: decoder))
        default: .unknown(type)
        }
    }

    var inlineContent: InlineContent {
        switch self {
        case .text(let text):
            .text(.init(text: text.text))

        case .codeVoice(let code):
            .codeVoice(.init(code: code.code))

        case .image(let image):
            .image(.init(identifier: image.identifier))

        case .reference(let ref):
            .reference(.init(identifier: ref.identifier, isActive: ref.isActive))

        case .strong(let strong):
            .strong(.init(contents: strong.inlineContent.map(\.inlineContent)))

        case .emphasis(let emphasis):
            .emphasis(.init(contents: emphasis.inlineContent.map(\.inlineContent)))

        case .inlineHead(let head):
            .inlineHead(.init(contents: head.inlineContent.map(\.inlineContent)))

        case .unknown(let type):
            .unknown(.init(type: type))
        }
    }
}

private enum RawTopic: Decodable {
    case document(Document)
    case taskGroup(TaskGroup)
    case relationships(Relationship)

    enum Kind: String, RawRepresentable, Decodable {
        case taskGroup
        case relationships
    }

    struct Document: Decodable {
        var title: String
        var identifiers: [Technology.Identifier]
    }

    struct TaskGroup: Decodable {
        var title: String
        var identifiers: [Technology.Identifier]
        var anchor: String
    }

    struct Relationship: Decodable {
        var title: String
        var identifiers: [Technology.Identifier]
        var type: String
    }

    private enum CodingKeys: CodingKey {
        case kind
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self = switch try c.decodeIfPresent(Kind.self, forKey: .kind) {
        case .taskGroup:
            try .taskGroup(TaskGroup(from: decoder))

        case .relationships:
            try .relationships(Relationship(from: decoder))

        case nil:
            try .document(Document(from: decoder))
        }
    }

    var topic: TechnologyDetail.Topic {
        switch self {
        case .document(let doc):
            .document(.init(title: doc.title, identifiers: doc.identifiers))
        case .taskGroup(let group):
            .taskGroup(.init(title: group.title, identifiers: group.identifiers, anchor: group.anchor))
        case .relationships(let rel):
            .relationships(.init(title: rel.title, identifiers: rel.identifiers, type: rel.type))
        }
    }
}

private struct RawSeeAlso: Decodable {
    var title: String
    var generated: Bool?
    var identifiers: [Technology.Identifier]
}

private struct RawReference: Decodable {
    var identifier: Technology.Identifier
    var title: String?
    var type: String
    var kind: String?
    var role: String?
    var url: String?
    var abstract: [RawInlineContent]?
    var fragments: [RawFragment]?
    var navigatorTitle: [RawFragment]?
    var variants: [RawImageVariant]?
    var beta: Bool?
}

private struct RawFragment: Decodable {
    var text: String
    var kind: Kind
    var identifier: Technology.Identifier?

    enum Kind: String, RawRepresentable, Decodable {
        case text, keyword, identifier, label, typeIdentifier, genericParameter
        case internalParam, externalParam, attribute, number
    }

    var fragment: TechnologyDetail.Fragment {
        let kind: TechnologyDetail.Fragment.Kind = switch kind {
        case .text: .text
        case .keyword: .keyword
        case .identifier: .identifier
        case .label: .label
        case .typeIdentifier: .typeIdentifier
        case .genericParameter: .genericParameter
        case .internalParam: .internalParam
        case .externalParam: .externalParam
        case .attribute: .attribute
        case .number: .number
        }
        return .init(text: text, kind: kind, identifier: identifier)
    }
}

private struct RawImageVariant: Decodable {
    var url: URL
    var traits: [Trait]

    enum Trait: String, RawRepresentable, Decodable {
        case x1 = "1x", x2 = "2x"  // swiftlint:disable:this identifier_name
        case light, dark
    }

    var variant: TechnologyDetail.Reference.ImageVariant {
        TechnologyDetail.Reference.ImageVariant(
            url: url,
            traits: traits.map {
                switch $0 {
                case .x1: .x1
                case .x2: .x2
                case .dark: .dark
                case .light: .light
                }
            }
        )
    }
}

private struct RawDeclaration: Decodable {
    var languages: [String]
    var platforms: [String]
    var tokens: [RawFragment]

    var declaration: TechnologyDetail.PrimaryContent.Declaration {
        .init(tokens: tokens.map(\.fragment))
    }
}

private struct RawParameter: Decodable {
    var name: String
    var content: [RawBlockContent]

    var parameter: TechnologyDetail.PrimaryContent.Parameter {
        .init(name: name, content: content.map(\.blockContent))
    }
}
