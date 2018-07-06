//
//  Schift
//  The Scheme interpreter written in Swift.
//  Created by Alex T. Davis.
//  Based on an implementation in C by Anna S. Johnson, Eva D. Grench, and Alex T. Davis.
//
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation

class Primitives {
    static func bindPrimitives(frame: Frame) {
        assert(frame.parent == nil, "`bindPrimitives` must be called with the top frame")

        frame.bind("null?", primitive: isNull)
        frame.bind("car", primitive: car)
        frame.bind("cdr", primitive: cdr)
        frame.bind("cons", primitive: cons)
        frame.bind("+", primitive: add)
        frame.bind("-", primitive: subtract)
        frame.bind("*", primitive: multiply)
        frame.bind("/", primitive: divide)
        frame.bind("<=", primitive: leq)
        frame.bind("=", primitive: equalsSign)
        frame.bind("eq?", primitive: isEq)
        frame.bind("append", primitive: append)
        frame.bind("apply", primitive: apply)
        frame.bind("pair?", primitive: isPair)
        frame.bind("integer?", primitive: isInteger)
        frame.bind("double?", primitive: isDouble)
        frame.bind("floor", primitive: primitiveFloor)
        frame.bind("list?", primitive: isList)
        frame.bind("load", primitive: load)
        frame.bind("reverse", primitive: reverse)
        frame.bind("length", primitive: length)
    }

