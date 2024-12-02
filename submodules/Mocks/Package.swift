// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Mocks",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "Mocks",
            targets: ["Mocks"]),
    ],
    dependencies: [
        .package(path: "../Additive"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Mocks",
            dependencies: [
                .product(name: "Additive", package: "Additive")
            ]
        ),
    ]
)
