// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "FanapPodChatSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10),
        .macOS(.v12),
        .macCatalyst(.v13),
    ],
    products: [
        .library(name: "FanapPodChatSDK", targets: ["FanapPodChatSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", .upToNextMinor(from: "4.5.0")),
        .package(url: "https://pubgi.fanapsoft.ir/chat/ios/fanappodasyncsdk.git", .upToNextMinor(from: "1.1.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
    ],
    targets: [
        .target(
            name: "FanapPodChatSDK",
            dependencies: [
                .product(name: "FanapPodAsyncSDK",
                         package: "fanappodasyncsdk"),
                .product(name: "Sentry",
                         package: "sentry-cocoa"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "FanapPodChatSDKTests",
                    dependencies: ["FanapPodChatSDK"], path: "Tests"),
    ]
)
