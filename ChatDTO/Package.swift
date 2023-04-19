// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatDTO",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v12),
        .macCatalyst(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ChatDTO",
            targets: ["ChatDTO"]),
    ],
    dependencies: [
        .package(path: "../ChatCore"),
        .package(path: "../ChatModels")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ChatDTO",
            dependencies: ["ChatCore", "ChatModels"]
        ),
        .testTarget(
            name: "ChatDTOTests",
            dependencies: ["ChatDTO"],
            resources: []
        ),
    ]
)
