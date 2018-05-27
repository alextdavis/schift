// swift-tools-version:4.0

import PackageDescription

let package = Package(
        name: "Kurtscheme",
        products: [
//            .executable(
//                    name: "Kurtscheme",
//                    targets: ["Interpreter", "Tokenize"]
//            ),
            .executable(
                    name: "Tokenize",
                    targets: ["Tokenize"]
            ),
            .executable(
                    name: "Parse",
                    targets: ["Parse"]
            ),
            .executable(
                    name: "REPL",
                    targets: ["REPL"]
            ),
        ],
        dependencies: [
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
                name: "REPL",
                dependencies: ["Interpreter"]
            ),
        ]
)
