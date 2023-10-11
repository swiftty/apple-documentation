import Foundation
import SwiftUI
import Router
import AppleDocClient
import AppleDocClientLive
import RootPage
import SafariPage
import AllTechnologiesPage
import TechnologyDetailIndexPage
import TechnologyDetailPage

public struct App: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @State var router = Router(provider: RoutingProviderImpl())

    public init() {}

    public var body: some Scene {
        WindowGroup {
            RootPage()
                .preferredColorScheme(.dark)
                .environment(router)
                .environment(\.appleDocClient, appDelegate.appleDocClient)
        }
    }
}

private final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var appleDocClient = AppleDocClient.live(session: .shared)
}

private struct RoutingProviderImpl: RoutingProvider {
    func route(for target: any Routing) -> some View {
        switch target {
        case is Routings.AllTechnologiesPage:
            AllTechnologiesPage()

        case let page as Routings.TechnologyDetailIndexPage:
            TechnologyDetailIndexPage(destination: page.destination)

        case let page as Routings.TechnologyDetailPage:
            TechnologyDetailPage(destination: page.destination)

        case let page as Routings.SafariPage:
            SafariPage(url: page.url)

        default:
            Text("unhandled route: \(String(describing: target))")
        }
    }
}
