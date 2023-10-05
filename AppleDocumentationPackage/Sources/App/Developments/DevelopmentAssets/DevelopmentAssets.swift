import Foundation
import UIKit

package enum DevelopmentResources {
    package static func data(name: String) -> Data? {
        NSDataAsset(name: name, bundle: .module)?.data
    }
}

import AppleDocumentation
import AppleDocumentationAPI

extension TechnologyDetail {
    package static func from(json data: Data?) throws -> Self {
        try decodeTechnologyDetail(from: data ?? Data())
    }
}
