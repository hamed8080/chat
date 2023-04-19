// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatCache",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v12),
        .macCatalyst(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ChatCache",
            targets: ["ChatCache"]),
    ],
    dependencies: [
        .package(path: "../ChatModels"),
        .package(path: "../ChatDTO"),
        .package(path: "../ChatExtensions"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ChatCache",
            dependencies: ["ChatModels", "ChatDTO", "ChatExtensions"],
            resources: [.process("Resources")]

        ),
        .testTarget(
            name: "ChatCacheTests",
            dependencies: ["ChatCache"],
            resources: [
                .copy("Resources/icon.png")
            ]
        ),
    ]
)
