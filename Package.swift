// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "DangerSwiftLint",
    products: [
        .library(
            name: "DangerSwiftLint",
            targets: ["DangerSwiftLint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", from: "3.18.1")
    ],
    targets: [
        .target(
            name: "DangerSwiftLint",
            dependencies: [.product(name: "Danger", package: "swift")]),
        .testTarget(
            name: "DangerSwiftLintTests",
            dependencies: ["DangerSwiftLint"]),
    ]
)
