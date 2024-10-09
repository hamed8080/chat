// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatDTO",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "ChatDTO",
            targets: ["ChatDTO"]),
    ],
    dependencies: [
        .package(path: "../ChatModels"),
        .package(url: "https://pubgi.sandpod.ir/chat/ios/chat-models", from: "2.2.1"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ChatDTO",
            dependencies: [
                .product(name: "ChatModels", package: "ChatModels"),
            ]
        ),
        .testTarget(
            name: "ChatDTOTests",
            dependencies: [
                .product(name: "ChatModels", package: "ChatModels"),
            ],
            resources: []
        ),
    ]
)
