import SwiftUI
import AppleDocumentation
import AppleDocClient

public struct AllTechnologiesPage: View {
    @Environment(\.appleDocClient) var appleDocClient

    @State private var allTechnologies: [Technology]?
    @State private var filterText = ""

    private var technologies: [Technology] {
        if filterText.isEmpty {
            allTechnologies ?? []
        } else {
            allTechnologies?
                .filter { $0.title.contains(filterText) }
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
            if technologies.isEmpty {
                emptyContent()
            }
        }
        .searchable(
            text: $filterText.animation(),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Filter on this page")
        )
        .navigationTitle("Technologies")
        .task {
            do {
                allTechnologies = try await appleDocClient.allTechnologies
            } catch {}
        }
    }

    private func listContent() -> some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(technologies, id: \.title) { tech in
                    NavigationLink(value: tech.destination) {
                        TechnologyCell(
                            title: tech.title,
                            abstract: tech.destination.abstract
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
}

// swiftlint:disable line_length
#Preview {
    NavigationStack {
        AllTechnologiesPage()
            .environment(
                \.appleDocClient,
                 AppleDocClient(
                    allTechnologies: {
                        [
                            .init(
                                title: "Accelerate",
                                languages: [.swift],
                                tags: ["UI"],
                                destination: .init(
                                    identifier: .init(rawValue: "swiftui"),
                                    title: "swiftui",
                                    url: "",
                                    abstract: """
                                    Make large-scale mathematical computations and image calculations, optimized for high performance and low energy consumption.
                                    """
                                )
                            )
                        ]
                    }
                 )
            )
    }
}
// swiftlint:enable line_length
