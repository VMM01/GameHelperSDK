// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameHelperSDK",
    platforms: [
        .iOS(.v14) // Укажите минимальные версии платформ
    ], products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GameHelperSDK",
            targets: ["GameHelperSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GameHelperSDK",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
            ]),
        .testTarget(
            name: "GameHelperSDKTests",
            dependencies: ["GameHelperSDK"]),
    ]
)
