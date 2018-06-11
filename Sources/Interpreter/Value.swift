//
//  LinkedList.swift
//  kurtscheme
//
//  Created by Alex Davis on 5/14/18.
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation

public enum Value {
    case null
    case void
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case open
    case close
    case symbol(String)
    indirect case cons(car: Value, cdr: Value)
    indirect case procedure(formals: Value, body: Value, frame: Frame)
    case primitive((Value) throws -> Value)
}

extension Value {
    public static func list(_ values: Value...) -> Value {
        var list = Value.null
        for value in values.reversed() {
            list = Value.cons(car: value, cdr: list)
        }
        return list
    }
}

extension Value {
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

    public var isNull: Bool {
        switch self {
        case .null:
            return true
        default:
            return false
        }
    }

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
                throw Value.Err.notList
            }
        }
    }

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
                reversedList = Value.cons(car: car, cdr: reversedList)
                oldList = cdr
            default:
                throw Err.notList
            }
        }
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
        case .symbol(let str):
            return str
        case .cons(car: _, cdr: _):
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
        case .procedure(formals: _, body: _, frame: _):
            return "#<procedure>"
        case .primitive(_):
            return "#<primitive>"
        }
    }

    public var type: String {
        switch self {
        case .null:
            return "Null"
        case .void:
            return "Void"
        case .int(_):
            return "Int"
        case .double(_):
            return "Double"
        case .string(_):
            return "String"
        case .bool(_):
            return "Bool"
        case .open:
            return "Open"
        case .close:
            return "Close"
        case .symbol(_):
            return "Symbol"
        case .cons(car: _, cdr: _):
            return "Cons"
        case .procedure(formals: _, body: _, frame: _):
            return "Procedure"
        case .primitive(_):
            return "Primitive"
        }
    }
}

//extension Value {
//    static func sameType(_ lhs: Value, _ rhs: Value) -> Bool {
//        switch (lhs, rhs) {
//        case (.null, .null),
//             (.void, .void),
//             (.int, .int),
//             (.double, .double),
//             (.string, .string),
//             (.bool, .bool),
//             (.open, .open),
//             (.close, .close),
//             (.symbol, .symbol),
//             (.cons, .cons),
//             (.procedure, .procedure),
//             (.primitive, .primitive):
//            return true
//        default:
//            return false
//        }
//    }
//}

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
        var list = Value.null
        for val in ary.reversed() {
            list = Value.cons(car: val, cdr: list)
        }
        self = list
    }

    public init(array ary: [Value], start: Value) {
        var list = start
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
