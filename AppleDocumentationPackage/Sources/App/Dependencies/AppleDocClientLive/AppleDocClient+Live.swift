public import SwiftUI
public import AppleDocClient
import AppleDocumentation
import AppleDocumentationAPI

extension AppleDocClient {
    public static func live(session: URLSession) -> Self {
        let data = DataContainer(session: session)

        return Self.init(
            allTechnologies: {
                try await data.fetchTechnologiesIfNeeded()
                return await data.technologies ?? []
            },
            diffAvailability: {
                try await data.fetchTechnologiesIfNeeded()
                return await data.diffAvailablity ?? .init([:])
            },
            technologyDetail: { path in
                try await data.fetchTechnologyDetail(for: path)
                guard let detail = await data.details[path] else { throw Error.notFound(path) }
                return detail
            }
        )
    }
}

private actor DataContainer {
    let session: URLSession

    var technologies: [Technology]?
    var diffAvailablity: Technology.DiffAvailability?

    var details: [String: TechnologyDetail] = [:]

    init(session: URLSession) {
        self.session = session
    }

    func fetchTechnologiesIfNeeded(force: Bool = false) async throws {
        guard force || technologies == nil || diffAvailablity == nil else { return }

        print("fetch started...")

        let url = URL(string: "https://developer.apple.com/tutorials/data/documentation/technologies.json")!
        do {
            let (data, _) = try await session.data(from: url)
            (technologies, diffAvailablity) = try decodeTechnologies(from: data)
        } catch {
            print("fetch failed.", error)
            throw error
        }
        print("fetch finished.")
    }

    func fetchTechnologyDetail(for path: String) async throws {
        guard details[path] == nil else { return }

        print("fetch detail[\(path)] started...")

        let url = URL(string: "https://developer.apple.com/tutorials/data/\(path).json")!
        do {
            let (data, _) = try await session.data(from: url)
            details[path] = try decodeTechnologyDetail(from: data)
        } catch {
            print("fetch detail[\(path)] failed.", url, error)
            throw error
        }
        print("fetch detail[\(path)] finished.")
    }
}
