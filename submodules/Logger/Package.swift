// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Logger",    
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "Logger",
            targets: ["Logger"]),
    ],
    dependencies:  [
        .package(path: "../Additive"),
        .package(path: "../Mocks"),
        .package(path: "../Spec"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Logger",
            dependencies: [
                .product(name: "Additive", package: "Additive"),
                .product(name: "Spec", package: "Spec"),
                .product(name: "Mocks", package: "Mocks"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "LoggerTests",
            dependencies: [
                .product(name: "Additive", package: "Additive"),
                .product(name: "Spec", package: "Spec"),
                .product(name: "Mocks", package: "Mocks"),
                "Logger",
            ]
        ),
    ]
)
