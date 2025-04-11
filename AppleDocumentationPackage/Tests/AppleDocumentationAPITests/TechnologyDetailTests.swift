// swiftlint:disable line_length
import XCTest
import Foundation
import AppleDocumentation
@testable import AppleDocumentationAPI

final class TechnologyDetailTests: XCTestCase {
    func test_TechnologyDetail_CoreText() async throws {
        let url = try XCTUnwrap(URL(string: "https://developer.apple.com/tutorials/data/documentation/coretext.json"))
        let (data, _) = try await URLSession.shared.data(from: url)

        XCTAssertNoThrow(try decodeTechnologyDetail(from: data))
    }

    func test_TechnologyDetail_CoreText_CTFont() async throws {
        let url = try XCTUnwrap(URL(string: "https://developer.apple.com/tutorials/data/documentation/coretext/ctfont.json"))
        let (data, _) = try await URLSession.shared.data(from: url)

        XCTAssertNoThrow(try decodeTechnologyDetail(from: data))
    }

    func test_TechnologyDetail_AppStoreConnectAPI() async throws {
        let url = try XCTUnwrap(URL(string: "https://developer.apple.com/tutorials/data/documentation/appstoreconnectapi.json"))
        let (data, _) = try await URLSession.shared.data(from: url)

        XCTAssertNoThrow(try decodeTechnologyDetail(from: data))
    }
}

// swiftlint:enable line_length
