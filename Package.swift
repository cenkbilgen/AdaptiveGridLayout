// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdaptiveGridLayout",
    platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9), .tvOS(.v16)],
    products: [
        .library(
            name: "AdaptiveGridLayout",
            targets: ["AdaptiveGridLayout"]),
    ],
    targets: [
        .target(
            name: "AdaptiveGridLayout",
            swiftSettings: [
                .unsafeFlags(["-warnings-as-errors"], .when(configuration: .debug)),
            ])
    ]
)
