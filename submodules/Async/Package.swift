// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Async",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "Async", targets: ["Async"]),
    ],
    dependencies:  [
        .package(path: "../Logger"),
        .package(path: "../Mocks"),
        .package(path: "../Additive"),
        .package(path: "../Spec"),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
    ],
    targets: [
        .target(name: "Async",
                dependencies: [
                    .product(name: "Additive", package: "Additive"),
                    .product(name: "Logger", package: "Logger"),
                    .product(name: "Spec", package: "Spec"),
                ]),
        .testTarget(name: "AsyncTests",
                    dependencies: [
                        .target(name: "Async"),
                        .product(name: "Additive", package: "Additive"),
                        .product(name: "Logger", package: "Logger"),
                        .product(name: "Spec", package: "Spec"),
                        .product(name: "Mocks", package: "Mocks"),
                    ],
                    path: "Tests"),
    ]
)
