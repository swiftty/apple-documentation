import Foundation
import Observation
import AppleDocumentation
import AppleDocClient

@Observable
class TechnologyDetailModel {
    struct Dependency {
        let appleDocClient: AppleDocClient
    }

    let destination: Technology.Destination.Value
    let dependency: Dependency

    private(set) var detail: TechnologyDetail?

    init(
        destination: Technology.Destination.Value,
        dependency: Dependency
    ) {
        self.destination = destination
        self.dependency = dependency
    }

    func fetch() async {
        do {
            detail = try await dependency.appleDocClient.technologyDetail(for: destination)
        } catch {
            print(error)
        }
    }
}
