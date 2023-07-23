import Foundation

public struct Technologies: Decodable {
    public var technologies: [Technology]
    public var diffAvailability: DiffAvailability

    public init(from decoder: Decoder) throws {
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

            init(from decoder: Decoder) throws {
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

            init(from decoder: Decoder) throws {
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

                init(from decoder: Decoder) throws {
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
            var diffAvailability: DiffAvailability
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
                    tags: tech.tags,
                    destination: .init(
                        identifier: tech.destination.identifier,
                        title: topic.title,
                        url: topic.url,
                        abstract: abstract.text
                    )
                )
            }
        diffAvailability = root.diffAvailability
    }
}

extension Technologies {
    public struct Technology {
        public var title: String
        public var languages: [Language]
        public var tags: [String]
        public var destination: Destination

        public struct Identifier: Hashable, RawRepresentable, Decodable, CodingKeyRepresentable {
            public var rawValue: String

            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }

        public struct Destination {
            public var identifier: Identifier
            public var title: String
            public var url: String
            public var abstract: String
        }

        public enum Language: Decodable {
            case objectiveC
            case swift
            case other

            public init(from decoder: Decoder) throws {
                enum RawLanguage: String, RawRepresentable, Decodable {
                    case occ, swift, data
                }

                self = switch try RawLanguage(from: decoder) {
                case .occ: .objectiveC
                case .swift: .swift
                case .data: .other
                }
            }
        }
    }
}

extension Technologies {
    public struct DiffAvailability: Decodable {
        public subscript(key: Key) -> Payload? {
            items[key]
        }

        private var items: [Key: Payload]

        public init(from decoder: Decoder) throws {
            items = try [Key: Payload](from: decoder)
        }

        public struct Key: Hashable, RawRepresentable, Decodable, CodingKeyRepresentable {
            public var rawValue: String

            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }

        public struct Payload: Decodable, Equatable, Comparable {
            public static func < (lhs: Self, rhs: Self) -> Bool {
                lhs.versions < rhs.versions
            }

            public var change: String
            public var platform: String
            public var versions: Versions

            public struct Versions: Decodable, Equatable, Comparable {
                public static func < (lhs: Self, rhs: Self) -> Bool {
                    lhs.from < rhs.from
                }

                public var from: String
                public var to: String

                public init(from decoder: Decoder) throws {
                    var c = try decoder.unkeyedContainer()
                    from = try c.decode(String.self)
                    to = try c.decode(String.self)
                }
            }
        }
    }
}

extension Technologies.DiffAvailability: Collection {
    public typealias Element = [Key: Payload].Element
    public typealias Index = [Key: Payload].Index

    public var startIndex: Index {
        items.startIndex
    }

    public var endIndex: Index {
        items.endIndex
    }

    public subscript(position: Index) -> Element {
        items[position]
    }

    public func index(after i: Index) -> Index {
        items.index(after: i)
    }
}

extension Technologies.DiffAvailability {
    public func sorted() -> [Element] {
        items.sorted(by: { lhs, rhs in lhs.value > rhs.value })
    }
}

extension Technologies.DiffAvailability.Key {
    public static let minor = Self.init(rawValue: "minor")

    public static let major = Self.init(rawValue: "major")

    public static let beta = Self.init(rawValue: "beta")
}

extension Technologies {
    public struct Changes: Decodable {
        public subscript(key: Technology.Identifier) -> Change? {
            items[key]
        }

        private var items: [Technology.Identifier: Change]

        public init(from decoder: Decoder) throws {
            struct RawContent: Decodable {
                var change: Change?

                enum CodingKeys: CodingKey {
                    case change
                }

                init(from decoder: Decoder) throws {
                    let c = try decoder.container(keyedBy: CodingKeys.self)
                    change = try c.decodeIfPresent(Change.self, forKey: .change)
                }
            }

            items = try [Technology.Identifier: RawContent](from: decoder)
                .compactMapValues(\.change)
        }

        public enum Change: String, Decodable {
            case modified, added
        }
    }
}

extension Technologies.Changes: Collection {
    public typealias Element = [Technologies.Technology.Identifier: Change].Element
    public typealias Index = [Technologies.Technology.Identifier: Change].Index

    public var startIndex: Index {
        items.startIndex
    }

    public var endIndex: Index {
        items.endIndex
    }

    public subscript(position: Index) -> Element {
        items[position]
    }

    public func index(after i: Index) -> Index {
        items.index(after: i)
    }
}
