// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CohoSDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "CohoSDK",
            targets: ["CohoSDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CohoSDK",
            dependencies: []),
        .testTarget(
            name: "CohoSDKTests",
            dependencies: ["CohoSDK"]),
    ]
)
