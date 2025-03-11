// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Legatus",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "Legatus",
            targets: ["Legatus"])
    ],
    dependencies: [
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", exact: "8.1.0")
    ],
    targets: [
        .target(
            name: "Legatus",
            dependencies: [
                .product(name: "SWXMLHash", package: "SWXMLHash")
            ]
        ),
        .testTarget(
            name: "LegatusTests",
            dependencies: ["Legatus"])
    ],
    swiftLanguageModes: [.v6]
)
