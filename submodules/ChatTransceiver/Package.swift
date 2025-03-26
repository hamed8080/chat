// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "ChatTransceiver",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "ChatTransceiver",
            targets: ["ChatTransceiver"]),
    ],
    dependencies: [
        .package(path: "../ChatDTO"),
        .package(path: "../Additive"),
        .package(path: "../Mocks"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ChatTransceiver",
            dependencies: [
                .product(name: "ChatDTO", package: "ChatDTO"),
                .product(name: "Additive", package: "Additive"),
                .product(name: "Mocks", package: "Mocks"),
            ]
        ),
        .testTarget(
            name: "ChatTransceiverTests",
            dependencies: [
                "ChatTransceiver",
                .product(name: "ChatDTO", package: "ChatDTO"),
                .product(name: "Additive", package: "Additive"),
                .product(name: "Mocks", package: "Mocks"),
            ],
            resources: []
        ),
    ]
)
