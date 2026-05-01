import SwiftUI
import AppleDocumentation

struct CodeListView: View {
    let syntax: String?
    let code: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code.joined(separator: "\n"))
                .fixedSize(horizontal: false, vertical: true)
                .tint(.init(r: 218, g: 186, b: 255))
        }
        .contentMargins(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.tertiary)
        }
    }
}
