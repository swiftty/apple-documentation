import SwiftUI
import AppleDocumentation

struct AsideView<Content: View>: View {
    let name: String?
    let style: String
    @ViewBuilder let content: Content

    var body: some View {
        let params = parameters()

        VStack(alignment: .leading) {
            if let name = params.name {
                Text(name)
                    .foregroundStyle(.primary)
                    .font(.body.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            content
        }
        .padding()
        .tint(.primary)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(params.fill)
                .stroke(params.border)
        }
    }

    private func parameters() -> (name: String?, fill: AnyShapeStyle, border: AnyShapeStyle) {
        switch style {
        case "important":
            return (
                name ?? "Important",
                AnyShapeStyle(.yellow.opacity(0.2)),
                AnyShapeStyle(.yellow)
            )
        default:
            return (
                name,
                AnyShapeStyle(.tertiary.opacity(0.3)),
                AnyShapeStyle(.quaternary)
            )
        }
    }
}
