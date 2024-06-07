// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "DangerSwiftLint",
    products: [
        .library(
            name: "DangerSwiftLint",
            targets: ["DangerSwiftLint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danger/danger-swift.git", from: "3.18.1")
    ],
    targets: [
        .target(
            name: "DangerSwiftLint",
            dependencies: ["Danger"]),
        .testTarget(
            name: "DangerSwiftLintTests",
            dependencies: ["DangerSwiftLint"]),
    ]
)
