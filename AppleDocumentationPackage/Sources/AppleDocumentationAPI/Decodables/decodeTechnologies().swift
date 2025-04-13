public import Foundation
public import AppleDocumentation
import Algorithms

public func decodeTechnologies(from data: Data) throws -> (
    technologies: [Technology],
    diffAvailability: Technology.DiffAvailability
) {
    let result = try JSONDecoder().decode(Result.self, from: data)
    return (result.technologies, result.diffAvailability)
}

// MARK: -

private struct Result: Decodable {
    var technologies: [Technology]
    var diffAvailability: Technology.DiffAvailability

    // swiftlint:disable:next function_body_length
    init(from decoder: any Decoder) throws {
        struct RawTechnology: Decodable {
            var title: String
            var languages: [Technology.Language]
            var tags: [String]
            var destination: RawDestination

            struct RawDestination: Decodable {
                var identifier: Technology.Identifier
                var type: String
                var isActive: Bool
            }
        }
        enum RawSection: Decodable {
            case technologies(RawTechnologies)
            case other(kind: String)

            struct RawTechnologies: Decodable {
                var groups: [RawGroup]

                struct RawGroup: Decodable {
                    var technologies: [RawTechnology]
                }
            }

            init(from decoder: any Decoder) throws {
                enum CodingKeys: CodingKey {
                    case kind
                }
                let c = try decoder.container(keyedBy: CodingKeys.self)
                let kind = try c.decode(String.self, forKey: .kind)

                switch kind {
                case "technologies":
                    self = .technologies(try RawTechnologies(from: decoder))

                case let other:
                    self = .other(kind: other)
                }
            }
        }
        struct RawReference: Decodable {
            var identifier: Technology.Identifier
            var content: Content

            init(from decoder: any Decoder) throws {
                enum CodingKeys: CodingKey {
                    case identifier
                }
                let c = try decoder.container(keyedBy: CodingKeys.self)
                identifier = try c.decode(Technology.Identifier.self, forKey: .identifier)
                content = try Content(from: decoder)
            }

            enum Content: Decodable {
                case topic(RawTopic)
                case other(type: String)

                init(from decoder: any Decoder) throws {
                    enum CodingKeys: CodingKey {
                        case type
                    }
                    let c = try decoder.container(keyedBy: CodingKeys.self)
                    let type = try c.decode(String.self, forKey: .type)

                    switch type {
                    case "topic":
                        self = .topic(try RawTopic(from: decoder))

                    case let other:
                        self = .other(type: other)
                    }
                }

                struct RawTopic: Decodable {
                    var title: String
                    var url: String
                    var abstract: [RawAbstract]
                }
            }

            struct RawAbstract: Decodable {
                var text: String
            }
        }
        struct Root: Decodable {
            var sections: [RawSection]
            var references: [Technology.Identifier: RawReference]
            var diffAvailability: [Technology.DiffAvailability.Key: Technology.DiffAvailability.Payload]
        }

        let root = try Root(from: decoder)

        technologies = root.sections
            .flatMap { section -> [RawTechnology] in
                switch section {
                case .technologies(let t): return t.groups.flatMap(\.technologies)
                case .other: return []
                }
            }
            .compactMap { tech -> Technology? in
                guard tech.destination.isActive,
                      let ref = root.references[tech.destination.identifier],
                      case .topic(let topic) = ref.content,
                      let abstract = topic.abstract.first
                else { return nil }

                return Technology(
                    title: tech.title,
                    languages: tech.languages,
                    tags: Array(tech.tags.uniqued()),
                    destination: .init(
                        identifier: tech.destination.identifier,
                        title: topic.title,
                        value: .init(rawValue: topic.url),
                        abstract: abstract.text
                    )
                )
            }
        diffAvailability = .init(root.diffAvailability)
    }
}
