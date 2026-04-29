package import Foundation
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

nonisolated package enum DevelopmentResources {
    package static func data(name: String) -> Data? {
        NSDataAsset(name: name, bundle: .nonisolatedModule)?.data
    }
}

package import AppleDocumentation
import AppleDocumentationAPI

extension TechnologyDetail {
    package static func from(json data: Data?) throws -> Self {
        try decodeTechnologyDetail(from: data ?? Data())
    }
}

private class BundleFinder {}

extension Foundation.Bundle {
    // swift-format-ignore: Indentation
    // Workaround for https://forums.swift.org/t/synthesized-bundle-module-is-not-usable-in-nonisolated-code-in-packages-with-mainactor-default-isolation/84416
    // Returns the resource bundle associated with the current Swift module.
    nonisolated static let nonisolatedModule: Bundle = {
        let bundleName = "AppleDocumentationPackage_DevelopmentAssets"

        let overrides: [URL]
        #if DEBUG
            // The 'PACKAGE_RESOURCE_BUNDLE_PATH' name is preferred since the expected value is a path. The
            // check for 'PACKAGE_RESOURCE_BUNDLE_URL' will be removed when all clients have switched over.
            // This removal is tracked by rdar://107766372.
            if let override = ProcessInfo.processInfo.environment["PACKAGE_RESOURCE_BUNDLE_PATH"]
                ?? ProcessInfo.processInfo.environment["PACKAGE_RESOURCE_BUNDLE_URL"]
            {
                overrides = [URL(fileURLWithPath: override)]
            } else {
                overrides = []
            }
        #else
            overrides = []
        #endif

        let candidates =
            overrides + [
                // Bundle should be present here when the package is linked into an App.
                Bundle.main.resourceURL,

                // Bundle should be present here when the package is linked into a framework.
                Bundle(for: BundleFinder.self).resourceURL,

                // For command-line tools.
                Bundle.main.bundleURL,
            ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named AppleDocumentationPackage_DevelopmentAssets")
    }()
}
