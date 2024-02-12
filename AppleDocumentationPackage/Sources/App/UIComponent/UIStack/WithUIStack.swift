import Foundation

@propertyWrapper
public struct WithUIStack<T> {
    public struct Key: Equatable, @unchecked Sendable {
        private let rawValue: any Equatable
        private let equals: (any Equatable) -> Bool
    }
    public enum State {
        case idle
        case loading
        case loaded(T)
        case failed(Error, key: Key)

        public static func failed(_ error: Error) -> Self {
            .failed(error, key: .init(Seeder.seed()))
        }
    }
    public var wrappedValue: T {
        get {
            if case .loaded(let val) = newState {
                return val
            }
            if case .loaded(let val) = oldState {
                return val
            }
            return initialValue
        }
        set {
            next(.loaded(newValue))
        }
    }
    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }
    public var isIdle: Bool {
        guard case .idle = newState else { return false }
        return true
    }
    public var isLoading: Bool {
        guard case .loading = newState else { return false }
        return true
    }
    public var error: Error? {
        guard case .failed(let error, _) = newState else { return nil }
        return error
    }

    private var newState: State = .idle {
        didSet {
            switch (oldValue, oldState) {
            case (.idle, .idle), (.loading, .loading), (.failed, .failed):
                break

            default:
                oldState = oldValue
            }
        }
    }
    private var oldState: State = .idle
    private var initialValue: T

    public init(wrappedValue: T) {
        initialValue = wrappedValue
    }

    public init(initialValue: T) {
        self.init(wrappedValue: initialValue)
    }

    public mutating func next(_ nextState: State) {
        newState = nextState
    }
}

extension WithUIStack: Sendable where T: Sendable {}
extension WithUIStack.State: Sendable where T: Sendable {}
extension WithUIStack: Equatable where T: Equatable {}

extension WithUIStack.State: Equatable where T: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
            (.loading, .loading):
            return true

        case (.loaded(let lhs), .loaded(let rhs)):
            return lhs == rhs

        case (.failed(_, let lhs), .failed(_, let rhs)):
            return lhs == rhs

        default:
            return false
        }
    }
}

extension WithUIStack.Key {
    public init<E: Equatable>(_ rawValue: E) {
        self.rawValue = rawValue
        self.equals = { other in
            guard let other = other as? E else { return false }
            return rawValue == other
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.equals(rhs.rawValue)
    }
}

extension WithUIStack {
    public init<U>(_ other: WithUIStack<U>?) where T == U? {
        guard let other else {
            self = .init(wrappedValue: nil)
            return
        }
        self = .init(currentState: other.newState.opt(),
                     oldState: other.oldState.opt(),
                     initialValue: other.initialValue)
    }

    private init(currentState: State, oldState: State, initialValue: T) {
        self.newState = currentState
        self.oldState = oldState
        self.initialValue = initialValue
    }
}

private extension WithUIStack.Key {
    func opt() -> WithUIStack<T?>.Key {
        .init(rawValue: rawValue, equals: equals)
    }
}

private extension WithUIStack.State {
    func opt() -> WithUIStack<T?>.State {
        switch self {
        case .idle: return .idle
        case .loading: return .loading
        case .loaded(let v): return .loaded(v)
        case .failed(let error, let key): return .failed(error, key: key.opt())
        }
    }
}

// MARK: -
private enum Seeder {
    class Storage {
        var value: UInt = 0
    }
    private static let storage = Storage()

    static func seed() -> UInt {
        defer { storage.value &+= 1 }
        return storage.value
    }
}
