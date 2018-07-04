//
// Created by alex on 6/14/18.
//

import Foundation

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

import Interpreter
import LineNoise

let ln = LineNoise()

func readLine(_ prompt: String) -> String? {
    let line = try? ln.getLine(prompt: prompt)
    ln.addHistory(line ?? "")
    print("")
    return line
}

func printOnError(_ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        if let kurtErr = error as? KurtError {
            print(kurtErr.message)
        } else {
            print("Problematic error:")
            print(error)
            exit(1)
        }
    }
}

func repl() throws {
    let ipr    = Interpreter.default
    var tokens = [Value]()
    var lineNo = 0
    print("Schift v0.0.1")

    while let line = readLine("[\(lineNo)] Schift> ") {
        printOnError() {
            defer {
                lineNo += 1
            }
            tokens = try Tokenizer(line).array

            while try !Parser.hasMatchingParens(tokens: tokens) {
                guard let more = readLine("[\(lineNo)]   ... > ") else {
                    break
                }

                tokens += try Tokenizer(more).array
            }

            print(try ipr.interpret(tokens: tokens).outputString)
        }
    }
}

func main() throws {
    if CommandLine.arguments.count > 1 {
        for path in CommandLine.arguments.dropFirst() {
            guard FileManager.default.isReadableFile(atPath: path) else {
                print("Error: File `\(path)` does not exist or is not readable.")
                exit(1)
            }
        }

        let ipr = Interpreter.default
        printOnError() {
            for path in CommandLine.arguments.dropFirst() {
                print(try ipr.interpret(path: path).outputString)
            }
        }
        exit(0)
    }

    if isatty(FileHandle.standardInput.fileDescriptor) != 0
       || ProcessInfo.processInfo.environment["INTERACTIVE"] != nil {
        try repl()
    }
}

try main()
