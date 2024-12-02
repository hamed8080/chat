// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "ChatModels",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
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
