// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZMarkupParser",
    platforms: [.iOS(.v12), .macOS(.v10_14)],
    products: [
        .library(name: "ZMarkupParser", targets: ["ZMarkupParser"])
    ],
    targets: [
        .target(name: "ZMarkupParser", path: "Sources")
    ]
)
