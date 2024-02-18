import SwiftUI
import AppleDocumentation
import UIComponent

struct FragmentTextView: View {
    @Environment(\.references) var references

    let fragments: [TechnologyDetail.Fragment]
    var attributes: AttributedText.Attributes = .init()
    var modifier: (TechnologyDetail.Fragment.Kind, inout AttributedText.Attributes) -> Void = { _, _ in }

    var body: some View {
        Text { next in
            for fragment in fragments {
                var attributes = attributes
                attributes.monospaced = true
                if let identifier = fragment.identifier {
                    attributes.link(using: references[identifier])
                }

                defer {
                    modifier(fragment.kind, &attributes)
                    next(.init(string: fragment.text, attributes: attributes))
                }

                switch fragment.kind {
                case .keyword:
                    attributes.foregroundColor = .init(r: 255, g: 122, b: 178)

                case .text:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)

                case .identifier:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)

                case .label:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)

                case .typeIdentifier:
                    attributes.foregroundColor = .init(r: 218, g: 186, b: 255)

                case .genericParameter:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)

                case .internalParam:
                    attributes.foregroundColor = .init(r: 191, g: 191, b: 191)

                case .externalParam:
                    attributes.foregroundColor = .init(r: 255, g: 255, b: 255)

                case .attribute:
                    attributes.foregroundColor = .init(r: 255, g: 122, b: 178)

                case .number:
                    attributes.foregroundColor = .init(r: 217, g: 201, b: 124)
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

        #if canImport(UIKit)
        self = .init(uiColor: .init(red: f(r), green: f(g), blue: f(b), alpha: 1))
        #elseif canImport(AppKit)
        self = .init(nsColor: .init(red: f(r), green: f(g), blue: f(b), alpha: 1))
        #endif
    }
}
