import SwiftUI
import AppleDocumentation
import SupportMacros

public struct AppleDocClient {
    package struct Props {
        package var allTechnologies: () async throws -> [Technology]
        package var diffAvailability: () async throws -> Technology.DiffAvailability

        package var technologyDetail: (String) async throws -> TechnologyDetail
    }

    package var props: Props

    public init(
        allTechnologies: @escaping () async throws -> [Technology],
        diffAvailability: @escaping () async throws -> Technology.DiffAvailability,
        technologyDetail: @escaping (String) async throws -> TechnologyDetail
    ) {
        props = Props(
            allTechnologies: allTechnologies,
            diffAvailability: diffAvailability,
            technologyDetail: technologyDetail
        )
    }

    public enum Error: Swift.Error {
        case notFound(any Hashable, payload: [String: Any]? = nil)
    }

    public var allTechnologies: [Technology] {
        get async throws {
            try await props.allTechnologies()
        }
    }

    public var diffAvailability: Technology.DiffAvailability {
        get async throws {
            try await props.diffAvailability()
        }
    }

    public func technologyDetail(for path: Technology.Destination.Value) async throws -> TechnologyDetail {
        try await props.technologyDetail(path.rawValue)
    }
}

extension EnvironmentValues {
    @SwiftUIEnvironment
    public var appleDocClient: AppleDocClient = AppleDocClient(
        allTechnologies: { fatalError() },
        diffAvailability: { fatalError() },
        technologyDetail: { _ in fatalError() }
    )
}
