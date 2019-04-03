// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SecureDefaults",
    products: [
        .library(
            name: "SecureDefaults",
            targets: ["SecureDefaults"]),
    ],
    targets: [
        .target(
            name: "SecureDefaults",
            dependencies: []),
        .testTarget(
            name: "SecureDefaultsTests",
            dependencies: ["SecureDefaults"]),
    ]
)
