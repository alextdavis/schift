// swift-tools-version:4.0

import PackageDescription

let package = Package(
        name: "Schift",
        products: [
            .executable(
                    name: "Schift",
                    targets: ["Schift"]
            ),
            .executable(
                    name: "Tokenize",
                    targets: ["Tokenize"]
            ),
            .executable(
                    name: "Parse",
                    targets: ["Parse"]
            ),
            .executable(
                    name: "Benchmark",
                    targets: ["Benchmark"]
            ),
        ],
        dependencies: [
            .package(url: "https://github.com/andybest/linenoise-swift.git", from: "0.0.3"),
        ],
        targets: [
            .target(
                    name: "Interpreter",
                    dependencies: []
            ),
            .target(
                    name: "Tokenize",
                    dependencies: ["Interpreter"]
            ),
            .target(
                    name: "Parse",
                    dependencies: ["Interpreter"]
            ),
            .target(
                    name: "Benchmark",
                    dependencies: ["Interpreter"]
            ),
            .target(
                    name: "Schift",
                    dependencies: ["Interpreter", "LineNoise"]
            ),
        ]
)
