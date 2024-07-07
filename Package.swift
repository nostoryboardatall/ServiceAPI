// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ServiceAPI",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v9)
    ],
    products: [
        .library(name: "ServiceAPI",
                 targets: ["ServiceAPI"]),
    ],
    targets: [
        .target(name: "ServiceAPI"),
        .testTarget(name: "ServiceAPITests",
                    dependencies: ["ServiceAPI"]),
    ]
)
