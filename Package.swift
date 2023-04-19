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
        .package(path: "../Async"),
        .package(path: "ChatModels"),
        .package(path: "ChatCache"),
        .package(path: "ChatExtensions"),
        .package(path: "ChatDTO"),
        .package(path: "ChatCore"),
//        .package(url: "https://pubgi.fanapsoft.ir/chat/ios/async.git", exact: "1.3.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
    ],
    targets: [
        .target(
            name: "Chat",
            dependencies: [
                "ChatModels",
                "ChatCache",
                "ChatDTO",
                "ChatExtensions",
                "ChatCore",
                .product(name: "Async", package: "async"),
            ],
            resources: []
        ),
        .testTarget(name: "ChatTests", dependencies: ["Chat"], path: "Tests"),
    ]
)
