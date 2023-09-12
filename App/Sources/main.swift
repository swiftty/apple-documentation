import SwiftUI
import AppResolver

struct AppProvider {
    #if DEBUG
    private struct TestApp: SwiftUI.App {
        var body: some Scene {
            WindowGroup {
                Text("Now Testing...")
            }
        }
    }
    #endif

    static func main() {
        #if DEBUG
        if NSClassFromString("XCTestCase") != nil {
            TestApp.main()
            return
        }
        #endif

        App.main()
    }
}

AppProvider.main()
