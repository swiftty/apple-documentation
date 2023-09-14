import SwiftUI

struct TechnologyCell: View {
    @Environment(\.isPressed) var isPressed

    var title: String
    var abstract: String

    var body: some View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(lineWidth: 1)
                .fill(isPressed ? .blue : .secondary)
        }
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
    private struct Key: EnvironmentKey {
        static var defaultValue: Bool = false
    }

    var isPressed: Bool {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
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
