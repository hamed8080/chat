// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Async",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "Async", targets: ["Async"]),
    ],
    dependencies:  [
        .package(path: "../Logger"),
        .package(path: "../Mocks"),
        .package(path: "../Additive"),
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "3.1.1")),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
    ],
    targets: [
        .target(name: "Async",
                dependencies: [
                    "Starscream",
                    .product(name: "Additive", package: "Additive"),
                    .product(name: "Logger", package: "Logger"),
                ]),
        .testTarget(name: "AsyncTests",
                    dependencies: [
                        .product(name: "Additive", package: "Additive"),
                        .product(name: "Logger", package: "Logger"),
                        .product(name: "Mocks", package: "Mocks"),
                    ],
                    path: "Tests"),
    ]
)
