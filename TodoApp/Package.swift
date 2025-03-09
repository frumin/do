// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TodoApp",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(path: "../TodoKit")
    ],
    targets: [
        .executableTarget(
            name: "TodoApp",
            dependencies: ["TodoKit"],
            path: "."
        )
    ]
)
