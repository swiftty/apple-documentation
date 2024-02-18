import Foundation
import SwiftUI
import Router
import AppleDocClient
import AppleDocClientLive
import RootPage
import SafariPage
import AllTechnologiesPage
import TechnologyDetailPage

public struct App: SwiftUI.App {
    #if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #elseif canImport(AppKit)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

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

#if canImport(UIKit)
private final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var appleDocClient = AppleDocClient.live(session: .shared)
}
#elseif canImport(AppKit)
private final class AppDelegate: NSResponder, NSApplicationDelegate {
    lazy var appleDocClient = AppleDocClient.live(session: .shared)
}
#endif

private struct RoutingProviderImpl: RoutingProvider {
    func route(for target: any Routing) -> some View {
        switch target {
        case is Routings.AllTechnologiesPage:
            AllTechnologiesPage()

        case let page as Routings.TechnologyDetailPage:
            TechnologyDetailPage(destination: page.destination)

        #if canImport(UIKit)
        case let page as Routings.SafariPage:
            SafariPage(url: page.url)
        #endif

        default:
            Text("unhandled route: \(String(describing: target))")
        }
    }
}
