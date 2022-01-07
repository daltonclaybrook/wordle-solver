// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "wordle-solver",
	products: [
		.executable(name: "wordle-solver", targets: ["WordleSolver"])
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
