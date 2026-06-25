// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "CurrencyConverter",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "CurrencyConverter",
            targets: ["CurrencyConverter"]),
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
