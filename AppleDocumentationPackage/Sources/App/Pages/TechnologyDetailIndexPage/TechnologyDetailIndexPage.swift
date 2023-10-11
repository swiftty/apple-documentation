import SwiftUI
import AppleDocumentation
import AppleDocClient

public struct TechnologyDetailIndexPage: View {
    @Environment(\.appleDocClient) var appleDocClient

    let destination: Technology.Destination.Value

    @State private var detail: TechnologyDetail?

    public init(destination: Technology.Destination.Value) {
        self.destination = destination
    }

    public var body: some View {
        if let detail {
            Text(detail.metadata.title)
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .task {
                    do {
                        detail = try await appleDocClient.technologyDetail(for: destination)
                    } catch {
                        print(error)
                    }
                }
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
