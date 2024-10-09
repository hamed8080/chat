// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatCache",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "ChatCache",
            targets: ["ChatCache"]),
    ],
    dependencies:  [
        .package(path: "../ChatModels"),
        .package(path: "../Additive"),
        .package(path: "../Mocks"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ChatCache",
            dependencies: [
                .product(name: "Additive", package: "Additive"),
                .product(name: "ChatModels", package: "ChatModels"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ChatCacheTests",
            dependencies: [
                "ChatCache",
                .product(name: "Additive", package: "Additive"),
                .product(name: "ChatModels", package: "ChatModels"),
                .product(name: "Mocks", package: "Mocks"),
            ]
        ),
    ]
)
