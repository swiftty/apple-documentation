import SwiftUI
import AppleDocumentation
import Nuke
import NukeUI
import UIComponent

struct ImageView: View {
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) var colorScheme

    let variants: [DocumentData.ImageVariant]

    var body: some View {
        if let url = findURL() {
            LazyImage(url: url) { state in
                state.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: state.imageContainer.map { $0.image.size.width / displayScale })
            }
        } else {
            Color.clear
                .overlay {
                    Image(systemName: "exclamationmark.triangle")
                }
                .aspectRatio(CGSize(width: 3, height: 2), contentMode: .fit)
                .border(.yellow)
        }
    }

    private func findURL() -> URL? {
        for variant in variants where variant.isMatching(scheme: colorScheme) {
            return variant.url
        }
        return variants.first?.url
    }
}
