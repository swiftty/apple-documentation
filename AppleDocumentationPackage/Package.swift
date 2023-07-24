// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppleDocumentationPackage",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppleDocumentationPackage",
            targets: [
                "AppleDocumentation", "AppleDocumentationAPI"
            ]),
    ],
    targets: [
        .target(
            name: "AppleDocumentation"),

        .target(
            name: "AppleDocumentationAPI",
            dependencies: ["AppleDocumentation"]),

            .testTarget(
                name: "AppleDocumentationAPITests",
                dependencies: ["AppleDocumentationAPI"])
    ]
)
