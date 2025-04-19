import Foundation
import SupportMacros

@ImplicitInit
public struct Technology: Sendable {
    public var title: String
    public var languages: [Language]
    public var tags: [String]
    public var destination: Destination
}

extension Technology {
    @ImplicitInit
    public struct Identifier: Hashable, RawRepresentable, Sendable {
        public var rawValue: String
    }

    @ImplicitInit
    public struct Destination: Hashable, Sendable {
        public var identifier: Identifier
        public var title: String
        public var value: Value
        public var abstract: String

        @ImplicitInit
        public struct Value: Hashable, RawRepresentable, Sendable {
            public var rawValue: String
        }
    }

    public enum Language: Sendable {
        case objectiveC
        case swift
        case other
    }
}

extension Technology {
    public struct DiffAvailability: Sendable {
        public subscript(key: Key) -> Payload? {
            items[key]
        }

        private var items: [Key: Payload]

        public init(_ values: [Key: Payload]) {
            items = values
        }

        @ImplicitInit
        public struct Key: Hashable, RawRepresentable, Sendable {
            public var rawValue: String
        }

        public struct Payload: Equatable, Comparable, Sendable {
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

            public struct Versions: Equatable, Comparable, Sendable {
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
