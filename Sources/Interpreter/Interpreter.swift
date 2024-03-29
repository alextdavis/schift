//
//  Schift
//  The Scheme interpreter written in Swift.
//  Created by Alex T. Davis.
//  Based on an implementation in C by Anna S. Johnson, Eva D. Grench, and Alex T. Davis.
//
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation

fileprivate let LibraryPath = "./Library/"

public final class Interpreter {
    public static var `default` = Interpreter()
    private let topFrame: Frame

    public init() {
        topFrame = Frame(parent: nil)

        Primitives.bindPrimitives(frame: topFrame)

        for filename in try! FileManager.default.contentsOfDirectory(atPath: LibraryPath) {
            if filename.hasSuffix(".scm"),
               FileManager.default.isReadableFile(atPath: LibraryPath + filename) {
                _ = try! self.interpret(path: LibraryPath + filename)
            } else {
                print("Warning: Library file `\(filename)` could not be read.")
            }
        }
    }

    /// Evaluates the given list of S-expressions.
    private func interpret(_ exprs: Value) throws -> Value {
        precondition(exprs.isList, "Interpret takes a list of expressions")
        var vals = Value.null
        for expr in exprs {
            vals.prepend(try Evaluator.eval(expr, frame: topFrame))
        }
        return try vals.reversed()
    }

    /// Parses, then evaluates the given array of tokens.
    public func interpret(tokens: [Value]) throws -> Value {
        return try self.interpret(Parser.parse(tokens))
    }

    /// Tokenizes, parses, and evaluates the given string of Scheme source code.
    public func interpret(source: String) throws -> Value {
        return try self.interpret(tokens: Tokenizer(source).array)
    }

    /// Tokenizes, parses, and evaluates the Scheme source file at the given path.
    public func interpret(path: String) throws -> Value {
        let str: String
        do {
            str = try String(contentsOfFile: path)
        } catch {
            print("Error opening file `\(path)`:")
            print(error)
            fatalError()
        }
        return try self.interpret(source: str)
    }
}
