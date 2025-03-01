// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Spec",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "Spec",
            targets: ["Spec"]),
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Spec",
            dependencies: []
        ),
        .testTarget(
            name: "SpecTests",
            dependencies: ["Spec"]
        ),
    ]
)
