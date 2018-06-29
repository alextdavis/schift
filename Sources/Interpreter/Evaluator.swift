//
//  Evaluator.swift
//  Interpreter
//
//  Created by Alex Davis on 5/19/18.
//

import Foundation

public final class Evaluator {

    private static func evalIf(_ args: [Value], _ frame: Frame) throws -> Value {
        guard args.count == 3 else {
            throw Err.arity(procedure: "if", expected: 3, given: args.count)
        }

        let testResult = try eval(args[0], frame: frame)
        if case .bool(false) = testResult {
            return try eval(args[2], frame: frame)
        } else {
            return try eval(args[1], frame: frame)
        }
    }

    private static func evalLet(_ args: [Value], _ parentFrame: Frame,
                                isStar: Bool, isRec: Bool) throws -> Value {
        assert(!(isStar && isRec), "Can never be letrec*.")

        guard args.count == 2 else {
            throw Err.arity(procedure: "let", expected: 2, given: args.count)
        }

        let bindings = args[0]
        let body = args[1]

        guard bindings.isList else {
            throw Err.specialForm("First argument in `let` should be a proper list of bindings.")
        }

        var frame = Frame(parent: parentFrame)

        for binding in bindings {
            guard let ary = try? binding.toArray(), ary.count == 2 else {
                throw Err.specialForm("Each binging in `let` must be a proper list of length 2.")
            }

            let x = ary[0]
            let e = ary[1]

            guard try frame.lookupInSingleFrame(symbol: x) == nil else {
                throw Err.specialForm("Duplicate identifier in `let`: `\(x)`")
            }

            if isRec {
                try frame.bind(symbol: x, value: eval(e, frame: frame))
            } else {
                try frame.bind(symbol: x, value: eval(e, frame: frame.parent!))
            }

            if isStar {
                frame = Frame(parent: frame)
            }
        }

        return try eval(body, frame: frame)
    }

    private static func evalDef(_ args: [Value], _ frame: Frame) throws -> Value {
        guard frame.parent == nil else {
            throw Err.specialForm("`define` can only be called from the top level.")
        }
        guard args.count == 2 else {
            throw Err.arity(procedure: "define", expected: 2, given: args.count)
        }

        let variable = args[0]
        let expr = args[1]
        let val = try eval(expr, frame: frame)
        try frame.bind(symbol: variable, value: val)

        return Value.void
    }

    private static func evalLambda(_ args: [Value], _ frame: Frame) throws -> Value {
        guard args.count == 2 else {
            throw Err.arity(procedure: "lambda", expected: 2, given: args.count)
        }
        return Value.procedure(formals: args[0], body: args[1], frame: frame)
    }

    private static func evaLand(_ args: [Value], _ frame: Frame) throws -> Value {
        if args.count == 0 {
            return Value.bool(true)
        }

        for arg in args.dropLast() {
            let value = try eval(arg, frame: frame)
            if case .bool(false) = value {
                return value
            }
        }
        return try eval(args.last!, frame: frame)
    }

    private static func evalOr(_ args: [Value], _ frame: Frame) throws -> Value {
        for expr in args {
            let value = try eval(expr, frame: frame)
            if case .bool(false) = value {
                continue
            } else {
                return value
            }
        }
        return Value.bool(false)
    }

    private static func evalCond(_ args: [Value], _ frame: Frame) throws -> Value {
        for i in args.indices {
            let arg = args[i]
            guard arg.isList, try arg.length() == 2 else {
                throw Err.specialForm("Each argument to `cond` must be a proper list of length 2.")
            }

            let test = try arg.car()
            let conseq = try arg.cdr().car()

            if case .symbol(let str) = test, str == "else" {
                if i != args.index(before: args.endIndex) {
                    throw Err.specialForm("`else` must be the last condition in `cond`.")
                } else {
                    return try eval(conseq, frame: frame)
                }
            }

            let testResult = try eval(test, frame: frame)
            if case .bool(false) = testResult {
                continue
            } else {
                return try eval(conseq, frame: frame)
            }
        }

        return Value.void
    }

    private static func evalSetBang(_ args: [Value], _ frame: Frame) throws -> Value {
        guard args.count == 2 else {
            throw Err.arity(procedure: "set!", expected: 2, given: args.count)
        }

        let variable = args[0]
        let expr = args[1]

        guard case .symbol(let str) = variable else {
            throw Err.specialForm("`set!` expects a symbol as the first argument.")
        }

        guard try Frame.setBang(str, value: try eval(expr, frame: frame), env: frame) else {
            throw Err.specialForm("Tried to `set!` unbound variable.")
        }

        return Value.void
    }

    private static func evalBegin(_ args: [Value], _ frame: Frame) throws -> Value {
        var result = Value.void
        for arg in args {
            result = try eval(arg, frame: frame)
        }
        return result
    }

    static func apply(_ proc: Value, actuals: [Value]) throws -> Value {
        if case .primitive(let closure) = proc {
            return try closure(actuals)
        }

        guard case .procedure(formals:let formals,
                              body:let body,
                              frame:let parentFrame) = proc else {
            throw Err.notProc(proc)
        }
//        guard args.isList else {
//            throw Err.procArgsNotList
//        }

        let newFrame = Frame(parent: parentFrame)

        if let formalAry = try? formals.toArray() {
//            let actualAry = try! args.toArray()

            guard formalAry.count == actuals.count else {
                throw Err.arity(procedure: "#<procedure>", //TODO: Include procedure name?
                                expected: formalAry.count,
                                given: actuals.count)
            }

            for i in formalAry.indices {
                try newFrame.bind(symbol: formalAry[i], value: actuals[i])
            }

        } else if case .symbol(let str) = formals { // Variadic
            newFrame.bind(str, value: Value(array: actuals))
        } else {
            throw Err.invalidFormals
        }

        return try eval(body, frame: newFrame)
    }

    static func eval(_ expr: Value, frame: Frame) throws -> Value {
        switch expr {
        case .int, .double, .string, .bool:
            return expr
        case .cons(car:let first, cdr:let cdr):
            let args = try! cdr.toArray()

            // Handle Special Forms
            if case .symbol(let sym) = first {
                switch sym {
                case "if":
                    return try evalIf(args, frame)
                case "quote":
                    return args[0]
                case "let":
                    return try evalLet(args, frame, isStar: false, isRec: false)
                case "let*":
                    return try evalLet(args, frame, isStar: true, isRec: false)
                case "letrec":
                    return try evalLet(args, frame, isStar: false, isRec: true)
                case "define":
                    return try evalDef(args, frame)
                case "lambda":
                    return try evalLambda(args, frame)
                case "and":
                    return try evaLand(args, frame)
                case "or":
                    return try evalOr(args, frame)
                case "cond":
                    return try evalCond(args, frame)
                case "set!":
                    return try evalSetBang(args, frame)
                case "begin":
                    return try evalBegin(args, frame)
                default:
                    break
                }
            }

            // Evaluate procedure
            let proc = try eval(first, frame: frame)

            guard proc.isProcedure || proc.isPrimitive else {
                throw Err.notProc(proc)
            }

            let actuals = try args.map {
                try eval($0, frame: frame)
            }

            return try apply(proc, actuals: actuals)

        case .symbol(let sym):
            return try Frame.lookup(sym, env: frame)
        case .null:
            throw Err.noProc
        case .void, .open, .close, .quote, .procedure, .primitive:
            preconditionFailure("Found Void, Open, Close, Quote, Procedure, or Primitive type " +
                                "in Evaluator#eval")
        }
    }
}
