import SwiftUI
import AppleDocumentation

struct FragmentTextView: View {
    let fragments: [TechnologyDetail.Fragment]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            text()
        }
        .contentMargins(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.tertiary)
        }
    }

    private func text() -> Text {
        Text { next in
            let attributes = AttributedText.Attributes()
            for fragment in fragments {
                switch fragment.kind {
                case .keyword:
                    var attributes = attributes
                    attributes.foregroundColor = .init(r: 255, g: 122, b: 178)
                    next(.init(string: fragment.text, attributes: attributes))

                case .text:
                    var attributes = attributes
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .identifier:
                    var attributes = attributes
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .label:
                    var attributes = attributes
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))
                    fatalError()

                case .typeIdentifier:
                    var attributes = attributes
                    attributes.foregroundColor = .init(r: 218, g: 186, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .genericParameter:
                    var attributes = attributes
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .internalParam:
                    var attributes = attributes
                    attributes.foregroundColor = .init(r: 191, g: 191, b: 191)
                    next(.init(string: fragment.text, attributes: attributes))

                case .externalParam:
                    var attributes = attributes
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .attribute:
                    var attributes = attributes
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
