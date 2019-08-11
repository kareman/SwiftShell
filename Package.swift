// swift-tools-version:5.0
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
			name: "SwiftShell",
			swiftSettings: [
				.define("DEBUG", .when(configuration: .debug)),
			]),
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
	swiftLanguageVersions: [.v4_2, .v5]
)
