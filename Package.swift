// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SwiftShell",
    products: [
        .library(
            name: "SwiftShell",
            targets: ["SwiftShell"])
    ],
    targets: [
        .target(
            name: "SwiftShell"),
        .testTarget(
            name: "SwiftShellTests",
            dependencies: ["SwiftShell"]),
        .testTarget(
            name: "StreamTests",
            dependencies: ["SwiftShell"]),
        .testTarget(
            name: "GeneralTests",
            dependencies: ["SwiftShell"]),
    ],
    swiftLanguageVersions: [4]
)
