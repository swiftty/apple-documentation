// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum Feature {
    case app
    case dependencies
    case pages

    var path: String {
        switch self {
        case .app: "Sources/App"
        case .dependencies: "Sources/App/Dependencies"
        case .pages: "Sources/App/Pages"
        }
    }
}

extension Target {
    static func target(
        feature: Feature,
        name: String,
        dependencies: [Dependency] = [],
        exclude: [String] = [],
        sources: [String]? = nil,
        resources: [Resource]? = nil,
        publicHeadersPath: String? = nil,
        packageAccess: Bool = true,
        cSettings: [CSetting]? = nil,
        cxxSettings: [CXXSetting]? = nil,
        swiftSettings: [SwiftSetting]? = nil,
        linkerSettings: [LinkerSetting]? = nil,
        plugins: [PluginUsage]? = nil
    ) -> Target {
        return .target(
            name: name,
            dependencies: dependencies,
            path: feature.path + "/" + name,
            exclude: exclude,
            sources: sources,
            resources: resources,
            publicHeadersPath: publicHeadersPath,
            packageAccess: packageAccess,
            cSettings: cSettings,
            cxxSettings: cxxSettings,
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings,
            plugins: plugins
        )
    }
}

let package = Package(
    name: "AppleDocumentationPackage",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "AppleDocumentationApp",
            targets: [
                "AppResolver",
                "AllTechnologiesPage"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftty/XcodeGenBinary.git", from: "2.37.0"),
        .package(url: "https://github.com/swiftty/SwiftLintBinary.git", branch: "main")
    ],
    targets: [
        .target(
            name: "AppleDocumentation"
        ),

        .target(
            name: "AppleDocumentationAPI",
            dependencies: ["AppleDocumentation"]
        ),

        .testTarget(
            name: "AppleDocumentationAPITests",
            dependencies: ["AppleDocumentationAPI"]
        ),

        // app
        .target(
            feature: .app,
            name: "AppResolver",
            dependencies: [
                "Router",
                "AppleDocClientLive",
                "RootPage",
                "AllTechnologiesPage"
            ]
        ),

        .target(
            feature: .app,
            name: "UIComponent"
        ),

        // dependencies
        .target(
            feature: .dependencies,
            name: "Router",
            dependencies: [
                "AppleDocumentation"
            ]
        ),

        .target(
            feature: .dependencies,
            name: "AppleDocClient",
            dependencies: [
                "AppleDocumentation"
            ]
        ),

        .target(
            feature: .dependencies,
            name: "AppleDocClientLive",
            dependencies: [
                "AppleDocClient",
                "AppleDocumentation",
                "AppleDocumentationAPI"
            ]
        ),

        // pages
        .target(
            feature: .pages,
            name: "RootPage",
            dependencies: [
                "Router",
                "UIComponent"
            ]
        ),

        .target(
            feature: .pages,
            name: "AllTechnologiesPage",
            dependencies: [
                "Router",
                "AppleDocClient",
                "UIComponent"
            ]
        )
    ]
)

package.targets.forEach {
    var plugins = $0.plugins ?? []

    plugins += [
        .plugin(name: "SwiftLintPlugin", package: "SwiftLintBinary")
    ]
    $0.plugins = plugins
}
