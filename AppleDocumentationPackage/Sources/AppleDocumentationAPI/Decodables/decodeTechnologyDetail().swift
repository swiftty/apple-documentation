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
            abstract: detail.abstract.map(\.inlineContent),
            primaryContents: detail.primaryContentSections.map {
                .init(content: $0.content.map(\.blockContent))
            },
            topics: detail.topicSections.map {
                switch $0 {
                case .taskGroup(let group):
                    .taskGroup(.init(title: group.title, identifiers: group.identifiers, anchor: group.anchor))
                }
            },
            seeAlso: detail.seeAlsoSections?.map {
                .init(title: $0.title, generated: $0.generated, identifiers: $0.identifiers)
            } ?? [],
            references: detail.references.mapValues {
                .init(
                    identifier: $0.identifier,
                    title: $0.title,
                    url: $0.url,
                    kind: $0.kind,
                    role: $0.role,
                    abstract: $0.abstract?.map(\.inlineContent) ?? [],
                    fragments: $0.fragments?.map {
                        .init(text: $0.text, kind: {
                            switch $0 {
                            case .identifier: .identifier
                            case .keyword: .keyword
                            case .text: .text
                            }
                        }($0.kind))
                    } ?? [],
                    navigatorTitle: $0.navigatorTitle?.map(\.inlineContent) ?? []
                )
            },
            diffAvailability: .init(detail.diffAvailability ?? [:])
        )
    }
}

private struct RawTechnologyDetail: Decodable {
    var metadata: RawMetadata
    var abstract: [RawInlineContent]
    var primaryContentSections: [PrimaryContentSection]
    var topicSections: [RawTopic]
    var seeAlsoSections: [RawSeeAlso]?
    var references: [Technology.Identifier: RawReference]
    var diffAvailability: [Technology.DiffAvailability.Key: Technology.DiffAvailability.Payload]?

    struct PrimaryContentSection: Decodable {
        var content: [RawBlockContent]
    }
}

private struct RawMetadata: Decodable {
    var title: String
    var role: String
    var roleHeading: String
    var platforms: [RawPlatform]?
    var externalID: String?

    struct RawPlatform: Decodable {
        var name: String
        var introducedAt: String
        var current: String
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
        self = try switch type {
        case "paragraph": .paragraph(.init(from: decoder))
        case "heading": .heading(.init(from: decoder))
        case "aside": .aside(.init(from: decoder))
        case "unorderedList": .unorderedList(.init(from: decoder))
        default: .unknown(type)
        }
    }

    var blockContent: BlockContent {
        switch self {
        case .paragraph(let paragraph):
            BlockContents.Paragraph(contents: paragraph.inlineContent.map(\.inlineContent))

        case .heading(let heading):
            BlockContents.Heading(level: heading.level, anchor: heading.anchor, text: heading.text)

        case .aside(let aside):
            BlockContents.Aside(style: aside.style, name: aside.name, contents: aside.content.map(\.blockContent))

        case .unorderedList(let list):
            BlockContents.UnorderedList(items: list.items.map { .init(content: $0.content.map(\.blockContent)) })

        case .unknown(let type):
            BlockContents.Unknown(type: type)
        }
    }
}

private enum RawInlineContent: Decodable {
    case text(Text)
    case codeVoice(CodeVoice)
    case image(Image)
    case reference(Reference)
    case strong(Strong)
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

    struct InlineHead: Decodable {
        var inlineContent: [RawInlineContent]
    }

    private enum CodingKeys: CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(String.self, forKey: .type)
        self = try switch type {
        case "text": .text(.init(from: decoder))
        case "codeVoice": .codeVoice(.init(from: decoder))
        case "image": .image(.init(from: decoder))
        case "reference": .reference(.init(from: decoder))
        case "strong": .strong(.init(from: decoder))
        case "inlineHead": .inlineHead(.init(from: decoder))
        default: .unknown(type)
        }
    }

    var inlineContent: InlineContent {
        switch self {
        case .text(let text):
            InlineContents.Text(text: text.text)

        case .codeVoice(let code):
            InlineContents.CodeVoice(code: code.code)

        case .image(let image):
            InlineContents.Image(identifier: image.identifier)

        case .reference(let ref):
            InlineContents.Reference(identifier: ref.identifier, isActive: ref.isActive)

        case .strong(let strong):
            InlineContents.Strong(contents: strong.inlineContent.map(\.inlineContent))

        case .inlineHead(let head):
            InlineContents.InlineHead(contents: head.inlineContent.map(\.inlineContent))

        case .unknown(let type):
            InlineContents.Unknown(type: type)
        }
    }
}

private enum RawTopic: Decodable {
    case taskGroup(TaskGroup)

    enum Kind: String, RawRepresentable, Decodable {
        case taskGroup
    }

    struct TaskGroup: Decodable {
        var title: String
        var identifiers: [Technology.Identifier]
        var anchor: String
    }

    private enum CodingKeys: CodingKey {
        case kind
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(Kind.self, forKey: .kind) {
        case .taskGroup:
            self = try .taskGroup(TaskGroup(from: decoder))
        }
    }
}

private struct RawSeeAlso: Decodable {
    var title: String
    var generated: Bool
    var identifiers: [Technology.Identifier]
}

private struct RawReference: Decodable {
    var identifier: Technology.Identifier
    var title: String
    var type: String
    var kind: String?
    var role: String?
    var url: String
    var abstract: [RawInlineContent]?
    var fragments: [RawFragment]?
    var navigatorTitle: [RawInlineContent]?
}

private struct RawFragment: Decodable {
    var text: String
    var kind: Kind

    enum Kind: String, RawRepresentable, Decodable {
        case text, keyword, identifier
    }
}
