public import SwiftUI
public import AppleDocumentation
import SupportMacros

@ImplicitInit
public struct AttributedText: Hashable {
    public var string: String
    public var attributes: Attributes

    @ImplicitInit
    public struct Attributes: Hashable {
        public var font: Font = .body
        public var bold: Bool = false
        public var italic: Bool = false
        public var monospaced: Bool = false
        public var foregroundColor: Color?

        public var link: URL?

        @discardableResult
        public mutating func link(using ref: TechnologyDetail.Reference?) -> Bool {
            link = encodeToURL(ref?.url, key: "identifier")
            return link != nil
        }
    }

    fileprivate func render() -> Text {
        let text = if let link = attributes.link {
            Text(.init("[\(string)](\(link.absoluteString))"))
        } else {
            Text(verbatim: string)
        }

        return text
            .font(attributes.font)
            .bold(attributes.bold)
            .italic(attributes.italic)
            .monospaced(attributes.monospaced)
            .foregroundStyle(attributes.foregroundColor ?? .primary)
    }
}

extension Text {
    public init(_ attributedText: AttributedText) {
        self = attributedText.render()
    }

    public init(next: ((AttributedText) -> Void) -> Void) {
        var text = Text("")
        next { attributedText in
            // swiftlint:disable:next shorthand_operator
            text = text + Text(attributedText)
        }
        self = text
    }
}

// MARK: - identifier
func encodeToURL(_ target: String?, key: String) -> URL? {
    guard let target else { return nil }

    var comps = URLComponents(string: "appledoc://")
    comps?.queryItems = [
        .init(name: key, value: target)
    ]
    return comps?.url
}

func decodeFromURL(_ url: URL, for key: String) -> String? {
    let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
    return comps?.queryItems?.first(where: { $0.name == key })?.value
}
