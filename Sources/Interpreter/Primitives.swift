//
// Created by Alex Davis on 5/27/18.
//

class Primitives {
    static func bindPrimitives(frame: Frame) {
        assert(frame.parent == nil, "`bindPrimitives` must be called with the top frame")

        frame.bind("+", primitive: { args in
            precondition(args.isList, "Primitive found non-list args.")
            var sumInt = 0
            var sumDouble = 0.0
            var isDouble = false

            var consCell: Value = args
            while true {
                if case .null = consCell {
                    break
                }

                switch try! consCell.car() {
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
                    throw Err.addNonNumber(try! consCell.car())
                }
                consCell = try! consCell.cdr()
            }

            if isDouble {
                return Value.double(sumDouble)
            } else {
                return Value.int(sumInt)
            }
        })

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

            guard case .cons(car: let car, cdr: _) = try! args.car() else {
                throw Err.typeError(procedure: "car", expected: "Cons Cell", found: try! args.car())
            }

            return car
        })

        frame.bind("cdr", primitive: { args in
            precondition(args.isList, "Primitive found non-list args.")
            guard try! args.length() == 1 else {
                throw Err.arity(procedure: "cdr", expected: 1, given: try? args.length())
            }

            guard case .cons(car: _, cdr: let cdr) = try! args.car() else {
                throw Err.typeError(procedure: "cdr", expected: "Cons Cell", found: try! args.car())
            }

            return cdr
        })

        frame.bind("cons", primitive: { args in
            precondition(args.isList, "Primitive found non-list args.")
            guard try! args.length() == 2 else {
                throw Err.arity(procedure: "cons", expected: 2, given: try! args.length())
            }

            return try! Value.cons(car: args.car(), cdr: args.cdr().car())
        })
    }
}
