import PackagePlugin
import Foundation

@main
struct TuistPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let tuist = try context.tool(named: "tuist")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: tuist.path.string)
        process.arguments = arguments
        process.currentDirectoryURL = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("project")

        try process.run()
        process.waitUntilExit()
    }
}