    private static func isNull(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "null?", expected: 1, given: args.count)
        }

        return Value.bool(args.first!.isNull)
    }

    private static func car(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "car", expected: 1, given: args.count)
        }

        guard case .cons(car: let car, cdr: _) = args.first! else {
            throw Err.typeError(procedure: "car", expected: "Cons Cell", found: args.first!)
        }

        return car
    }

    private static func cdr(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "cdr", expected: 1, given: args.count)
        }

        guard case .cons(car: _, cdr: let cdr) = args.first! else {
            throw Err.typeError(procedure: "cdr", expected: "Cons Cell", found: args.first!)
        }

        return cdr
    }

    private static func cons(_ args: [Value]) throws -> Value {
        guard args.count == 2 else {
            throw Err.arity(procedure: "cons", expected: 2, given: args.count)
        }

        return Value.cons(car: args.first!, cdr: args.dropFirst().first!)
    }

    private static func add(_ args: [Value]) throws -> Value {
        var sumInt    = 0
        var sumDouble = 0.0
        var isDouble  = false

        for arg in args {
            switch arg {
            case .int(let int) where !isDouble:
                sumInt += int
            case .double(let dbl) where !isDouble:
                sumDouble = Double(sumInt) + dbl
                isDouble = true
            case .double(let dbl) where isDouble:
                sumDouble += dbl
            case .int(let int) where isDouble:
                sumDouble += Double(int)
            default:
                throw Err.mathNonNumber(arg)
            }
        }

        if isDouble {
            return Value.double(sumDouble)
        } else {
            return Value.int(sumInt)
        }
    }

    private static func subtract(_ args: [Value]) throws -> Value {
        guard args.count > 0 else {
            throw Err.arity(procedure: "-", expected: 1..., given: args.count)
        }

        if args.count == 1 {
            switch args.first! {
            case .double(let dbl):
                return Value.double(-dbl)
            case .int(let int):
                return Value.int(-int)
            default:
                throw Err.mathNonNumber(args.first!)
            }
        }

        var diffInt    = 0
        var diffDouble = 0.0
        var isDouble: Bool

        switch args.first! {
        case .double(let dbl):
            diffDouble = dbl
            isDouble = true
        case .int(let int):
            diffInt = int
            isDouble = false
        default:
            throw Err.mathNonNumber(args.first!)
        }

        for arg in args.dropFirst() {
            switch arg {
            case .int(let int) where !isDouble:
                diffInt -= int
            case .double(let dbl) where !isDouble:
                diffDouble = Double(diffInt) - dbl
                isDouble = true
            case .double(let dbl) where isDouble:
                diffDouble -= dbl
            case .int(let int) where isDouble:
                diffDouble -= Double(int)
            default:
                throw Err.mathNonNumber(arg)
            }
        }

        if isDouble {
            return .double(diffDouble)
        } else {
            return .int(diffInt)
        }
    }

    private static func multiply(_ args: [Value]) throws -> Value {
        var prodInt    = 1
        var prodDouble = 1.0
        var isDouble   = false

        for arg in args {
            switch arg {
            case .int(let int) where !isDouble:
                prodInt *= int
            case .double(let dbl) where !isDouble:
                prodDouble = Double(prodInt) * dbl
                isDouble = true
            case .double(let dbl) where isDouble:
                prodDouble *= dbl
            case .int(let int) where isDouble:
                prodDouble *= Double(int)
            default:
                throw Err.mathNonNumber(arg)
            }
        }

        if isDouble {
            return .double(prodDouble)
        } else {
            return .int(prodInt)
        }
    }

    private static func divide(_ args: [Value]) throws -> Value {
        guard args.count > 0 else {
            throw Err.arity(procedure: "-", expected: 1..., given: args.count)
        }

        if args.count == 1 {
            switch args.first! {
            case .double(let dbl):
                if dbl == 0 {
                    throw Err.divideByZero
                }
                return .double(1.0 / dbl)
            case .int(let int):
                if int == 0 {
                    throw Err.divideByZero
                }
                return .double(1.0 / Double(int))
            default:
                throw Err.mathNonNumber(args.first!)
            }
        }

        let numerValue = args.first!
        let denomValue = try multiply(Array(args.dropFirst()))

        if case .int(let int) = denomValue, int == 0 {
            throw Err.divideByZero
        }
        if case .double(let dbl) = denomValue, dbl == 0 {
            throw Err.divideByZero
        }

        switch (numerValue, denomValue) {
        case (.int(let numer), .int(let denom)):
            if numer % denom == 0 {
                return .int(numer / denom)
            } else {
                return .double(Double(numer) / Double(denom))
            }
        case (.double(let numer), .int(let denom)):
            return .double(numer / Double(denom))
        case (.int(let numer), .double(let denom)):
            return .double(Double(numer) / denom)
        case (.double(let numer), .double(let denom)):
            return .double(numer / denom)
        case (.int, _),
             (.double, _):
            throw Err.mathNonNumber(denomValue)
        default:
            throw Err.mathNonNumber(numerValue)
        }
    }

    private static func leq(_ args: [Value]) throws -> Value {
        guard args.count >= 2 else {
            throw Err.arity(procedure: "<=", expected: 2..., given: args.count)
        }

        for i in args.startIndex..<args.index(before: args.endIndex) {
            switch (args[i], args[i + 1]) {
            case (.int(let lint), .int(let rint)):
                guard lint <= rint else {
                    return .bool(false)
                }
            case (.double(let ldbl), .int(let rint)):
                guard ldbl <= Double(rint) else {
                    return .bool(false)
                }
            case (.int(let lint), .double(let rdbl)):
                guard Double(lint) <= rdbl else {
                    return .bool(false)
                }
            case (.double(let ldbl), .double(let rdbl)):
                guard ldbl <= rdbl else {
                    return .bool(false)
                }
            case (.int, _),
                 (.double, _):
                throw Err.mathNonNumber(args[args.index(after: i)])
            default:
                throw Err.mathNonNumber(args[i])
            }
        }
        return .bool(true)
    }

    private static func isEq(_ args: [Value]) throws -> Value {
        guard args.count == 2 else {
            throw Err.arity(procedure: "eq?", expected: 2, given: args.count)
        }

        let (lhs, rhs) = args.firstTwo!

        switch (lhs, rhs) {
        case (.symbol(let lstr), .symbol(let rstr)),
             (.string(let lstr), .string(let rstr)):
            return .bool(lstr == rstr)
        case (.int(let lint), .int(let rint)):
            return .bool(lint == rint)
        case (.double(let ldbl), .double(let rdbl)):
            return .bool(ldbl == rdbl)
        case (.bool(let lbool), .bool(let rbool)):
            return .bool(lbool == rbool)
        case (.cons, .cons),
             (.primitive, .primitive),
             (.procedure, .procedure):
            return .bool(false)
        case (.null, .null):
            return .bool(true)
        case (.void, _),
             (_, .void):
            fatalError("`define` not allowed in expression context")
        default:
            return .bool(false)
        }
    }

    private static func equalsSign(_ args: [Value]) throws -> Value {
        guard args.count >= 2 else {
            throw Err.arity(procedure: "=", expected: 2..., given: args.count)
        }

        for i in args.startIndex..<args.index(before: args.endIndex) {

            switch (args[i], args[i + 1]) {
            case (.int(let lint), .int(let rint)):
                guard lint == rint else {
                    return .bool(false)
                }
            case (.double(let ldbl), .int(let rint)):
                guard ldbl == Double(rint) else {
                    return .bool(false)
                }
            case (.int(let lint), .double(let rdbl)):
                guard Double(lint) == rdbl else {
                    return .bool(false)
                }
            case (.double(let ldbl), .double(let rdbl)):
                guard ldbl == rdbl else {
                    return .bool(false)
                }
            case (.int, _),
                 (.double, _):
                throw Err.mathNonNumber(args[i + 1])
            default:
                throw Err.mathNonNumber(args[i])
            }
        }
        return .bool(true)
    }

    private static func apply(_ args: [Value]) throws -> Value {
        guard args.count == 2 else {
            throw Err.arity(procedure: "apply", expected: 2, given: args.count)
        }

        let (proc, argsList) = args.firstTwo!

        guard proc.isProcedure || proc.isPrimitive else {
            throw Err.typeError(procedure: "apply", expected: "procedure or primitive", found: proc)
        }

        guard let argsAry = try? argsList.toArray() else {
            throw Err.typeError(procedure: "apply", expected: "a list of arguments",
                                found: argsList)
        }

        return try Evaluator.apply(proc, actuals: argsAry)
    }

    private static func isPair(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "pair?", expected: 1, given: args.count)
        }

        switch args.first! {
        case .cons:
            return .bool(true)
        default:
            return .bool(false)
        }
    }

    private static func append(_ args: [Value]) throws -> Value {
        var bigAry       = [Value]()
        var last: Value? = nil
        for arg in args {
            if arg.isList {
                bigAry.append(contentsOf: try! arg.toArray())
            } else {
                guard last == nil else {
                    throw Err.typeError(procedure: "append",
                                        expected: "proper list (for all but the last element)",
                                        found: arg)
                }
                last = arg
            }
        }

        if last != nil {
            return Value(array: bigAry, tail: last!)
        } else {
            return Value(array: bigAry)
        }
    }

    private static func primitiveFloor(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "floor", expected: 1, given: args.count)
        }

        switch args.first! {
        case .double(let dbl):
            return .int(Int(floor(dbl)))
        case .int(let int):
            return .int(int)
        default:
            throw Err.mathNonNumber(args.first!)
        }
    }

    private static func isInteger(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "integer?", expected: 1, given: args.count)
        }

        switch args.first! {
        case .double(let dbl):
            return .bool(floor(dbl) == dbl)
        case .int:
            return .bool(true)
        default:
            return .bool(false)
        }
    }

    private static func isDouble(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "double?", expected: 1, given: args.count)
        }

        switch args.first! {
        case .double:
            return .bool(true)
        default:
            return .bool(false)
        }
    }

    private static func isList(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "list?", expected: 1, given: args.count)
        }

        return .bool(args.first!.isList)
    }

    private static func load(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "load", expected: 1, given: args.count)
        }
        guard case .string(let path) = args.first! else {
            throw Err.typeError(procedure: "load", expected: "File path string",
                                found: args.first!)
        }

        _ = try Interpreter.default.interpret(path: path)
        return .void
    }

    private static func reverse(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "reverse", expected: 1, given: args.count)
        }
        guard args.first!.isList else {
            throw Err.typeError(procedure: "reverse", expected: "Proper list",
                                found: args.first!)
        }

        return try args.first!.reversed()
    }

    private static func length(_ args: [Value]) throws -> Value {
        guard args.count == 1 else {
            throw Err.arity(procedure: "length", expected: 1, given: args.count)
        }
        guard args.first!.isList else {
            throw Err.typeError(procedure: "length", expected: "Proper list", found: args.first!)
        }

        return try .int(args.first!.length())
    }
}
