// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kite",
    products: [
        .library(
            name: "Kite",
            targets: ["Kite"])
    ],
    dependencies: [
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", exact: "8.1.1")
    ],
    targets: [
        .target(
            name: "Kite",
            dependencies: [
                .product(name: "SWXMLHash", package: "SWXMLHash")
            ]
        ),
        .testTarget(
            name: "KiteTests",
            dependencies: ["Kite"],
            path: "Tests/KiteTests",
            exclude: ["KiteTests.xctestplan"],
            resources: [
                .process("Stubs/BinaryStubs")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
