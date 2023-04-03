// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Chat",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v12),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "Chat", targets: ["Chat"]),
    ],
    dependencies: [
        .package(url: "https://pubgi.fanapsoft.ir/chat/ios/async.git", exact: "1.3.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
    ],
    targets: [
        .target(
            name: "Chat",
            dependencies: [
                .product(name: "Async", package: "async"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "ChatTests", dependencies: ["Chat"], path: "Tests"),
    ]
)
