public import SwiftUI

public struct InObservation<Model: Observable, Content: View, Loading: View>: View {
    @ViewBuilder private var content: (Model) -> Content
    @ViewBuilder private var loading: () -> Loading

    @State private var model: Model?
    private let initializer: () -> Model

    public init(
        _ initializer: @escaping () -> Model,
        @ViewBuilder content: @escaping (Model) -> Content,
        @ViewBuilder loading: @escaping () -> Loading = { Color.clear }
    ) {
        self.initializer = initializer
        self.content = content
        self.loading = loading
    }

    public var body: some View {
        if let model {
            content(model)
        } else {
            loading()
                .onAppear {
                    model = initializer()
                }
        }
    }
}
