import SwiftUI
import AppleDocumentation

struct LinksView: View {
    let style: String
    let items: [TechnologyDetail.Reference]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(items.indexed()) { item in
                ReferenceView(reference: item.element)
            }
        }
    }
}
