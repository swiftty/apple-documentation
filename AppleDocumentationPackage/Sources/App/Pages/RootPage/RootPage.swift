import SwiftUI
import Router

public struct RootPage: View {
    @Environment(\.router) var router

    public init() {}

    public var body: some View {
        NavigationStack {
            router.route(for: .allTechnologiesPage)
        }
    }
}
