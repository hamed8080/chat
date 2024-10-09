// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Additive",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "Additive",
            targets: ["Additive"]),
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Additive",
            dependencies: []
        ),
        .testTarget(
            name: "AdditiveTests",
            dependencies: ["Additive"],
            resources: [
                .copy("Resources/icon.png"),
                .copy("Resources/Localizable.strings")
            ]
        ),
    ]
)
