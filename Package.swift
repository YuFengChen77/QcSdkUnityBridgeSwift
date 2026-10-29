// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "QcSdkUnityBridgeSwift", defaultLocalization: "en", platforms: [.iOS(.v17)],

    products: [
        .library(name: "QcSdkUnityBridgeSwift", targets: ["QcSdkUnityBridgeSwift", "QcSdkUnityBridgeSwiftSupport"])
    ],

    dependencies: [
        .package(url: "https://github.com/YuFengChen77/QcSdkCore.git", exact: "1.1.5")
    ],

    targets: [
        .binaryTarget(name: "QcSdkUnityBridgeSwift", url: "https://github.com/YuFengChen77/QcSdkUnityBridgeSwift/releases/download/1.1.2/QcSdkUnityBridgeSwift-1.1.2.xcframework.zip", checksum: "17342e8414da6e214e75b4ce59893f4f54f676a08f7f5fbc5c911b313d741185"),

        .target(name: "QcSdkUnityBridgeSwiftSupport", dependencies: ["QcSdkUnityBridgeSwift", .product(name: "QcSdkCore", package: "qcsdkcore")], path: "QcSdkUnityBridgeSwift", sources: ["Sources"])
    ]
)
