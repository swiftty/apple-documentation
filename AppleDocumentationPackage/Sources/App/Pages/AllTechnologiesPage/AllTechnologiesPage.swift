import SwiftUI
import AppleDocumentation
import AppleDocClient

public struct AllTechnologiesPage: View {
    @Environment(\.appleDocClient) var appleDocClient

    @State private var allTechnologies: [Technology] = []

    public init() {}

    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(allTechnologies, id: \.title) { tech in
                    Text(tech.title)
                }
            }
        }
        .navigationTitle("Technologies")
        .task {
            do {
                allTechnologies = try await appleDocClient.allTechnologies
            } catch {}
        }
    }
}
