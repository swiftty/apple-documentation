public import SwiftUI
public import AppleDocumentation
import SupportMacros

public struct OpenDestinationAction {
    private let handler: (Technology.Destination.Value) -> Void

    public init(perform handler: @escaping (Technology.Destination.Value) -> Void) {
        self.handler = handler
    }

    public func callAsFunction(_ identifier: Technology.Destination.Value) {
        handler(identifier)
    }
}

extension EnvironmentValues {
    @Entry
    public var openDestination: OpenDestinationAction = .init(perform: { _ in })
}

extension View {
    public func extractDestination() -> some View {
        modifier(OpenDestinationModifier())
    }
}

private struct OpenDestinationModifier: ViewModifier {
    @Environment(\.openURL) var openURL
    @Environment(\.openDestination) var openDestination

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                guard let identifier = decodeFromURL(url, for: "identifier") else {
                    openURL(url)
                    return .handled
                }
                if identifier.hasPrefix("/") {
                    openDestination(.init(rawValue: identifier))
                    return .handled
                }
                guard let url = URL(string: identifier) else { return .discarded }
                if url.scheme?.hasPrefix("http") ?? false {
                    openURL(url)
                    return .handled
                }

                openDestination(.init(rawValue: identifier))
                return .handled
            })
    }
}
