import Foundation
import AppleDocumentation

func decodeTechnologyChanges(from data: Data) throws -> Technology.Changes {
    let result = try JSONDecoder().decode([Technology.Identifier: RawContent].self, from: data)
    return Technology.Changes(result.compactMapValues(\.change))
}

private struct RawContent: Decodable {
    var change: Technology.Changes.Change?

    enum CodingKeys: CodingKey {
        case change
    }

    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        do {
            change = try c.decodeIfPresent(Technology.Changes.Change.self, forKey: .change)
        } catch DecodingError.dataCorrupted {
            change = nil
        }
    }
}
