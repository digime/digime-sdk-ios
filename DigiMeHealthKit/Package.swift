// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DigiMeHealthKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v13)
    ],
    products: [
        .library(name: "DigiMeHealthKit", targets: ["DigiMeHealthKit"]),
    ],
    dependencies: [
        .package(path: "../DigiMeCore"),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
    ],
    targets: [
        .target(
            name: "DigiMeHealthKit",
            dependencies: ["DigiMeCore"],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("Security"),
                .linkedFramework("CryptoKit"),
                .linkedFramework("HealthKit")
            ]

        )
    ]
)
