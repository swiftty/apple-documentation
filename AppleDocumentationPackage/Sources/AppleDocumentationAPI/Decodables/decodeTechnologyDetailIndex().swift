import Foundation
import AppleDocumentation

public func decodeTechnologyDetailIndex(from data: Data) throws -> [TechnologyDetailIndex] {
    let result = try JSONDecoder().decode(Result.self, from: data)
    return result.interfaceLanguages["swift"]?.map(\.technologyDetailIndex) ?? []
}

private struct Result: Decodable {
    var interfaceLanguages: [String: [RawIndex]]
}

private struct RawIndex: Decodable {
    var title: String
    var path: String?
    var type: String
    var external: Bool?
    var deprecated: Bool?
    var children: [RawIndex]?

    var technologyDetailIndex: TechnologyDetailIndex {
        let kind: TechnologyDetailIndex.Kind = switch type {
        case "module": .module
        case "groupMarker": .groupMarker
        case "protocol": .`protocol`
        case "class": .`class`
        case "struct": .`struct`
        case "enum": .`enum`
        case "collection": .collection
        case "property": .property
        case "method": .method
        case "init": .`init`
        case "func": .`func`
        case "case": .`case`
        default: .unknown(type)
        }

        return .init(
            title: title,
            path: path,
            external: external ?? false,
            deprecated: deprecated ?? false,
            kind: kind,
            children: children?.map(\.technologyDetailIndex) ?? []
        )
    }
}
