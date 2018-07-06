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
            }
        }
    }

    private func interpret(_ exprs: Value) throws -> Value {
        precondition(exprs.isList, "Interpret takes a list of expressions")
        var vals = Value.null
        for expr in exprs {
            vals.prepend(try Evaluator.eval(expr, frame: topFrame))
        }
        return try vals.reversed()
    }

    public func interpret(tokens: [Value]) throws -> Value {
        return try self.interpret(Parser.parse(tokens))
    }

    public func interpret(source: String) throws -> Value {
        return try self.interpret(tokens: Tokenizer(source).array)
    }

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

extension Value {
    public var jedEvalString: String {
        var str = ""
        guard self.isList else {
            preconditionFailure("Can't get the jedEvalString of a non-proper list")
        }

        for val in self {
            let desc = val.description
            if desc != "" {
                str += desc + "\n"
            }
        }
        return str
    }
}
