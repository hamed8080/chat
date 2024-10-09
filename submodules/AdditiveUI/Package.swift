// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdditiveUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "AdditiveUI",
            targets: ["AdditiveUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [        
        .target(
            name: "AdditiveUI",
            dependencies: []
        ),
        .testTarget(
            name: "AdditiveUITests",
            dependencies: ["AdditiveUI"],
            resources: [
                .copy("Resources/icon.png")
            ]
        ),
    ]
)
