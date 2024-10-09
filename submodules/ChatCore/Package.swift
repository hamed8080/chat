// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "ChatCore",
            targets: ["ChatCore"]),
    ],
    dependencies: [
        .package(path: "../Async"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ChatCore",
            dependencies: [
                .productItem(name: "Async", package: "Async"),
            ]
        ),
        .testTarget(
            name: "ChatCoreTests",
            dependencies: [
                "ChatCore",
                .productItem(name: "Async", package: "Async"),
            ],
            resources: []
        ),
    ]
)
