//
// Created by Alex Davis on 5/27/18.
//

class Primitives {
    static func bindPrimitives(frame: Frame) {
        assert(frame.parent == nil, "`bindPrimitives` must be called with the top frame")

        frame.bind("null?", primitive: { args in
            precondition(args.isList, "Primitive found non-list args.")
            guard try! args.length() == 1 else {
                throw Err.arity(procedure: "null?", expected: 1, given: try? args.length())
            }

            return Value.bool(try args.car().isNull)
        })

        frame.bind("car", primitive: { args in
            precondition(args.isList, "Primitive found non-list args.")
            guard try! args.length() == 1 else {
                throw Err.arity(procedure: "car", expected: 1, given: try? args.length())
            }

            guard case .cons(car:let car, cdr:_) = try! args.car() else {
                throw Err.typeError(procedure: "car", expected: "Cons Cell", found: try! args.car())
            }

            return car
        })

        frame.bind("cdr", primitive: { args in
            precondition(args.isList, "Primitive found non-list args.")
            guard try! args.length() == 1 else {
                throw Err.arity(procedure: "cdr", expected: 1, given: try? args.length())
            }

            guard case .cons(car:_, cdr:let cdr) = try! args.car() else {
                throw Err.typeError(procedure: "cdr", expected: "Cons Cell", found: try! args.car())
            }

            return cdr
        })

        frame.bind("cons", primitive: { args in
            precondition(args.isList, "Primitive found non-list args.")
            guard try! args.length() == 2 else {
                throw Err.arity(procedure: "cons", expected: 2, given: try! args.length())
            }

            return try! Value.cons(car: args.car(), cdr:args.cdr().car())
        })

        frame.bind("+", primitive: { args in
            precondition(args.isList, "Primitive found non-list args.")
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
        })

        frame.bind("-", primitive: { args in
            guard try args.length() > 0 else {
                throw Err.arity(procedure: "-", expected: 1..., given: try args.length())
            }

            let first = try args.car()

            if try args.length() == 1 {
                switch first {
                case .double(let dbl):
                    return Value.double(dbl)
                case .int(let int):
                    return Value.int(int)
                default:
                    throw Err.mathNonNumber(first)
                }
            }

            var diffInt = 0
            var diffDouble = 0.0
            var isDouble:   Bool

            switch first {
            case .double(let dbl):
                diffDouble = dbl
                isDouble = true
            case .int(let int):
                diffInt = int
                isDouble = false
            default:
                throw Err.mathNonNumber(first)
            }

            for arg in try args.cdr() {
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
        })

        frame.bind("*", primitive: { args in
            var prodInt = 1
            var prodDouble = 1.0
            var isDouble = false

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
        })

//        frame.bind("/", primitive: { args in
//            guard try args.length() > 0 else {
//                throw Err.arity(procedure: "-", expected: 1..., given: try args.length())
//            }
//
//            if try args.length() == 1 {
//                switch try args.car() {
//                case .double(let dbl):
//                    if dbl == 0 {
//                        throw Err.divideByZero
//                    }
//                    return .double(1.0/dbl)
//                case .int(let int):
//                    if int == 0 {
//                        throw Err.divideByZero
//                    }
//                    return .double(1.0/int)
//                default:
//                    throw Err.mathNonNumber(try args.car())
//                }
//            }
//
//            let numerValue = try args.car()
//            var
//        })
    }
}
