public import AppleDocumentation

extension Technology.Identifier: Decodable, CodingKeyRepresentable {}

extension Technology.Language: Decodable {
    public init(from decoder: any Decoder) throws {
        enum RawLanguage: String, RawRepresentable, Decodable {
            case occ, swift, data
        }

        self = switch try RawLanguage(from: decoder) {
        case .occ: .objectiveC
        case .swift: .swift
        case .data: .other
        }
    }
}

// MARK: - DiffAvailability

extension Technology.DiffAvailability: Decodable {
    public init(from decoder: any Decoder) throws {
        self.init(try [Key: Payload](from: decoder))
    }
}

extension Technology.DiffAvailability.Key: Decodable, CodingKeyRepresentable {}

extension Technology.DiffAvailability.Payload: Decodable {
    public init(from decoder: any Decoder) throws {
        struct Raw: Decodable {
            var change: String
            var platform: String
            var versions: Versions
        }

        let raw = try Raw(from: decoder)
        self.init(change: raw.change, platform: raw.platform, versions: raw.versions)
    }
}

extension Technology.DiffAvailability.Payload.Versions: Decodable {
    public init(from decoder: any Decoder) throws {
        var c = try decoder.unkeyedContainer()
        self.init(from: try c.decode(String.self), to: try c.decode(String.self))
    }
}

// MARK: - Changes

extension Technology.Changes: Decodable {
    public init(from decoder: any Decoder) throws {
        struct RawContent: Decodable {
            var change: Change?

            enum CodingKeys: CodingKey {
                case change
            }

            init(from decoder: any Decoder) throws {
                let c = try decoder.container(keyedBy: CodingKeys.self)
                change = try c.decodeIfPresent(Change.self, forKey: .change)
            }
        }

        self.init(
            try [Technology.Identifier: RawContent](from: decoder)
                .compactMapValues(\.change)
        )
    }
}
