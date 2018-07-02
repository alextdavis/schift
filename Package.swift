// swift-tools-version:4.0

import PackageDescription

let package = Package(
        name: "Kurtscheme",
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
        ],
        targets: [
            .target(
                    name: "Interpreter",
                    dependencies: []
            ),
            .testTarget(
                    name: "LinkedListTests",
                    dependencies: ["Interpreter"]
            ),
            .target(
                    name: "Tokenize",
                    dependencies: ["Interpreter"]
            ),
            .testTarget(
                    name: "TokenizerTests",
                    dependencies: ["Interpreter"]
            ),
            .target(
                    name: "Parse",
                    dependencies: ["Interpreter"]
            ),
            .testTarget(
                    name: "ParserTests",
                    dependencies: ["Interpreter"]
            ),
            .target(
                    name: "Benchmark",
                    dependencies: ["Interpreter"]
            ),
            .target(
                    name: "Schift",
                    dependencies: ["Interpreter"]
            ),
            .testTarget(
                    name: "EvaluatorTests",
                    dependencies: ["Interpreter"]
            ),
        ]
)
