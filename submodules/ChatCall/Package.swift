// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "ChatCall",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v12),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "ChatCall", targets: ["ChatCall"]),
    ],
    dependencies: [
        .package(path: "../Chat"),
        .package(url: "https://github.com/stasel/WebRTC.git", .upToNextMajor(from: "107.0.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "ChatCall",
            dependencies: [
                "Chat",
                "WebRTC",
            ],
            resources: []
        ),
        .testTarget(name: "ChatTests",
         dependencies: [
            "Chat",
            "WebRTC",
            ],
             path: "Tests"),
    ]
)
