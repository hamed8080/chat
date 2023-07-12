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
//        .package(path: "../async"),
        .package(url: "https://pubgi.fanapsoft.ir/chat/ios/fanappodasyncsdk.git", .upToNextMinor(from: "1.2.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
    ],
    targets: [
        .target(
            name: "FanapPodChatSDK",
            dependencies: [
                .product(name: "FanapPodAsyncSDK",
                         package: "fanappodasyncsdk"),

//                    .product(name: "FanapPodAsyncSDK",
//                             package: "async"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "FanapPodChatSDKTests",
                    dependencies: ["FanapPodChatSDK"], path: "Tests"),
    ]
)
