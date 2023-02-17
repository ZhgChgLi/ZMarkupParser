// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZMarkupParser",
    platforms: [.iOS(.v12), .macOS(.v10_14)],
    products: [
        .library(name: "ZMarkupParser", targets: ["ZMarkupParser"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.11.0")
    ],
    targets: [
        .target(
            name: "ZMarkupParser",
            dependencies: []),
        .testTarget(
            name: "ZMarkupParserTests",
            dependencies: ["ZMarkupParser"]),
        .testTarget(
            name: "ZMarkupParserSnapshotTests",
            dependencies: [
                "ZMarkupParser",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
