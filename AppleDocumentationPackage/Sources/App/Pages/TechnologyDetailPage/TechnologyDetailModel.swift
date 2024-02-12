import Foundation
import Observation
import AppleDocumentation
import AppleDocClient
import UIComponent

@Observable
class TechnologyDetailModel {
    struct Dependency {
        let appleDocClient: AppleDocClient
    }

    let destination: Technology.Destination.Value
    let dependency: Dependency

    private(set) var detail = WithUIStack<TechnologyDetail?>(initialValue: nil)

    init(
        destination: Technology.Destination.Value,
        dependency: Dependency
    ) {
        self.destination = destination
        self.dependency = dependency
    }

    func fetch() async {
        do {
            detail.next(.loaded(try await dependency.appleDocClient.technologyDetail(for: destination)))
        } catch {
            detail.next(.failed(error))
        }
    }
}
