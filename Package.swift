// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Chat",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "Chat", targets: ["Chat"]),
    ],
    dependencies: [
        .package(path: "submodules/ChatExtensions"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/stasel/WebRTC.git", .upToNextMajor(from: "107.0.0")),
    ],
    targets: [
        .target(
            name: "Chat",
            dependencies: [
                .product(name: "ChatExtensions", package: "ChatExtensions"),
                "WebRTC"
            ],
            resources: []
        ),
        .testTarget(
            name: "ChatTests",
            dependencies: [
                "Chat",
                .product(name: "ChatExtensions", package: "ChatExtensions"),
                "WebRTC"
            ],
            path: "Tests"
        ),
    ]
)
