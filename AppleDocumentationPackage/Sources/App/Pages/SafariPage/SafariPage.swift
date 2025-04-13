public import SwiftUI
import SafariServices

#if canImport(UIKit)

public struct SafariPage: View {
    var url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        InnerView(url: url)
            .ignoresSafeArea()
            .id(url)
    }
}

private struct InnerView: UIViewControllerRepresentable {
    var url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        #if os(visionOS)
        #else
        config.barCollapsingEnabled = true
        #endif
        let vc = SFSafariViewController(url: url, configuration: config)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#endif
