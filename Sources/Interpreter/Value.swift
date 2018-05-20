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
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case open
    case close
    case symbol(String)
    indirect case cons(car: Value, cdr: Value)

    public var length: Int {
        switch self {
        case .null:
            return 0
        case .cons(car: _, cdr: let cdr):
            return 1 + cdr.length
        default:
            preconditionFailure("Can't find the length of a non-list")
        }
    }

    public func reversed() -> Value {
        var reversedList = Value.null
        var oldList = self
        while true {
            switch oldList {
            case .null:
                return reversedList
            case .cons(car: let car, cdr: let cdr):
                reversedList = Value.cons(car: car, cdr: reversedList)
                oldList = cdr
            default:
                preconditionFailure("Tried to reverse non-list")
            }
        }
    }

    public var car: Value {
        switch self {
        case .cons(car: let car, cdr: _):
            return car
        default:
            preconditionFailure("Tried to take the car of a non-cons.")
        }
    }

    public var cdr: Value {
        switch self {
        case .cons(car: _, cdr: let cdr):
            return cdr
        default:
            preconditionFailure("Tried to take the cdr of a non-cons.")
        }
    }
}

extension Value: CustomStringConvertible {
    public var description: String {
        switch self {
        case .null:
            return "()"
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
            var str = "("
            var cell = self
            while true {
                switch cell {
                case .cons(car: let car, cdr: let cdr):
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
        }
    }
}

extension Value {
    public func toArray() -> [Value]? {
        var ary = [Value]()
        var cell = self
        while true {
            switch cell {
            case .null:
                return ary
            case .cons(car: let car, cdr: let cdr):
                ary.append(car)
                cell = cdr
            default:
                assertionFailure("Tried to convert a non-proper list to array.")
                return nil
            }
        }
    }
}
