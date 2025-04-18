import Testing
import Foundation
import AppleDocumentation
@testable import AppleDocumentationAPI

struct TechnologyTests {
    @Test
    func test_DiffAvailability() throws {
        let json = """
        {
            "minor": {
                "change": "modified",
                "platform": "Xcode",
                "versions": [
                    "14.3",
                    "15.0 beta 3"
                ]
            },
            "major": {
                "change": "modified",
                "platform": "Xcode",
                "versions": [
                    "14.0",
                    "15.0 beta 3"
                ]
            },
            "beta": {
                "change": "modified",
                "platform": "Xcode",
                "versions": [
                    "15.0 beta 2",
                    "15.0 beta 3"
                ]
            }
        }
        """.data(using: .utf8) ?? Data()

        typealias DiffAvailability = Technology.DiffAvailability
        let data = try JSONDecoder().decode([DiffAvailability.Key: DiffAvailability.Payload].self, from: json)
        let diff = DiffAvailability(data)
        #expect(diff.count == 3)
        #expect(diff.sorted().map(\.key) == [.beta, .minor, .major])

        #expect(diff[.beta] != nil)
        #expect(diff[.minor] != nil)
        #expect(diff[.major] != nil)
    }

    @Test
    func test_Technologies() async throws {
        let url = try #require(URL(string: "https://developer.apple.com/tutorials/data/documentation/technologies.json"))
        let (data, _) = try await URLSession.shared.data(from: url)

        let (technologies, diff) = try decodeTechnologies(from: data)

        #expect(technologies.count >= 0)
        #expect(diff.count >= 0)
    }

    @Test
    func test_Technologies_changes() async throws {
        let url = try #require(URL(string: "https://developer.apple.com/tutorials/data/diffs/documentation/technologies.json?changes=latest_minor"))
        let (data, _) = try await URLSession.shared.data(from: url)

        let changes = try decodeTechnologyChanges(from: data)

        #expect(changes.count >= 0)
    }
}
