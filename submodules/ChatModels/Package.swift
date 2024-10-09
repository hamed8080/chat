// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatModels",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "ChatModels",
            targets: ["ChatModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ChatModels",
            dependencies: []
        ),
        .testTarget(
            name: "ChatModelsTests",
            dependencies: ["ChatModels"],
            resources: []
        ),
    ]
)
