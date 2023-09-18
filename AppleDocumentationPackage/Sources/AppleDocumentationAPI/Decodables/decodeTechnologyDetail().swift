import Foundation
import AppleDocumentation

public func decodeTechnologyDetail(from data: Data) throws -> TechnologyDetail {
    let result = try JSONDecoder().decode(Result.self, from: data)
    return result.technologyDetail
}

private struct Result: Decodable {
    var technologyDetail: TechnologyDetail

    // swiftlint:disable:next function_body_length
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
            abstract: detail.abstract.map {
                $0.toAbstract()
            },
            primaryContentSections: detail.primaryContentSections.map {
                .content($0.content?.map {
                    switch $0 {
                    case .heading(let heading):
                        .heading(.init(level: heading.level, anchor: heading.anchor, text: heading.text))

                    case .paragraph(let paragraph):
                        .paragraph(paragraph.toInlineContent())

                    case .aside(let aside):
                        .aside(aside.content.flatMap { $0.toInlineContent() })

                    case .unorderedList(let list):
                        .unorderedList(list.items.flatMap { $0.content.flatMap { $0.toInlineContent() } })
                    }
                } ?? [])
            },
            topicSections: detail.topicSections.map {
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
                    abstract: $0.abstract?.map {
                        $0.toAbstract()
                    } ?? [],
                    fragments: $0.fragments?.map {
                        .init(text: $0.text, kind: {
                            switch $0 {
                            case .identifier: .identifier
                            case .keyword: .keyword
                            case .text: .text
                            }
                        }($0.kind))
                    } ?? [],
                    navigatorTitle: $0.navigatorTitle?.map {
                        $0.toAbstract()
                    } ?? []
                )
            }
        )
    }
}

// swiftlint:disable nesting
private struct RawTechnologyDetail: Decodable {
    var metadata: RawMetadata
    var abstract: [RawAbstract]
    var primaryContentSections: [RawPrimaryContent]
    var topicSections: [RawTopic]
    var seeAlsoSections: [RawSeeAlso]?
    var references: [Technology.Identifier: RawReference]
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

private enum RawAbstract: Decodable {
    case text(Text)
    case reference(Reference)

    private enum CodingKeys: CodingKey {
        case type
    }

    enum AbstractType: String, RawRepresentable, Decodable {
        case text, reference
    }

    struct Text: Decodable {
        var text: String
    }

    struct Reference: Decodable {
        var identifier: Technology.Identifier
        var isActive: Bool
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(AbstractType.self, forKey: .type) {
        case .text:
            self = try .text(Text(from: decoder))

        case .reference:
            self = try .reference(Reference(from: decoder))
        }
    }

    func toAbstract() -> TechnologyDetail.Abstract {
        switch self {
        case .text(let text):
            return .text(text.text)

        case .reference(let ref):
            return .reference(.init(identifier: ref.identifier, isActive: ref.isActive))
        }
    }
}

private struct RawPrimaryContent: Decodable {
    var content: [Content]?

    enum Content: Decodable {
        case heading(Heading)
        case paragraph(Paragraph)
        case aside(Aside)
        case unorderedList(UnorderedList)

        enum Kind: String, RawRepresentable, Decodable {
            case heading
            case paragraph
            case aside
            case unorderedList
        }

        private enum CodingKeys: CodingKey {
            case type
        }

        struct Heading: Decodable {
            var level: Int
            var anchor: String
            var text: String
        }

        struct Paragraph: Decodable {
            var inlineContent: [InlineContent]

            enum InlineContent: Decodable {
                case text(Text)
                case codeVoice(CodeVoice)
                case image(Image)
                case reference(Reference)
                case strong(Paragraph)
                case inlineHead(Paragraph)

                enum Kind: String, RawRepresentable, Decodable {
                    case text
                    case codeVoice
                    case image
                    case reference
                    case strong
                    case inlineHead
                }

                private enum CodingKeys: CodingKey {
                    case type
                }

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

                init(from decoder: Decoder) throws {
                    let c = try decoder.container(keyedBy: CodingKeys.self)
                    switch try c.decode(Kind.self, forKey: .type) {
                    case .text:
                        self = try .text(Text(from: decoder))

                    case .codeVoice:
                        self = try .codeVoice(CodeVoice(from: decoder))

                    case .image:
                        self = try .image(Image(from: decoder))

                    case .reference:
                        self = try .reference(Reference(from: decoder))

                    case .strong:
                        self = try .strong(Paragraph(from: decoder))

                    case .inlineHead:
                        self = try .inlineHead(Paragraph(from: decoder))
                    }
                }
            }

            func toInlineContent() -> [TechnologyDetail.PrimaryContent.Content.InlineContent] {
                inlineContent.map {
                    switch $0 {
                    case .text(let text):
                        .text(text.text)

                    case .codeVoice(let code):
                        .codeVoice(code.code)

                    case .image(let image):
                        .image(image.identifier)

                    case .reference(let ref):
                        .reference(.init(identifier: ref.identifier, isActive: ref.isActive))

                    case .strong(let paragraph):
                        .strong(paragraph.toInlineContent())

                    case .inlineHead(let paragraph):
                        .inlineHead(paragraph.toInlineContent())
                    }
                }
            }
        }

        struct Aside: Decodable {
            var name: String?
            var style: String
            var content: [Paragraph]
        }

        struct UnorderedList: Decodable {
            var items: [Item]

            struct Item: Decodable {
                var content: [Paragraph]
            }
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            switch try c.decode(Kind.self, forKey: .type) {
            case .heading:
                self = try .heading(Heading(from: decoder))

            case .paragraph:
                self = try .paragraph(Paragraph(from: decoder))

            case .aside:
                self = try .aside(Aside(from: decoder))

            case .unorderedList:
                self = try .unorderedList(UnorderedList(from: decoder))
            }
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
    var abstract: [RawAbstract]?
    var fragments: [RawFragment]?
    var navigatorTitle: [RawAbstract]?
}

private struct RawFragment: Decodable {
    var text: String
    var kind: Kind

    enum Kind: String, RawRepresentable, Decodable {
        case text, keyword, identifier
    }
}

// swiftlint:enable nesting
