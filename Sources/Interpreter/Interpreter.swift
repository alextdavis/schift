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

    public func interpret(_ exprs: Value) throws -> Value {
        precondition(exprs.isList, "Interpret takes a list of expressions")
        var vals = Value.null
        for expr in try! exprs.toArray() {
            vals = Value.cons(car: try Evaluator.eval(expr, frame: topFrame), cdr: vals)
        }
        return vals
    }

    public func interpret(source: String) throws -> Value {
        return try self.interpret(Parser.parse(Tokenizer(source).array))
    }
}

extension Value {
    public var jedEvalString: String {
        var str = ""
        var cell = self
        while true {
            switch cell {
            case .cons(car: let car, cdr: let cdr):
                str += car.description + "\n"
                cell = cdr
            case .null:
                return str
            default:
                preconditionFailure("Can't get the jedEvalString of a non-proper list")
            }
        }
    }
}
