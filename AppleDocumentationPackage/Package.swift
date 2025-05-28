// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

enum Feature {
    case app
    case dependencies
    case pages
    case developments

    var path: String {
        switch self {
        case .app: "Sources/App"
        case .dependencies: "Sources/App/Dependencies"
        case .pages: "Sources/App/Pages"
        case .developments: "Sources/App/Developments"
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
    platforms: [.iOS(.v17), .macOS(.v14)],
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
        .package(url: "https://github.com/kean/Nuke.git", from: "12.8.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.13.0"),

        .package(url: "https://github.com/apple/swift-syntax.git", from: "601.0.1"),

        .package(url: "https://github.com/swiftty/XcodeGenBinary.git", from: "2.43.0"),
        .package(url: "https://github.com/swiftty/SwiftLintBinary.git", exact: "0.59.1-patch")
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
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax")
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
                "SafariPage",
                "AllTechnologiesPage",
                "TechnologyDetailPage",

                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ]
        ),

        .target(
            feature: .app,
            name: "UIComponent",
            dependencies: [
                "AppleDocumentation",

                "SupportMacros"
            ]
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
                "AppleDocumentation",

                "SupportMacros"
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
            name: "SafariPage",
            dependencies: []
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

                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "NukeExtensions", package: "Nuke")
            ]
        ),

        //
        .target(
            feature: .developments,
            name: "DevelopmentAssets",
            dependencies: [
                "AppleDocumentationAPI"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)

extension Optional {
    static func += <T>(lhs: inout Self, rhs: [T]) where Wrapped == [T] {
        lhs = (lhs ?? []) + rhs
    }
}

package.targets.forEach { target in
    if target.type != .macro {
        target.swiftSettings += [
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault")
        ]
    }
    target.plugins += [
        .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintBinary")
    ]
}

let isDEBUG = true
if isDEBUG {
    package.targets.forEach {
        guard $0.path?.hasPrefix("Sources/App") ?? false else { return }
        guard $0.name != "DevelopmentAssets" else { return }
        $0.dependencies += [
            "DevelopmentAssets"
        ]
    }
}
