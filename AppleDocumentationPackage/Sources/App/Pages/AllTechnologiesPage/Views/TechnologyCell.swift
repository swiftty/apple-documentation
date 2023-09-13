import SwiftUI

struct TechnologyCell: View {
    var title: String
    var abstract: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline.bold())
                .foregroundStyle(.primary)

            Text(abstract)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(lineWidth: 1)
                .fill(.secondary)
        }
    }
}

// swiftlint:disable line_length
#Preview(traits: .sizeThatFitsLayout) {
    TechnologyCell(
        title: "Accelerate",
        abstract: """
        Make large-scale mathematical computations and image calculations, optimized for high performance and low energy consumption.
        """
    )
    .padding()
}
// swiftlint:enable line_length
