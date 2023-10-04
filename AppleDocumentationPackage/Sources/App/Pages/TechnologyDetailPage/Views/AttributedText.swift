import SwiftUI

struct AttributedText: Hashable {
    var string: String
    var attributes: Attributes

    struct Attributes: Hashable {
        var font: Font = .body
        var bold: Bool = false
        var italic: Bool = false
        var monospaced: Bool = false
        var foregroundColor: Color = .primary

        var link: URL?
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
            .foregroundStyle(attributes.foregroundColor)
    }
}

extension Text {
    init(_ attributedText: AttributedText) {
        self = attributedText.render()
    }

    init(next: ((AttributedText) -> Void) -> Void) {
        var text = Text("")
        next { attributedText in
            // swiftlint:disable:next shorthand_operator
            text = text + Text(attributedText)
        }
        self = text
    }
}
