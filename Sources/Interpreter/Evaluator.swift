//
//  Evaluator.swift
//  Interpreter
//
//  Created by Alex Davis on 5/19/18.
//

import Foundation

public final class Evaluator {

    private static func evalIf(_ args: Value, _ frame: Frame) throws -> Value {
        guard try args.length() == 3 else {
            throw Err.arity(procedure: "if", expected: 3, given: try? args.length())
        }

        let testResult = try eval(args.car(), frame: frame)
        if case .bool(false) = testResult {
            return try eval(args.cdr().cdr().car(), frame: frame)
        } else {
            return try eval(args.cdr().car(), frame: frame)
        }
    }

    private static func evalLet(_ args: Value, _ parentFrame: Frame,
                                isStar: Bool, isRec: Bool) throws -> Value {
        assert(!(isStar && isRec), "Can never be letrec*.")

        guard try args.length() == 2 else {
            throw Err.arity(procedure: "let", expected: 2, given: try? args.length())
        }

        let bindings = try args.car()
        let body = try args.cdr().car()

        guard bindings.isList else {
            throw Err.specialForm("First argument in `let` should be a proper list of bindings.")
        }

        var frame = Frame(parent: parentFrame)

        for binding in bindings {
            guard binding.isList, try binding.length() == 2 else {
                throw Err.specialForm("Each binging in `let` must be a proper list of length 2.")
            }

            let x = try binding.car()
            let e = try binding.cdr().car()

            guard try parentFrame.lookupInSingleFrame(symbol: x) == nil else {
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

    private static func evalDef(_ args: Value, _ frame: Frame) throws -> Value {
        guard frame.parent == nil else {
            throw Err.specialForm("`define` can only be called from the top level.")
        }
        guard try args.length() == 2 else {
            throw Err.arity(procedure: "define", expected: 2, given: try? args.length())
        }

        let variable = try args.car()
        let expr = try args.cdr().car()
        let val = try eval(expr, frame: frame)
        try frame.bind(symbol: variable, value: val)

        return Value.void
    }

    private static func evalLambda(_ args: Value, _ frame: Frame) throws -> Value {
        guard try args.length() == 2 else {
            throw Err.arity(procedure: "lambda", expected: 2, given: try? args.length())
        }
        return try Value.procedure(formals: args.car(), body:args.cdr().car(), frame: frame)
    }

    private static func evaLand(_ args: Value, _ frame: Frame) throws -> Value {
        if try args.length() == 0 {
            return Value.bool(true)
        }

        var cell = args
        while try cell.length() > 1 { //TODO make more swifty
            let value = try eval(cell.car(), frame: frame)
            if case .bool(false) = value {
                return value
            }
            cell = try cell.cdr()
        }
        return try eval(cell.car(), frame: frame)
    }

    private static func evalOr(_ args: Value, _ frame: Frame) throws -> Value {
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

    private static func evalCond(_ args: Value, _ frame: Frame) throws -> Value {
        for arg in args {
            guard arg.isList, try arg.length() == 2 else {
                throw Err.specialForm("Each argument to `cond` must be a proper list of length 2.")
            }

            let test = try arg.car()
            let conseq = try arg.cdr().car()

            //TODO FINISH
        }

        return Value.void
    }

    private static func evalSetBang(_ args: Value, _ frame: Frame) throws -> Value {
        guard try args.length() == 2 else {
            throw Err.arity(procedure: "set!", expected: 2, given: try? args.length())
        }

        let variable = try args.car()
        let expr = try args.cdr().car()

        guard case .symbol(let str) = variable else {
            throw Err.specialForm("`set!` expects a symbol as the first argument.")
        }

        guard try Frame.setBang(str, value: try eval(expr, frame: frame), env: frame) else {
            throw Err.specialForm("Tried to `set!` unbound variable.")
        }

        return Value.void
    }

    private static func evalBegin(_ args: Value, _ frame: Frame) throws -> Value {
        var result = Value.void
        for arg in args {
            result = try eval(arg, frame: frame)
        }
        return result
    }

    private static func apply(_ proc: Value, args: Value) throws -> Value {
        if case .primitive(let closure) = proc {
            return try closure(args)
        }

        guard case .procedure(formals:let formals,
                              body:let body,
                              frame:let parentFrame) = proc else {
            throw Err.notProc(proc)
        }
        guard args.isList else {
            throw Err.procArgsNotList
        }

        let newFrame = Frame(parent: parentFrame)

        if formals.isList {
            guard try formals.length() == args.length() else {
                throw Err.arity(procedure: "#<procedure>", //TODO: Include primtive name?
                                expected: try! formals.length(),
                                given: try? args.length())
            }

            guard let formalAry = try? formals.toArray(), let actualAry = try? args.toArray() else {
                preconditionFailure("Args or Formals changed since last check.")
            }

            for i in formalAry.indices {
                try newFrame.bind(symbol: formalAry[i], value: actualAry[i])
            }

        } else if case .symbol(let str) = formals { // Variadic
            newFrame.bind(str, value: args)
        } else {
            throw Err.invalidFormals
        }

        return try eval(body, frame: newFrame)
    }

    static func eval(_ expr: Value, frame: Frame) throws -> Value {
        switch expr {
        case .int, .double, .string, .bool:
            return expr
        case .cons(car:let first, cdr:let args):
            // TODO Godel has `assert(first!=NULL_TYPE)`. This might be necessary, e.g. `()`.

            // Handle Special Forms
            if case .symbol(let sym) = first {
                switch sym {
                case "if":
                    return try evalIf(args, frame)
                case "quote":
                    return try args.car()
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
            switch proc {
            case .procedure, .primitive:
                break
            default:
                throw Err.notProc(proc)
            }

            var actuals = Value.null
            for arg in args {
                actuals.prepend(try eval(arg, frame: frame))
            }

            /* Chunk above replaces this:
            var argsCell = args
            argEvalLoop: while true {
                switch argsCell {
                case .null:
                    break argEvalLoop
                case .cons(car: let car, cdr: let cdr):
                    actuals = .cons(car: try eval(car, frame: frame), cdr: actuals)
                    argsCell = cdr
                default:
                    throw Err.procArgsNotList
                }
            }
            */

            return try apply(proc, args: actuals.reversed())

        case .symbol(let sym):
            return try Frame.lookup(sym, env: frame)
        case .null:
            throw Err.noProc
        case .void, .open, .close, .procedure, .primitive:
            preconditionFailure(
                    "Found Void, Open, Close, Procedure, or Primitive type in Evaluator#eval")
        }
    }
}
