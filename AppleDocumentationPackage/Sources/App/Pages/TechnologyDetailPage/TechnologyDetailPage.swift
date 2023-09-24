import SwiftUI
import AppleDocumentation
import AppleDocClient

public struct TechnologyDetailPage: View {
    @Environment(\.appleDocClient) var appleDocClient

    let destination: Technology.Destination

    @State private var detail: TechnologyDetail?

    public init(destination: Technology.Destination) {
        self.destination = destination
    }

    public var body: some View {
        if let detail {
            VStack {
                Text(detail.metadata.title)

                ForEach(detail.abstract, id: \.self) { content in
                    content
                }

                Spacer()
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .task {
                    detail = try? await appleDocClient.technologyDetail(for: destination.url)
                }
        }
    }
}

#Preview {
    TechnologyDetailPage(
        destination: .init(
            identifier: .init(rawValue: ""),
            title: "",
            url: "",
            abstract: ""
        )
    )
    .transformEnvironment(\.appleDocClient) { client in
        client.props.technologyDetail = { _ in
            TechnologyDetail(
                metadata: .init(
                    title: "title",
                    role: "",
                    roleHeading: "",
                    platforms: [],
                    externalID: nil
                ),
                abstract: [],
                primaryContents: [],
                topics: [],
                seeAlso: [],
                references: [:],
                diffAvailability: .init([:])
            )
        }
    }
}
