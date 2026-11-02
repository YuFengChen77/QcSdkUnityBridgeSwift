// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "QcSdkUnityBridgeSwift", defaultLocalization: "en", platforms: [.iOS(.v17)],

    products: [
        .library(name: "QcSdkUnityBridgeSwift", targets: ["QcSdkUnityBridgeSwift", "QcSdkUnityBridgeSwiftSupport"]),
        .library(name: "QcSdkUnityBridgeSwiftDependencies", type: .dynamic, targets: ["QcSdkUnityBridgeSwiftDependencies"])
    ],

    dependencies: [
        .package(url: "https://github.com/YuFengChen77/QcSdkCore.git", exact: "2.0.0-beta.1")
    ],

    targets: [
        .binaryTarget(name: "QcSdkUnityBridgeSwift", url: "https://github.com/YuFengChen77/QcSdkUnityBridgeSwift/releases/download/2.0.0-beta.1/QcSdkUnityBridgeSwift-2.0.0-beta.1.xcframework.zip", checksum: "05f22b9fcc2639ca3062225d1c8d832b5651ac7e85e028bf6fe0b45039475248"),

        .target(name: "QcSdkUnityBridgeSwiftSupport", dependencies: ["QcSdkUnityBridgeSwift", .product(name: "QcSdkCore", package: "qcsdkcore")], path: "QcSdkUnityBridgeSwift", exclude: ["DependencySources"], sources: ["Sources"]),
        .target(name: "QcSdkUnityBridgeSwiftDependencies", dependencies: [], path: "QcSdkUnityBridgeSwift", exclude: ["Sources"], sources: ["DependencySources"])
    ]
)
