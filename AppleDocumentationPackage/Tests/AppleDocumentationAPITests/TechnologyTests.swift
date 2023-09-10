// swiftlint:disable line_length
import XCTest
import Foundation
import AppleDocumentation
@testable import AppleDocumentationAPI

final class TechnologyTests: XCTestCase {
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
        XCTAssertEqual(diff.count, 3)
        XCTAssertEqual(diff.sorted().map(\.key), [.beta, .minor, .major])

        XCTAssertNotNil(diff[.beta])
        XCTAssertNotNil(diff[.minor])
        XCTAssertNotNil(diff[.major])
    }

    func test_Technologies() async throws {
        let url = try XCTUnwrap(URL(string: "https://developer.apple.com/tutorials/data/documentation/technologies.json"))
        let (data, _) = try await URLSession.shared.data(from: url)

        let (technologies, diff) = try decodeTechnologies(from: data)

        XCTAssertGreaterThanOrEqual(technologies.count, 0)
        XCTAssertGreaterThanOrEqual(diff.count, 0)
    }

    func test_Technologies_changes() async throws {
        let url = try XCTUnwrap(URL(string: "https://developer.apple.com/tutorials/data/diffs/documentation/technologies.json?changes=latest_minor"))
        let (data, _) = try await URLSession.shared.data(from: url)

        let changes = try decodeTechnologyChanges(from: data)

        XCTAssertGreaterThanOrEqual(changes.count, 0)
    }
}

// swiftlint:enable line_length
