// swift-tools-version:5.9

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
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
    ],
    targets: [
        .target(name: "Async",
                dependencies: [
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
