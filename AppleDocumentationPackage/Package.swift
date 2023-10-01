// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

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
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(
            name: "AppleDocumentationApp",
            targets: [
                "AppResolver",
                "RootPage",
                "AllTechnologiesPage",
                "TechnologyDetailPage"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", from: "12.1.6"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),

        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),

        .package(url: "https://github.com/swiftty/XcodeGenBinary.git", from: "2.37.0"),
        .package(url: "https://github.com/swiftty/SwiftLintBinary.git", from: "0.53.0")
    ],
    targets: [
        .target(
            name: "AppleDocumentation",
            dependencies: ["SupportMacros"]
        ),

        .target(
            name: "AppleDocumentationAPI",
            dependencies: [
                "AppleDocumentation",
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),

        .testTarget(
            name: "AppleDocumentationAPITests",
            dependencies: ["AppleDocumentationAPI"]
        ),

        .target(
            name: "SupportMacros",
            dependencies: ["SupportMacrosPlugin"]
        ),

        .macro(
            name: "SupportMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        .testTarget(
            name: "SupportMacrosPluginTests",
            dependencies: [
                "SupportMacrosPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        ),

        // app
        .target(
            feature: .app,
            name: "AppResolver",
            dependencies: [
                "Router",
                "AppleDocClientLive",
                "RootPage",
                "AllTechnologiesPage",
                "TechnologyDetailPage"
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
        ),

        .target(
            feature: .pages,
            name: "TechnologyDetailPage",
            dependencies: [
                "SupportMacros",

                "Router",
                "AppleDocClient",
                "UIComponent",

                .product(name: "NukeExtensions", package: "Nuke")
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
