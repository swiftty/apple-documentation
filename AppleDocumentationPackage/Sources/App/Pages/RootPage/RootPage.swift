import SwiftUI
import Router
import AppleDocumentation

public struct RootPage: View {
    @Environment(Router.self) var router

    public init() {}

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.navigationPath) {
            router.route(for: .allTechnologiesPage)
                .navigationDestination(for: Technology.Destination.Value.self) { destination in
                    router.route(for: .technologyDetail(for: destination))
                }
        }
    }
}
