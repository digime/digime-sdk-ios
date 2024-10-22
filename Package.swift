// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DigiMeSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "DigiMeSDK", targets: ["DigiMeSDK"]),
        .library(name: "DigiMeSDKWithHealthKit", targets: ["DigiMeSDK", "DigiMeHealthKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "DigiMeCore",
            dependencies: [],
            path: "DigiMeCore/Sources"),
        .target(
            name: "DigiMeSDK",
            dependencies: ["DigiMeCore"],
            path: "DigiMeSDK/Sources"),
        .target(
            name: "DigiMeHealthKit",
            dependencies: ["DigiMeCore"],
            path: "DigiMeHealthKit/Sources"),
    ]
)
