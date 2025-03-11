// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kite",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .driverKit(.v19),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Kite",
            targets: ["Kite"])
    ],
    dependencies: [
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", exact: "8.1.0")
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
            exclude: [
                "KiteTests.xctestplan"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
