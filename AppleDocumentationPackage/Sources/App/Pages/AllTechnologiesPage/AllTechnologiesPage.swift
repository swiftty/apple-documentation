public import SwiftUI
import Router
import AppleDocumentation
import AppleDocClient

public struct AllTechnologiesPage: View {
    @Environment(Router.self) var router
    @Environment(\.appleDocClient) var appleDocClient

    @State private var allTechnologies: [Technology]?
    @State private var diffAvailability: Technology.DiffAvailability?
    @State private var filterText = ""

    private var technologies: [Technology] {
        if filterText.isEmpty {
            return allTechnologies ?? []
        } else {
            let filterText = filterText.lowercased()
            return allTechnologies?
                .filter { $0.title.lowercased().contains(filterText) }
            ?? []
        }
    }

    private var isLoading: Bool {
        allTechnologies == nil
    }

    public init() {}

    public var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                listContent()
            }
        }
        .overlay {
            if !isLoading && technologies.isEmpty {
                emptyContent()
            }
        }
        #if canImport(UIKit)
        .searchable(
            text: $filterText.animation(),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Filter on this page")
        )
        #endif
        .toolbar {
            let isEmpty = diffAvailability?.isEmpty ?? true
            if !isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        diffContent()
                    } label: {
                        Label(
                            "Show API Changes",
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                    }
                }
            }
        }
        .navigationTitle("Technologies")
        .task {
            do {
                (allTechnologies, diffAvailability) = try await (
                    appleDocClient.allTechnologies,
                    appleDocClient.diffAvailability
                )
            } catch {}
        }
    }

    private func listContent() -> some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(technologies, id: \.title) { tech in
                    NavigationLink(for: .technologyDetail(for: tech.destination.value)) {
                        TechnologyCell(
                            title: tech.title,
                            abstract: tech.destination.abstract,
                            tags: tech.tags
                        )
                    }
                    .buttonStyle(TechnologyCell.ButtonStyle())
                    .padding(.horizontal)
                    .padding(.top)
                }
            } header: {
                if !technologies.isEmpty {
                    Text("Showing \(technologies.count) results")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.thinMaterial, in: Capsule())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .padding(.top, 4)
                }
            }
        }
    }

    private func emptyContent() -> some View {
        ContentUnavailableView {
            VStack(alignment: .leading, spacing: 16) {
                Text("No results found")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .padding(.top)

                Text("No results found Try changing or removing text.")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                .secondary,
                                style: StrokeStyle(
                                    lineWidth: 1,
                                    dash: [8, 4]
                                )
                            )
                    }

                Spacer()
            }
        }
        .padding(-16)
    }

    @ViewBuilder
    private func diffContent() -> some View {
        Button {

        } label: {
            Text("Current APIs")
        }

        if let beta = diffAvailability?[.beta] {
            Button {

            } label: {
                Text(beta.title)
            }
        }

        if let minor = diffAvailability?[.minor] {
            Button {

            } label: {
                Text(minor.title)
            }
        }

        if let major = diffAvailability?[.major] {
            Button {

            } label: {
                Text(major.title)
            }
        }
    }
}

extension Technology.DiffAvailability.Payload {
    var title: String {
        "\(versions.from) - \(versions.to)"
    }
}

// swiftlint:disable line_length
#Preview {
    NavigationStack {
        AllTechnologiesPage()
            .environment(Router.empty())
            .transformEnvironment(\.appleDocClient) { client in
                client.props.allTechnologies = {
                    [
                        .init(
                            title: "Accelerate",
                            languages: [.swift],
                            tags: ["UI"],
                            destination: .init(
                                identifier: .init(rawValue: "swiftui"),
                                title: "swiftui",
                                value: .init(rawValue: ""),
                                abstract: """
                                    Make large-scale mathematical computations and image calculations, optimized for high performance and low energy consumption.
                                    """
                            )
                        )
                    ]
                }
                client.props.diffAvailability = {
                    .init([:])
                }
            }
    }
}
// swiftlint:enable line_length
