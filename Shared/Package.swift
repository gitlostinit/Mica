// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MicaCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "MicaCore", targets: ["MicaCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.4.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0"),
    ],
    targets: [
        .target(
            name: "MicaCore",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            path: "Sources/MicaCore"
        ),
        .testTarget(
            name: "MicaCoreTests",
            dependencies: ["MicaCore"],
            path: "Tests/MicaCoreTests"
        ),
    ]
)
