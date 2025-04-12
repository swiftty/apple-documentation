package import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

package enum DevelopmentResources {
    package static func data(name: String) -> Data? {
        NSDataAsset(name: name, bundle: .module)?.data
    }
}

package import AppleDocumentation
import AppleDocumentationAPI

extension TechnologyDetail {
    package static func from(json data: Data?) throws -> Self {
        try decodeTechnologyDetail(from: data ?? Data())
    }
}
