// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatExtensions",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v12),
        .macCatalyst(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ChatExtensions",
            targets: ["ChatExtensions"]),
    ],
    dependencies: [.package(path: "../ChatDTO")],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ChatExtensions",
            dependencies: ["ChatDTO"]
        ),
        .testTarget(
            name: "ChatExtensionsTests",
            dependencies: ["ChatExtensions"],
            resources: []
        ),
    ]
)
