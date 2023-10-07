import SwiftUI
import AppleDocumentation
import SupportMacros

@ImplicitInit
public struct AttributedText: Hashable {
    public var string: String
    public var attributes: Attributes

    public struct Attributes: Hashable {
        public var font: Font
        public var bold: Bool
        public var italic: Bool
        public var monospaced: Bool
        public var foregroundColor: Color?

        public var link: URL?

        public init(
            font: Font = .body,
            bold: Bool = false,
            italic: Bool = false,
            monospaced: Bool = false,
            foregroundColor: Color? = nil,
            link: URL? = nil
        ) {
            self.font = font
            self.bold = bold
            self.italic = italic
            self.monospaced = monospaced
            self.foregroundColor = foregroundColor
            self.link = link
        }

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
