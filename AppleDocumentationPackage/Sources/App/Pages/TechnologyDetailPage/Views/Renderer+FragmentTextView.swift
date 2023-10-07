import SwiftUI
import AppleDocumentation
import UIComponent

struct FragmentTextView: View {
    @Environment(\.references) var references

    let fragments: [TechnologyDetail.Fragment]
    var attributes: AttributedText.Attributes = .init()

    var body: some View {
        Text { next in
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
                    attributes.link = nil
                    next(.init(string: fragment.text, attributes: attributes))

                case .identifier:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

                case .label:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)
                    next(.init(string: fragment.text, attributes: attributes))

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

                case .number:
                    attributes.foregroundColor = .init(r: 217, g: 201, b: 124)
                    next(.init(string: fragment.text, attributes: attributes))
                }
            }
        }
    }
}

extension Color {
    init(r: Int, g: Int, b: Int) {
        func f(_ v: Int) -> CGFloat {
            CGFloat(v) / 255
        }

        self = .init(uiColor: .init(red: f(r), green: f(g), blue: f(b), alpha: 1))
    }
}
