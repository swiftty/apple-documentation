import SwiftUI
import Router
import AppleDocumentation

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
                .navigationDestination(for: Routings.SafariPage.self) { page in
                    router.route(for: page)
                }
        }
        .fullScreenCover(item: $modalContext) { context in
            switch context {
            case .safariPage(let url):
                router.route(for: .safari(for: url))
            }
        }
        .environment(\.openURL, OpenURLAction { url in
            modalContext = .safariPage(url)
            return .handled
        })
    }
}

private enum ModalContext: Hashable, Identifiable {
    case safariPage(URL)

    var id: some Hashable { self }
}
