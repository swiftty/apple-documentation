import Foundation
import SupportMacros

@ImplicitInit
public struct TechnologyDetailIndex: Hashable {
    public var title: String
    public var children: [Item]
}

extension TechnologyDetailIndex {
    @ImplicitInit
    public struct Item: Hashable {
        public var title: String
        public var path: String
        public var external: Bool
        public var deprecated: Bool

        public var kind: Kind
        public var children: [Item]

        public enum Kind: Hashable {
            case groupMarker
            case `protocol`, `class`, `struct`, `enum`, collection
            case property, method, `init`, `func`, `case`
            case unknown(String)
        }
    }
}
