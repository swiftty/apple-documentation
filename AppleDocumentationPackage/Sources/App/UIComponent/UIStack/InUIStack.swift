public import SwiftUI

public struct InUIStack<Value, Loaded: View, Failed: View, Loading: View>: View {
    private let target: WithUIStack<Value>
    @ViewBuilder private var loading: (Bool) -> Loading
    @ViewBuilder private var loaded: (Value) -> Loaded
    @ViewBuilder private var failed: (any Error) -> Failed

    public var body: some View {
        ZStack {
            if let error = target.error {
                failed(error)
            } else {
                loaded(target.wrappedValue)
            }

            if target.isIdle {
                loading(false)
            } else if target.isLoading {
                loading(true)
            }
        }
    }
}

extension InUIStack {
    public init(
        _ target: () -> WithUIStack<Value>,
        @ViewBuilder loading: @escaping (Bool) -> Loading,
        @ViewBuilder loaded: @escaping (Value) -> Loaded,
        @ViewBuilder failed: @escaping (any Error) -> Failed
    ) {
        self.init(target: target(), loading: loading, loaded: loaded, failed: failed)
    }
}
