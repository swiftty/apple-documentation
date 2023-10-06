import SwiftUI
import AppleDocumentation
import AppleDocClient
import Router

struct IndexedItem<Element: Hashable>: Identifiable, Hashable {
    var id: some Hashable { self }

    var index: Int
    var element: Element
}

extension Array where Element: Hashable {
    func indexed() -> [IndexedItem<Element>] {
        enumerated().map(IndexedItem.init)
    }
}

public struct TechnologyDetailPage: View {
    @Environment(\.appleDocClient) var appleDocClient
    @Environment(\.openURL) var openURL

    let destination: Technology.Destination.Value

    @State private var detail: TechnologyDetail?

    public init(destination: Technology.Destination.Value) {
        self.destination = destination
    }

    public var body: some View {
        if let detail {
            ScrollView {
                LazyVStack {
                    if let roleHeading = detail.metadata.roleHeading {
                        Text(roleHeading)
                            .font(.title3.bold())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Text(detail.metadata.title)
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    BlockTextView(detail.abstract)

                    TagLayout {
                        ForEach(detail.metadata.platforms, id: \.name) { platform in
                            Text("\(platform.name) \(platform.introducedAt)+")
                                .font(.callout)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule()
                                        .stroke()
                                }
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(detail.primaryContents.indexed()) { item in
                        primaryContentSection(with: item.element)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .environment(\.references, detail.references)
                .padding(.horizontal)
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        guard let url = URL(string: "https://developer.apple.com\(destination.rawValue)") else {
                            return
                        }
                        openURL(url)
                    } label: {
                        Label("safari", systemImage: "safari")
                    }
                }
            }
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

    @ViewBuilder
    private func primaryContentSection(with content: TechnologyDetail.PrimaryContent) -> some View {
        if case let declarations = content.declarations, !declarations.isEmpty {
            ForEach(declarations.indexed()) { item in
                FragmentTextView(fragments: item.element.tokens)
            }
        }

        if case let parameters = content.parameters, !parameters.isEmpty {
            Text("Parameters")
                .font(.title2.bold())

            ForEach(parameters.indexed()) { item in
                Text(item.element.name)
                    .font(.body.bold())

                ForEach(item.element.content.indexed()) { item in
                    BlockTextView(item.element)
                }
            }
        }

        if case let blocks = content.content, !blocks.isEmpty {
            ForEach(blocks.indexed()) { item in
                BlockTextView(item.element)
            }
        }
    }
}

#if canImport(DevelopmentAssets)
import DevelopmentAssets

#Preview {
    TechnologyDetailPage(
        destination: .init(rawValue: "")
    )
    .transformEnvironment(\.appleDocClient) { client in
        client.props.technologyDetail = { _ in
            let data = DevelopmentResources
                .data(name: "cloudkit--ckdatabase--3794311-configuredwith")
            return try TechnologyDetail.from(json: data)
        }
    }
}

#endif
