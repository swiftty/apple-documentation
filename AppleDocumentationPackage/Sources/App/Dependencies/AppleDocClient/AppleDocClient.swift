public import SwiftUI
public import AppleDocumentation
import SupportMacros

public struct AppleDocClient: Sendable {
    package struct Props: Sendable {
        package var allTechnologies: @Sendable () async throws -> [Technology]
        package var diffAvailability: @Sendable () async throws -> Technology.DiffAvailability

        package var technologyDetail: @Sendable (String) async throws -> TechnologyDetail
    }

    package var props: Props

    public init(
        allTechnologies: @escaping @Sendable () async throws -> [Technology],
        diffAvailability: @escaping @Sendable () async throws -> Technology.DiffAvailability,
        technologyDetail: @escaping @Sendable (String) async throws -> TechnologyDetail
    ) {
        props = Props(
            allTechnologies: allTechnologies,
            diffAvailability: diffAvailability,
            technologyDetail: technologyDetail
        )
    }

    public enum Error: Swift.Error {
        case notFound(any Hashable & Sendable, payload: [String: any Sendable]? = nil)
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
    @Entry
    public var appleDocClient: AppleDocClient = AppleDocClient(
        allTechnologies: { fatalError() },
        diffAvailability: { fatalError() },
        technologyDetail: { _ in fatalError() }
    )
}
