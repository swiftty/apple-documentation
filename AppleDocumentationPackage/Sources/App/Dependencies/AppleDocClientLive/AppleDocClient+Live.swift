import SwiftUI
import AppleDocClient
import AppleDocumentation
import AppleDocumentationAPI

extension AppleDocClient {
    public static func live(session: URLSession) -> Self {
        let data = DataContainer(session: session)

        return Self.init(
            allTechnologies: {
                try await data.fetchTechnologies().technologies
            },
            diffAvailability: {
                try await data.fetchTechnologies().diffAvailability
            },
            technologyDetail: { path in
                try await data.fetchTechnologyDetail(for: path)
            },
            technologyDetailIndex: { path in
                try await data.fetchTechnologyDetailIndex(for: path)
            }
        )
    }
}

private actor DataContainer {
    let session: URLSession

    private typealias Top = (
        technologies: [Technology],
        diffAvailability: Technology.DiffAvailability
    )
    private let tops = SerialExecutor<String, ([Technology], Technology.DiffAvailability)>()
    private var topCache: Top?

    private let details = SerialExecutor<String, TechnologyDetail>()
    private var detailsCache: [String: TechnologyDetail] = [:]

    private let indexes = SerialExecutor<String, [TechnologyDetailIndex]>()
    private var indexesCache: [String: [TechnologyDetailIndex]] = [:]

    init(session: URLSession) {
        self.session = session
    }

    func fetchTechnologies() async throws -> (
        technologies: [Technology],
        diffAvailability: Technology.DiffAvailability
    ) {
        if let top = top() {
            return top
        }
        print("fetch started...")

        let url = URL(string: "https://developer.apple.com/tutorials/data/documentation/technologies.json")!
        do {
            let (data, _) = try await session.data(from: url)
            let value = try decodeTechnologies(from: data)
            top(value)
            print("fetch finished.")
            return value
        } catch {
            print("fetch failed.", error)
            throw error
        }
    }

    private func top() -> Top? {
        topCache
    }

    private func top(_ value: Top) {
        topCache = value
    }

    func fetchTechnologyDetail(for path: String) async throws -> TechnologyDetail {
        try await details.execute(for: path) {
            if let cache = detail(for: path) {
                return cache
            }
            print("fetch detail[\(path)] started...")

            let url = URL(string: "https://developer.apple.com/tutorials/data\(path).json")!
            do {
                let (data, _) = try await session.data(from: url)
                let value = try decodeTechnologyDetail(from: data)
                detail(value, for: path)
                print("fetch detail[\(path)] finished.")
                return value
            } catch {
                print("fetch detail[\(path)] failed.", url, error)
                throw error
            }
        }
    }

    private func detail(for path: String) -> TechnologyDetail? {
        detailsCache[path]
    }

    private func detail(_ value: TechnologyDetail, for path: String) {
        detailsCache[path] = value
    }

    func fetchTechnologyDetailIndex(for path: String) async throws -> [TechnologyDetailIndex] {
        precondition(path.hasPrefix("/documentation"))
        let paths = path.split(separator: "/")
        if !paths.indices.contains(1) {
            throw AppleDocClient.Error.notFound(path)
        }
        let path = String(paths[1])

        return try await indexes.execute(for: path) {
            if let cache = index(for: path) {
                return cache
            }
            print("fetch index[\(path)] started...")

            let url = URL(string: "https://developer.apple.com/tutorials/data/index/\(path)")!
            do {
                let (data, _) = try await session.data(from: url)
                let value = try decodeTechnologyDetailIndex(from: data)
                index(value, for: path)
                print("fetch index[\(path)] finished.")
                return value
            } catch {
                print("fetch index[\(path)] failed.", url, error)
                throw error
            }
        }
    }

    private func index(for path: String) -> [TechnologyDetailIndex]? {
        indexesCache[path]
    }

    private func index(_ value: [TechnologyDetailIndex], for path: String) {
        indexesCache[path] = value
    }
}
