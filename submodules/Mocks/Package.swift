// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mocks",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13),
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
