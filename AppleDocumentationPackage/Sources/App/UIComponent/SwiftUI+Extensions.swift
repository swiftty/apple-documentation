public import SwiftUI

extension View {
    public func onChange<T, U: Equatable>(
        of value: T,
        id: KeyPath<T, U>,
        initial: Bool = false,
        action: @escaping (_ oldValue: T, _ newValue: T) -> Void
    ) -> some View {
        onChange(of: OnChangeContainer(value: value, id: id), initial: initial) { oldValue, newValue in
            action(oldValue.value, newValue.value)
        }
    }

    public func onChange<T, U: Equatable>(
        of value: T,
        id: KeyPath<T, U>,
        initial: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        onChange(of: value, id: id, initial: initial) { _, _ in
            action()
        }
    }
}

private struct OnChangeContainer<T, U: Equatable>: Equatable {
    var value: T
    var id: KeyPath<T, U>

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value[keyPath: lhs.id] == rhs.value[keyPath: rhs.id]
    }
}
