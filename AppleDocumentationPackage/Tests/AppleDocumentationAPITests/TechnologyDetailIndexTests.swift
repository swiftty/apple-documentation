import XCTest
import Foundation
import AppleDocumentation
@testable import AppleDocumentationAPI

final class TechnologyDetailIndexTests: XCTestCase {
    func test_TechnologyDetailIndex_AppKit() async throws {
        let url = try XCTUnwrap(URL(string: "https://developer.apple.com/tutorials/data/index/appkit"))
        let (data, _) = try await URLSession.shared.data(from: url)

        XCTAssertNoThrow(try decodeTechnologyDetailIndex(from: data))
    }
}
