// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "ChatCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
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
                .product(name: "Async", package: "Async"),
            ]
        ),
        .testTarget(
            name: "ChatCoreTests",
            dependencies: [
                "ChatCore",
                .product(name: "Async", package: "Async"),
            ],
            resources: []
        ),
    ]
)
