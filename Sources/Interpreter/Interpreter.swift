//
// Created by Alex Davis on 5/27/18.
//

import Foundation

public final class Interpreter {
    private let topFrame: Frame

    public init() {
        topFrame = Frame(parent: nil)
        Primitives.bindPrimitives(frame: topFrame)
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
        return try self.interpret(Parser.parse(Tokenizer(source).array))
    }

    public func interpret(path: String) throws -> Value {
        return try self.interpret(source: String(contentsOfFile: path))
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
