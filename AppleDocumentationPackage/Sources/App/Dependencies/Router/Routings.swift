public import Foundation
public import AppleDocumentation

public enum Routings {}

extension Routings {
    public struct AllTechnologiesPage: Routing {}
}

extension Routing where Self == Routings.AllTechnologiesPage {
    public static var allTechnologiesPage: Self {
        Self.init()
    }
}

extension Routings {
    public struct TechnologyDetailPage: Routing {
        public var destination: Technology.Destination.Value
    }
}

extension Routing where Self == Routings.TechnologyDetailPage {
    public static func technologyDetail(for destination: Technology.Destination.Value) -> Self {
        Self.init(destination: destination)
    }
}

extension Routings {
    public struct SafariPage: Routing {
        public var url: URL
    }
}

extension Routing where Self == Routings.SafariPage {
    public static func safari(for url: URL) -> Self {
        Self.init(url: url)
    }
}
