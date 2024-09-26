// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DigiPlugin",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DigiPlugin",
            targets: ["DigiMePlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main"),
        .package(url: "https://github.com/apple/FHIRModels.git", branch: "main"),
        .package(path: "../../../digime-sdk-ios/DigiMeSDK"),
        .package(path: "../../../digime-sdk-ios/DigiMeHealthKit")
    ],
    targets: [
        .target(
            name: "DigiMePlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "ModelsR5", package: "FHIRModels"),
                .product(name: "DigiMeSDK", package: "DigiMeSDK"),
                .product(name: "DigiMeHealthKit", package: "DigiMeHealthKit")
            ],
            path: "ios/Sources/DigiMePlugin",
            resources: [.process("Resources")]),
        .testTarget(
            name: "DigiMePluginTests",
            dependencies: ["DigiMePlugin"],
            path: "ios/Tests/DigiMePluginTests")
    ]
)
