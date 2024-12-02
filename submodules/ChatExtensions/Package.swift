// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "ChatExtensions",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "ChatExtensions",
            targets: ["ChatExtensions"]),
    ],
    dependencies:  [
        .package(path: "../ChatTransceiver"),
        .package(path: "../ChatCache"),
        .package(path: "../ChatCore"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ChatExtensions",
            dependencies: [
                .product(name: "ChatTransceiver", package: "ChatTransceiver"),
                .product(name: "ChatCache", package: "ChatCache"),
                .product(name: "ChatCore", package: "ChatCore"),
            ]
        ),
        .testTarget(
            name: "ChatExtensionsTests",
            dependencies: [
                "ChatExtensions",
                .product(name: "ChatTransceiver", package: "ChatTransceiver"),
                .product(name: "ChatCache", package: "ChatCache"),
                .product(name: "ChatCore", package: "ChatCore"),
            ],
            resources: []
        ),
    ]
)
