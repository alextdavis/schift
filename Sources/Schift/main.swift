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

//import func POSIX.isatty

func readLine(_ prompt: String) -> String? {
    print(prompt, terminator: "")
    return readLine(strippingNewline: false) //TODO: Handle arrow keys, history, etc.
}

func repl() throws {
    let ipr = Interpreter()
    var tokens = [Value]()
    var lineNo = 0
    print("Schwift v0.0.1")
    defer {
        print("\nExiting...")
    }
    while let line = readLine("[\(lineNo)] Schwift> ") {
        defer {
            lineNo += 1
        }
        tokens = try Tokenizer(line).array

        while try !Parser.hasMatchingParens(tokens: tokens) {
            guard let more = readLine("[\(lineNo)]    ... > ") else {
                break
            }

            tokens += try Tokenizer(more).array
        }
        do {
            print(try ipr.interpret(tokens: tokens).outputString)
        } catch {
            if let kurtErr = error as? KurtError {
                print(kurtErr.message)
            } else {
                print("Problematic error:")
                print(error)
            }
        }
    }
}

func main() throws {
    if CommandLine.arguments.count > 1 {
        let ipr = Interpreter()
        do {
            for path in CommandLine.arguments.dropFirst() {
                print(try ipr.interpret(path: path).outputString)
            }
        } catch {
            if let kurtErr = error as? KurtError {
                print(kurtErr.message)
            } else {
                print("Problematic error:")
                print(error)
            }
        }
        exit(0)
    }

    if isatty(FileHandle.standardInput.fileDescriptor) != 0 {
        try repl()
    }
}

try main()
