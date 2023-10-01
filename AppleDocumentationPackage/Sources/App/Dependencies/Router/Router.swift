import SwiftUI

public protocol Routing: Hashable {}

public protocol RoutingProvider {
    associatedtype ResultView: View

    @MainActor
    @ViewBuilder
    func route(for target: any Routing) -> ResultView
}

@Observable
@MainActor
public class Router {
    public var navigationPath = NavigationPath()

    let router: @MainActor (any Routing) -> AnyView

    init(router: @escaping (any Routing) -> AnyView) {
        self.router = router
    }

    public func route(for target: some Routing) -> some View {
        router(target)
    }
}

extension Router {
    public convenience init(provider: some RoutingProvider) {
        let route = provider.route(for:)
        self.init(router: { target in
            AnyView(route(target))
        })
    }
}
