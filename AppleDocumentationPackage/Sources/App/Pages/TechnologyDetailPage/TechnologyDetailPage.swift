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
            ScrollView {
                VStack {
                    InlineContentView(contents: detail.abstract)

                    ForEach(detail.primaryContents.map(\.content), id: \.self) { blocks in
                        BlockContentView(blocks: blocks)
                    }
                }
            }
            .navigationTitle(detail.metadata.title)
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .task {
                    detail = try? await appleDocClient.technologyDetail(for: destination.url)
                }
        }
    }
}

private struct BlockContentView: View {
    var blocks: [BlockContent]

    var body: some View {
        ForEach(blocks, id: \.self) { block in
            switch block {
            case .paragraph(let paragraph):
                InlineContentView(contents: paragraph.contents)

            case .heading(let heading):
                Text(heading.text)
                    .font(.title3.bold())

            default:
                EmptyView()
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
