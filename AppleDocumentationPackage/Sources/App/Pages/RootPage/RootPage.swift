public import SwiftUI
import Router
import AppleDocumentation
import UIComponent

public struct RootPage: View {
    @Environment(Router.self) var router

    @State private var modalContext: ModalContext?

    public init() {}

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.navigationPath) {
            router.route(for: .allTechnologiesPage)
                .navigationDestination(for: Routings.TechnologyDetailPage.self) { page in
                    router.route(for: page)
                }
        }
        #if canImport(UIKit)
        .fullScreenCover(item: $modalContext) { _ in }
        #endif
        .extractDestination()
        .environment(\.openDestination, OpenDestinationAction { identifier in
            router.navigationPath.append(.technologyDetail(for: identifier))
        })
    }
}

private enum ModalContext: Hashable, Identifiable {
    var id: some Hashable { self }
}
