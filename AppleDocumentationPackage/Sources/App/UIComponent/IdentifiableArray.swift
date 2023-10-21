import Foundation

public struct IndexedItem<Element: Hashable>: Identifiable, Hashable {
    public var id: some Hashable { self }

    public var index: Int
    public var element: Element
}

extension Array where Element: Hashable {
    public func indexed() -> [IndexedItem<Element>] {
        enumerated().map(IndexedItem.init)
    }
}
