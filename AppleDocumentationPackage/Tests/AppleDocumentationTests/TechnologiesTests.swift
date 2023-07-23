import XCTest
import Foundation
@testable import AppleDocumentation

final class TechnologiesTests: XCTestCase {
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

        let diff = try JSONDecoder().decode(Technologies.DiffAvailability.self, from: json)
        XCTAssertEqual(diff.count, 3)
        XCTAssertEqual(diff.sorted().map(\.key), [.beta, .minor, .major])

        XCTAssertNotNil(diff[.beta])
        XCTAssertNotNil(diff[.minor])
        XCTAssertNotNil(diff[.major])
    }

    func test_Technologies() async throws {
        let url = try XCTUnwrap(URL(string: "https://developer.apple.com/tutorials/data/documentation/technologies.json"))
        let (data, _) = try await URLSession.shared.data(from: url)

        let technologies = try JSONDecoder().decode(Technologies.self, from: data)

        XCTAssertEqual(technologies.technologies.isEmpty, false)
    }

    func test_Technologies_changes() async throws {
        let url = try XCTUnwrap(URL(string: "https://developer.apple.com/tutorials/data/diffs/documentation/technologies.json?changes=latest_minor"))
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let changes = try JSONDecoder().decode(Technologies.Changes.self, from: data)
        
        XCTAssertGreaterThanOrEqual(changes.count, 0)
    }
}
