import SwiftUI

struct TechnologyCell: View {
    @Environment(\.isPressed) var isPressed

    var title: String
    var abstract: String
    var tags: [String]

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundStyle(.primary)

                    Text(abstract)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal)

            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .preferredColorScheme(.light)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 8)
                                .frame(minWidth: 30)
                                .background {
                                    Capsule()
                                        .fill(.tertiary)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(lineWidth: 1)
                .fill(isPressed ? .blue : .secondary)
        }
        .contentShape(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
    }
}

extension TechnologyCell {
    struct ButtonStyle: SwiftUI.ButtonStyle {
       func makeBody(configuration: Configuration) -> some View {
           configuration.label
               .environment(\.isPressed, configuration.isPressed)
               .scaleEffect(configuration.isPressed ? 1.02 : 1)
       }
   }
}

extension EnvironmentValues {
    @Entry var isPressed: Bool = false
}

// swiftlint:disable line_length
#Preview(traits: .sizeThatFitsLayout) {
    TechnologyCell(
        title: "Accelerate",
        abstract: """
        Make large-scale mathematical computations and image calculations, optimized for high performance and low energy consumption.
        """,
        tags: ["UI"]
    )
    .padding()
}
// swiftlint:enable line_length
