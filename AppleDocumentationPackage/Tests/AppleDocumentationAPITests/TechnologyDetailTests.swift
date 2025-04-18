import Testing
import Foundation
import AppleDocumentation
@testable import AppleDocumentationAPI

struct TechnologyDetailTests {
    @Test
    func test_TechnologyDetail_CoreText() async throws {
        let url = try #require(URL(string: "https://developer.apple.com/tutorials/data/documentation/coretext.json"))
        let (data, _) = try await URLSession.shared.data(from: url)

        #expect(throws: Never.self) {
            try decodeTechnologyDetail(from: data)
        }
    }

    @Test
    func test_TechnologyDetail_CoreText_CTFont() async throws {
        let url = try #require(URL(string: "https://developer.apple.com/tutorials/data/documentation/coretext/ctfont.json"))
        let (data, _) = try await URLSession.shared.data(from: url)

        #expect(throws: Never.self) {
            try decodeTechnologyDetail(from: data)
        }
    }

    @Test
    func test_TechnologyDetail_AppStoreConnectAPI() async throws {
        let url = try #require(URL(string: "https://developer.apple.com/tutorials/data/documentation/appstoreconnectapi.json"))
        let (data, _) = try await URLSession.shared.data(from: url)

        #expect(throws: Never.self) {
            try decodeTechnologyDetail(from: data)
        }
    }
}
