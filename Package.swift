// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "FanapPodChatSDK",
    platforms: [
        .iOS(.v10),
        .macOS(.v12),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "FanapPodChatSDK", targets: ["FanapPodChatSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", .upToNextMajor(from: "4.5.0")),
        .package(path: "../FanapPodAsyncSDK"),
    ],
    targets: [
        .target(name: "FanapPodChatSDK", dependencies: [
            "FanapPodAsyncSDK",
            .product(name: "Sentry", package: "sentry-cocoa"),
        ],
        swiftSettings: [.unsafeFlags(["-suppress-warnings"])]),
        .testTarget(name: "FanapPodChatSDKTests", dependencies: ["FanapPodChatSDK"]),
    ]
)
