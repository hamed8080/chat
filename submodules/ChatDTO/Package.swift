// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "ChatDTO",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "ChatDTO",
            targets: ["ChatDTO"]),
    ],
    dependencies: [
        .package(path: "../ChatModels"),
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
