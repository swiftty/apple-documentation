import SwiftUI
import AppleDocumentation
import AppleDocClient
import Router

public struct TechnologyDetailPage: View {
    @Environment(Router.self) var router
    @Environment(\.appleDocClient) var appleDocClient

    let destination: Technology.Destination.Value

    @State private var detail: TechnologyDetail?

    public init(destination: Technology.Destination.Value) {
        self.destination = destination
    }

    public var body: some View {
        if let detail {
            ScrollView {
                VStack {
                    TextView(detail.abstract)

                    ForEach(detail.primaryContents.flatMap(\.content), id: \.self) { block in
                        TextView(block)
                    }
                }
                .environment(\.references, detail.references)
            }
            .navigationTitle(detail.metadata.title)
            .environment(\.openDestination, OpenDestinationAction { identifier in
                router.navigationPath.append(identifier)
            })
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .task {
                    detail = try? await appleDocClient.technologyDetail(for: destination)
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

            case .unorderedList(let list):
                ForEach(list.items, id: \.self) { item in
                    HStack(alignment: .top) {
                        Text("・")
                        BlockContentView(blocks: item.content)
                    }
                }

            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    TechnologyDetailPage(
        destination: .init(rawValue: "")
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
