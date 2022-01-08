// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "wordle-solver",
	platforms: [
		.iOS(.v9),
		.tvOS(.v9),
		.macOS(.v10_10),
		.watchOS(.v2)
	],
	products: [
		.executable(name: "wordle-solver", targets: ["WordleSolver"]),
		.library(name: "WordleSolverKit", targets: ["WordleSolverKit"])
	],
    dependencies: [],
    targets: [
        .executableTarget(name: "WordleSolver", dependencies: [
			"WordleSolverKit"
		]),
		.target(name: "WordleSolverKit"),
        .testTarget(name: "WordleSolverTests", dependencies: [
			"WordleSolverKit"
		])
    ]
)
