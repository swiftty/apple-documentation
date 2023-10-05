import SwiftUI
import AppleDocumentation
import UIComponent

struct FragmentTextView: View {
    @Environment(\.references) var references

    let fragments: [TechnologyDetail.Fragment]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            text()
                .tint(.init(r: 218, g: 186, b: 255))
        }
        .contentMargins(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.tertiary)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func text() -> Text {
        Text { next in
            let attributes = AttributedText.Attributes()
            for fragment in fragments {
                var attributes = attributes
                if let identifier = fragment.identifier {
                    attributes.link(using: references[identifier])
                }

                switch fragment.kind {
                case .keyword:
                    attributes.foregroundColor = .init(r: 255, g: 122, b: 178)
                    next(.init(string: fragment.text, attributes: attributes))

                case .text:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .identifier:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .label:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))
                    fatalError()

                case .typeIdentifier:
                    attributes.foregroundColor = .init(r: 218, g: 186, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .genericParameter:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .internalParam:
                    attributes.foregroundColor = .init(r: 191, g: 191, b: 191)
                    next(.init(string: fragment.text, attributes: attributes))

                case .externalParam:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .attribute:
                    attributes.foregroundColor = .init(r: 255, g: 122, b: 178)
                    next(.init(string: fragment.text, attributes: attributes))
                }
            }
        }
    }
}

private extension Color {
    init(r: Int, g: Int, b: Int) {
        func f(_ v: Int) -> CGFloat {
            CGFloat(v) / 255
        }

        self = .init(uiColor: .init(red: f(r), green: f(g), blue: f(b), alpha: 1))
    }
}
