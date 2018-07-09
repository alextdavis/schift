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
    indirect case pair(car: Value, cdr: Value)
    /// Procedure/closure/lambda.
    indirect case procedure(formals: Value, body: Value, frame: Frame)
    /// Primitively implemented procedure.
    case primitive(([Value]) throws -> Value)
}

// linked list stuff
extension Value {
    /**
     True if the receiver is a proper list. A proper list is define as either `null`, or a
     pair whose `cdr` is a proper list.
     */
    public var isList: Bool {
        var cell = self
        while true {
            switch cell {
            case .null:
                return true
            case .pair(car:_, cdr:let cdr):
                cell = cdr
            default:
                return false
            }
        }
    }

    /**
     Returns the length of the receiver (given it's a proper list).
     
     - Throws: If the receiver is not a proper list.
     */
    public func length() throws -> Int {
        var cell  = self
        var count = 0
        while true {
            switch cell {
            case .null:
                return count
            case .pair(car:_, cdr:let cdr):
                count += 1
                cell = cdr
            default:
                throw Err.notList
            }
        }
    }

    /**
     Returns the car of the receiver (given it's a pair).
     
     - Throws: If `self` is not a pair. 
     */
    public func car() throws -> Value {
        switch self {
        case .pair(car:let car, cdr:_):
            return car
        default:
            throw Err.notPair(self)
        }
    }

    public func cdr() throws -> Value {
        switch self {
        case .pair(car:_, cdr:let cdr):
            return cdr
        default:
            throw Err.notPair(self)
        }
    }

    /**
     Returns the cdr of the receiver (given it's a pair).
     
     - Throws: If `self` is not a pair.
     */
    public func reversed() throws -> Value {
        var reversedList = Value.null
        var oldList      = self
        while true {
            switch oldList {
            case .null:
                return reversedList
            case .pair(car:let car, cdr:let cdr):
                reversedList.prepend(car)
                oldList = cdr
            default:
                throw Err.notList
            }
        }
    }

    /**
     Creates a proper list from the values given.
     */
    @available(*, deprecated) // TODO: Look for places where this would be useful. If none, remove.8
    public static func list(_ values: Value...) -> Value {
        var list = Value.null
        for value in values.reversed() {
            list = .pair(car: value, cdr: list)
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
            return String(int)
        case .double(let dbl):
            return String(dbl)
        case .string(let str):
            return "\"" + str + "\""
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
        case .pair:
            var str  = "("
            var cell = self
            while true {
                switch cell {
                case .pair(car:let car, cdr:let cdr):
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
}

extension Array where Element == Value {
    /**
     Initializes an Array from a proper list.
     
     - Throws: If the passed value is not a proper list.
     */
    public init(_ val: Value) throws {
        var ary  = [Value]()
        var cell = val
        while true {
            switch cell {
            case .null:
                self.init(ary)
                return
            case .pair(car:let car, cdr:let cdr):
                ary.append(car)
                cell = cdr
            default:
                throw Value.Err.notList
            }
        }
        fatalError("Array initializer from value should have never exit the loop.")
    }
}

// Array stuff
extension Value {
    /**
     Creates a Scheme-style proper list from a Swift array. Equivalent to calling
     `Value(array: <arg>, tail: .null)`.
     */
    public init(array ary: [Value]) {
        self.init(array: ary, tail: .null)
    }

    /**
     Creates a Scheme-style list from a Swift array, and the value at the end of the list (i.e. the
     initial value before everything is cons'd onto it).
     */
    public init(array ary: [Value], tail: Value) {
        var list = tail
        for val in ary.reversed() {
            list.prepend(val)
        }
        self = list
    }

    /**
     Cons the item given onto the receiver. Mutates the receiver to be a cons cell whose car is the
     value passed, and whose cdr is the receiver.
     */
    public mutating func prepend(_ new: Value) {
        self = .pair(car: new, cdr: self)
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
            case .pair(car: let car, cdr: let cdr):
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
    /// Returns true if the receiver is of type `null`.
    public var isNull: Bool {
        switch self {
        case .null:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `void`.
    public var isVoid: Bool {
        switch self {
        case .void:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `int`.
    public var isInt: Bool {
        switch self {
        case .int:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `double`.
    public var isDouble: Bool {
        switch self {
        case .double:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `string`.
    public var isString: Bool {
        switch self {
        case .string:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `bool`.
    public var isBool: Bool {
        switch self {
        case .bool:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `open`.
    public var isOpen: Bool {
        switch self {
        case .open:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `close`.
    public var isClose: Bool {
        switch self {
        case .close:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `quote`.
    public var isQuote: Bool {
        switch self {
        case .quote:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `symbol`.
    public var isSymbol: Bool {
        switch self {
        case .symbol:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `pair`.
    public var isPair: Bool {
        switch self {
        case .pair:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `procedure`.
    public var isProcedure: Bool {
        switch self {
        case .procedure:
            return true
        default:
            return false
        }
    }

    /// Returns true if the receiver is of type `primitive`.
    public var isPrimitive: Bool {
        switch self {
        case .primitive:
            return true
        default:
            return false
        }
    }
}
