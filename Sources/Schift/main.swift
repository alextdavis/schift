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

func repl() throws {
    let ipr = Interpreter()
    var tokens = [Value]()
    var lineNo = 0
    print("Schwift v0.0.1")
    print("[\(lineNo)] Schwift>")
    defer {
        print("Exiting...")
    }
    while let line = readLine(strippingNewline: false) {
        defer {
            lineNo += 1
        }
        tokens = try Tokenizer(line).array

        while try !Parser.hasMatchingParens(tokens: tokens) {
            print("[\(lineNo)]    ... >")
            guard let more = readLine(strippingNewline: false) else {
                break
            }

            tokens += try Tokenizer(more).array
        }

        print(try ipr.interpret(tokens: tokens))
    }
}

func main() throws {
    if CommandLine.arguments.count > 1 {
        let ipr = Interpreter()
        for path in CommandLine.arguments {
            print(try ipr.interpret(path: path))
        }
        exit(0)
    }

    if isatty(FileHandle.standardInput.fileDescriptor) != 0 {
        try repl()
    }
}

try main()
