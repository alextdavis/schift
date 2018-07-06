//
//  Schift
//  The Scheme interpreter written in Swift.
//  Created by Alex T. Davis.
//  Based on an implementation in C by Anna S. Johnson, Eva D. Grench, and Alex T. Davis.
//
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation

//TODO IDEA: Make class which is a view into an immutable Value which it tests at runtime to be a
// proper list. Then have it implement protocols.

public enum Value {
    /// Null, the beginning of a proper list.
    case null
    /// Void, the type returned by the likes of `define`.
    case void
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    /// Open Parenthesis token.
    case open
    /// Close Parenthesis token.
    case close
    /// Quote (`'`) token.
    case quote
    /// Symbol/Identifier.
    case symbol(String)
    /// Pair or Cons Cell.
    indirect case cons(car: Value, cdr: Value)
    /// Procedure/closure/lambda.
    indirect case procedure(formals: Value, body: Value, frame: Frame)
    /// Primitively implemented procedure.
    case primitive(([Value]) throws -> Value)
}

// linked list stuff
extension Value {
    /**
     True if `self` is a proper list. A proper list is define as either `null`, or a pair whose
     `cdr` is a proper list.
     */
    public var isList: Bool {
        var cell = self
        while true {
            switch cell {
            case .null:
                return true
            case .cons(car:_, cdr:let cdr):
                cell = cdr
            default:
                return false
            }
        }
    }

    /**
     Returns the length of the proper list `self`.
     
     - Throws: If `self` is not a proper list.
     */
    public func length() throws -> Int {
        var cell  = self
        var count = 0
        while true {
            switch cell {
            case .null:
                return count
            case .cons(car:_, cdr:let cdr):
                count += 1
                cell = cdr
            default:
                throw Err.notList
            }
        }
    }

    /**
     Returns the car of the pair `self`.
     
     - Throws: If `self` is not a pair. 
     */
    public func car() throws -> Value {
        switch self {
        case .cons(car:let car, cdr:_):
            return car
        default:
            throw Err.notCons(self)
        }
    }

    public func cdr() throws -> Value {
        switch self {
        case .cons(car:_, cdr:let cdr):
            return cdr
        default:
            throw Err.notCons(self)
        }
    }

    public func reversed() throws -> Value {
        var reversedList = Value.null
        var oldList      = self
        while true {
            switch oldList {
            case .null:
                return reversedList
            case .cons(car:let car, cdr:let cdr):
                reversedList.prepend(car)
                oldList = cdr
            default:
                throw Err.notList
            }
        }
    }

    public static func list(_ values: Value...) -> Value {
        var list = Value.null
        for value in values.reversed() {
            list = .cons(car: value, cdr: list)
        }
        return list
    }
}

extension Value: CustomStringConvertible {
    public var description: String {
        switch self {
        case .null:
            return "()"
        case .void:
            return ""
        case .int(let int):
            return int.description
        case .double(let dbl):
            return dbl.description
        case .string(let str):
            return "\"" + str.description + "\""
        case .bool(let bool):
            return bool ? "#t" : "#f"
        case .open:
            return "("
        case .close:
            return ")"
        case .quote:
            return "'"
        case .symbol(let str):
            return str
        case .cons:
            var str  = "("
            var cell = self
            while true {
                switch cell {
                case .cons(car:let car, cdr:let cdr):
                    str += car.description + " "
                    cell = cdr
                case .null:
                    if str.last == " " {
                        str.removeLast()
                    }
                    return str + ")"
                default:
                    return str + ". " + cell.description + ")"
                }
            }
        case .procedure:
            return "#<procedure>"
        case .primitive:
            return "#<primitive>"
        }
    }

    public var type: String {
        switch self {
        case .null:
            return "Null"
        case .void:
            return "Void"
        case .int:
            return "Int"
        case .double:
            return "Double"
        case .string:
            return "String"
        case .bool:
            return "Bool"
        case .open:
            return "Open"
        case .close:
            return "Close"
        case .quote:
            return "Quote"
        case .symbol:
            return "Symbol"
        case .cons:
            return "Cons"
        case .procedure:
            return "Procedure"
        case .primitive:
            return "Primitive"
        }
    }

    public var outputString: String {
        precondition(self.isList, "Cannot print a non-list in the output format")
        let ary = try! self.toArray()
        return ary.filter({
            switch $0 {
            case .void:
                return false
            default:
                return true
            }
        }).joinedStrings(separator: "\n")
    }
}

/*
extension Value {
    static func sameType(_ lhs: Value, _ rhs: Value) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null),
             (.void, .void),
             (.int, .int),
             (.double, .double),
             (.string, .string),
             (.bool, .bool),
             (.open, .open),
             (.close, .close),
             (.symbol, .symbol),
             (.cons, .cons),
             (.procedure, .procedure),
             (.primitive, .primitive):
            return true
        default:
            return false
        }
    }
}
*/

// Array stuff
extension Value {
    public func toArray() throws -> [Value] {
        var ary  = [Value]()
        var cell = self
        while true {
            switch cell {
            case .null:
                return ary
            case .cons(car:let car, cdr:let cdr):
                ary.append(car)
                cell = cdr
            default:
                throw Err.notList
            }
        }
    }

    public init(array ary: [Value]) {
        self.init(array: ary, tail: .null)
    }

    public init(array ary: [Value], tail: Value) {
        var list = tail
        for val in ary.reversed() {
            list = .cons(car: val, cdr: list)
        }
        self = list
    }

    public mutating func prepend(_ new: Value) {
        self = .cons(car: new, cdr: self)
    }
}

extension Value: Sequence {
    public struct ValueIterator: IteratorProtocol {
        var value: Value

        init(_ value: Value) {
            self.value = value
        }

        public mutating func next() -> Value? {
            switch value {
            case .null:
                return nil
            case .cons(car:let car, cdr:let cdr):
                defer {
                    value = cdr
                }
                return car
            default:
                return nil
            }
        }
    }

    public func makeIterator() -> ValueIterator {
        return ValueIterator(self)
    }
}

// `isNull`, etc.
extension Value {
    public var isNull: Bool {
        switch self {
        case .null:
            return true
        default:
            return false
        }
    }

    public var isVoid: Bool {
        switch self {
        case .void:
            return true
        default:
            return false
        }
    }

    public var isInt: Bool {
        switch self {
        case .int:
            return true
        default:
            return false
        }
    }

    public var isDouble: Bool {
        switch self {
        case .double:
            return true
        default:
            return false
        }
    }

    public var isString: Bool {
        switch self {
        case .string:
            return true
        default:
            return false
        }
    }

    public var isBool: Bool {
        switch self {
        case .bool:
            return true
        default:
            return false
        }
    }

    public var isOpen: Bool {
        switch self {
        case .open:
            return true
        default:
            return false
        }
    }

    public var isClose: Bool {
        switch self {
        case .close:
            return true
        default:
            return false
        }
    }

    public var isQuote: Bool {
        switch self {
        case .quote:
            return true
        default:
            return false
        }
    }

    public var isSymbol: Bool {
        switch self {
        case .symbol:
            return true
        default:
            return false
        }
    }

    public var isCons: Bool {
        switch self {
        case .cons:
            return true
        default:
            return false
        }
    }

    public var isProcedure: Bool {
        switch self {
        case .procedure:
            return true
        default:
            return false
        }
    }

    public var isPrimitive: Bool {
        switch self {
        case .primitive:
            return true
        default:
            return false
        }
    }
}
