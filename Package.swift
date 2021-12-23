// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CurrencyConverter",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
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
