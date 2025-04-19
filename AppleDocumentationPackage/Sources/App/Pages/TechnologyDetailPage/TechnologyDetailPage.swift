public import SwiftUI
public import AppleDocumentation
import AppleDocClient
import Router
import UIComponent

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

    let destination: Technology.Destination.Value

    public init(destination: Technology.Destination.Value) {
        self.destination = destination
    }

    public var body: some View {
        InObservation {
            TechnologyDetailModel(
                destination: destination,
                dependency: .init(
                    appleDocClient: appleDocClient
                )
            )
        } content: { model in
            _Body(destination: destination, model: model)
        }
        .id(destination)
    }

    private struct _Body: View {
        @Environment(\.openURL) var openURL
        let destination: Technology.Destination.Value
        let model: TechnologyDetailModel

        var body: some View {
            InUIStack {
                model.detail
            } loading: { isLoading in
                ProgressView()
                    .progressViewStyle(.circular)
                    .task {
                        if !isLoading {
                            await model.fetch()
                        }
                    }
            } loaded: { detail in
                detail.map(content(for:))
            } failed: { error in
                Text(String(describing: error))
            }
        }

        // swiftlint:disable:next function_body_length
        private func content(for detail: TechnologyDetail) -> some View {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    if let roleHeading = detail.metadata.roleHeading {
                        Text(roleHeading)
                            .font(.title3.bold())
                            .foregroundStyle(.secondary)
                            .padding(.bottom)
                    }

                    Text(detail.metadata.title)
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                        .padding(.bottom)
                        .padding(.bottom)

                    BlockTextView(detail.abstract)
                        .padding(.bottom)

                    platformsView(with: detail.metadata.platforms)

                    ForEach(detail.primaryContents.indexed()) { item in
                        primaryContentSection(with: item.element)
                    }

                    if case let topics = detail.topics, !topics.isEmpty {
                        Divider()
                            .padding(.vertical)

                        Text("Topics")
                            .font(.title2.bold())

                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(topics.indexed()) { topic in
                                topicView(with: topic.element)
                            }
                        }
                    }

                    if case let rels = detail.relationships, !rels.isEmpty {
                        Divider()
                            .padding(.vertical)

                        Text("Relationships")
                            .font(.title2.bold())

                        ForEach(rels.indexed()) { topic in
                            topicView(with: topic.element)
                        }
                    }
                }
                .environment(\.references, detail.references)
                .padding(.horizontal)
            }
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
        }

        @ViewBuilder
        private func platformsView(with platforms: [TechnologyDetail.Metadata.Platform]) -> some View {
            TagLayout {
                ForEach(platforms, id: \.name) { platform in
                    let text = if platform.beta {
                        Text("\(platform.name) \(platform.introducedAt)+")
                        + (Text(" Beta")
                            .foregroundStyle(.green))
                    } else {
                        Text("\(platform.name) \(platform.introducedAt)+")
                    }

                    text
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
        }

        @ViewBuilder
        private func primaryContentSection(with content: TechnologyDetail.PrimaryContent) -> some View {
            if case let declarations = content.declarations, !declarations.isEmpty {
                ForEach(declarations.indexed()) { item in
                    ScrollView(.horizontal, showsIndicators: false) {
                        FragmentTextView(fragments: item.element.tokens)
                            .fixedSize(horizontal: false, vertical: true)
                            .tint(.init(r: 218, g: 186, b: 255))
                    }
                    .contentMargins(16)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.tertiary)
                    }
                }
            }

            if case let parameters = content.parameters, !parameters.isEmpty {
                Text("Parameters")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                ForEach(parameters.indexed()) { item in
                    Text(item.element.name)
                        .font(.body.bold())
                        .foregroundStyle(.primary)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(item.element.content.indexed()) { item in
                            BlockTextView(item.element)
                        }
                    }
                }
            }

            if case let blocks = content.content, !blocks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(blocks.indexed()) { item in
                        BlockTextView(item.element)
                    }
                }
            }
        }

        @ViewBuilder
        private func topicView(with topic: TechnologyDetail.Topic) -> some View {
            VStack(alignment: .leading) {
                switch topic {
                case .taskGroup(let group):
                    Text(group.title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .headingLevel(3)

                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(group.identifiers, id: \.self) { identifier in
                            model.detail.wrappedValue?.references[identifier].map { ref in
                                ReferenceView(reference: ref)
                            }
                        }
                    }

                case .relationships(let rel):
                    Text(rel.title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .headingLevel(3)

                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(rel.identifiers, id: \.self) { identifier in
                            model.detail.wrappedValue?.references[identifier].map { ref in
                                ReferenceView(reference: ref, descriptionOnly: true)
                            }
                        }
                    }

                case .document(let doc):
                    Text(doc.title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .headingLevel(3)

                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(doc.identifiers, id: \.self) { identifier in
                            model.detail.wrappedValue?.references[identifier].map { ref in
                                ReferenceView(reference: ref)
                            }
                        }
                    }
                }
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
                .data(name: "uikit")
            return try TechnologyDetail.from(json: data)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview {
    TechnologyDetailPage(
        destination: .init(rawValue: "")
    )
    .transformEnvironment(\.appleDocClient) { client in
        client.props.technologyDetail = { _ in
            let data = DevelopmentResources
                .data(name: "view-fundamentals")
            return try TechnologyDetail.from(json: data)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview {
    TechnologyDetailPage(
        destination: .init(rawValue: "")
    )
    .transformEnvironment(\.appleDocClient) { client in
        client.props.technologyDetail = { _ in
            let data = DevelopmentResources
                .data(name: "developing-a-widgetkit-strategy")
            return try TechnologyDetail.from(json: data)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview {
    TechnologyDetailPage(
        destination: .init(rawValue: "")
    )
    .transformEnvironment(\.appleDocClient) { client in
        client.props.technologyDetail = { _ in
            let data = DevelopmentResources
                .data(name: "view")
            return try TechnologyDetail.from(json: data)
        }
    }
    .preferredColorScheme(.dark)
}

#endif
