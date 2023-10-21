import SwiftUI
import AppleDocumentation
import AppleDocClient
import UIComponent

public struct TechnologyDetailIndexPage: View {
    @Environment(\.appleDocClient) var appleDocClient

    let destination: Technology.Destination.Value

    @State private var index: [TechnologyDetailIndex]?

    public init(destination: Technology.Destination.Value) {
        self.destination = destination
    }

    public var body: some View {
        if let index {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(index.indexed()) { item in
                        IndexContent(index: item.element)
                    }
                }
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .task {
                    do {
                        index = try await appleDocClient.technologyDetailIndex(for: destination)
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

private struct IndexContent: View {
    let index: TechnologyDetailIndex

    var body: some View {
        mainContent()

        ForEach(index.children.indexed()) { item in
            IndexContent(index: item.element)
        }
    }

    @ViewBuilder
    private func mainContent() -> some View {
        switch index.kind {
        case .module:
            Text(index.title)

        case .groupMarker:
            Text(index.title)

        case .protocol:
            Text(index.title)

        case .class:
            Text(index.title)

        case .struct:
            Text(index.title)

        case .enum:
            Text(index.title)

        case .collection:
            Text(index.title)

        case .property:
            Text(index.title)

        case .method:
            Text(index.title)

        case .`init`:
            Text(index.title)

        case .func:
            Text(index.title)

        case .case:
            Text(index.title)

        case .unknown(let string):
            Text("unhandled type: \(string)")
                .foregroundStyle(.red)
        }
    }
}

#if canImport(DevelopmentAssets)
import DevelopmentAssets

#Preview {
    TechnologyDetailIndexPage(
        destination: .init(rawValue: "")
    )
    .transformEnvironment(\.appleDocClient) { client in
        client.props.technologyDetail = { _ in
            let data = DevelopmentResources
                .data(name: "uikit")
            return try TechnologyDetail.from(json: data)
        }
    }
    .preferredColorScheme(.dark)
}

#endif
