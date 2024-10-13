// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "CurrencyConverter",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "CurrencyConverter",
            targets: ["CurrencyConverter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "CurrencyConverter",
            dependencies: []),
        .testTarget(
            name: "CurrencyConverterTests",
            dependencies: ["CurrencyConverter"]),
    ]
)
