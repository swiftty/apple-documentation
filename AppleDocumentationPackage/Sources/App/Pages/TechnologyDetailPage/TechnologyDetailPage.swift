import SwiftUI
import AppleDocumentation

public struct TechnologyDetailPage: View {
    let destination: Technology.Destination

    public init(destination: Technology.Destination) {
        self.destination = destination
    }

    public var body: some View {
        Text("\(String(describing: destination))")
    }
}

#Preview {
    TechnologyDetailPage(
        destination: .init(
            identifier: .init(rawValue: ""),
            title: "",
            url: "",
            abstract: ""
        )
    )
}
