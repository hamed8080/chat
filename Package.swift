// swift-tools-version:5.6

import PackageDescription

let useLocalDependency = true

let local: [Package.Dependency] = [
    .package(path: "../ChatExtensions"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
]

let remote: [Package.Dependency] = [
    .package(url: "https://pubgi.sandpod.ir/chat/ios/chat-extensions", from: "2.1.2"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
]

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
    dependencies: useLocalDependency ? local : remote,
    targets: [
        .target(
            name: "Chat",
            dependencies: [
                .product(name: "ChatExtensions", package: useLocalDependency ? "ChatExtensions" : "chat-extensions"),
            ],
            resources: []
        ),
        .testTarget(name: "ChatTests", dependencies: [
            "Chat",
            .product(name: "ChatExtensions", package: useLocalDependency ? "ChatExtensions" : "chat-extensions"),
        ], path: "Tests"),
    ]
)
