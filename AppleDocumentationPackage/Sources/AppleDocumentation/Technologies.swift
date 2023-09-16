import Foundation
import SupportMacros

public struct Technology {
    public var title: String
    public var languages: [Language]
    public var tags: [String]
    public var destination: Destination

    public init(title: String, languages: [Language], tags: [String], destination: Destination) {
        self.title = title
        self.languages = languages
        self.tags = tags
        self.destination = destination
    }
}

extension Technology {
    @ImplicitInit
    public struct Identifier: Hashable, RawRepresentable {
        public var rawValue: String
    }

    @ImplicitInit
    public struct Destination: Hashable {
        public var identifier: Identifier
        public var title: String
        public var url: String
        public var abstract: String

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.identifier == rhs.identifier
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    public enum Language {
        case objectiveC
        case swift
        case other
    }
}

extension Technology {
    public struct DiffAvailability {
        public subscript(key: Key) -> Payload? {
            items[key]
        }

        private var items: [Key: Payload]

        public init(_ values: [Key: Payload]) {
            items = values
        }

        public struct Key: Hashable, RawRepresentable {
            public var rawValue: String

            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }

        public struct Payload: Equatable, Comparable {
            public static func < (lhs: Self, rhs: Self) -> Bool {
                lhs.versions < rhs.versions
            }

            public var change: String
            public var platform: String
            public var versions: Versions

            public init(change: String, platform: String, versions: Versions) {
                self.change = change
                self.platform = platform
                self.versions = versions
            }

            public struct Versions: Equatable, Comparable {
                public static func < (lhs: Self, rhs: Self) -> Bool {
                    lhs.from < rhs.from
                }

                public var from: String
                public var to: String

                public init(from: String, to: String) {
                    self.from = from
                    self.to = to
                }
            }
        }
    }
}

extension Technology.DiffAvailability: Collection {
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

extension Technology.DiffAvailability {
    public func sorted() -> [Element] {
        items.sorted(by: { lhs, rhs in lhs.value > rhs.value })
    }
}

extension Technology.DiffAvailability.Key {
    public static let minor = Self.init(rawValue: "minor")

    public static let major = Self.init(rawValue: "major")

    public static let beta = Self.init(rawValue: "beta")
}

extension Technology {
    public struct Changes {
        public subscript(key: Technology.Identifier) -> Change? {
            items[key]
        }

        private var items: [Technology.Identifier: Change]

        public init(_ values: [Technology.Identifier: Change]) {
            items = values
        }

        public enum Change: String, Decodable {
            case modified, added
        }
    }
}

extension Technology.Changes: Collection {
    public typealias Element = [Technology.Identifier: Change].Element
    public typealias Index = [Technology.Identifier: Change].Index

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
