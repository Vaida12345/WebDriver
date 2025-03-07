// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebDriver",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "WebDriver", targets: ["WebDriver"]),
    ],
    dependencies: [
        .package(url: "https://www.github.com/Vaida12345/FinderItem", from: "1.0.11"),
        .package(url: "https://www.github.com/Vaida12345/Essentials", from: "1.0.18"),
        .package(url: "https://www.github.com/Vaida12345/NativeImage", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "WebDriver", dependencies: ["FinderItem", "Essentials", "NativeImage"], path: "Sources"),
        .executableTarget(name: "Client", dependencies: ["WebDriver", "FinderItem"], path: "Client"),
        .testTarget(name: "WebDriverTests", dependencies: ["WebDriver"], path: "Tests"),
    ]
)
