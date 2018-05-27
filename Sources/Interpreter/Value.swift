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
    indirect case closure(formals: Value, body: Value, frame: Frame)
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
            case .cons(car: _, cdr: let cdr):
                cell = cdr
            default:
                return false
            }
        }
    }
    
    public func length() throws -> Int {
        var cell = self
        var count = 0
        while true {
            switch cell {
            case .null:
                return count
            case .cons(car: _, cdr: let cdr):
                count += 1
                cell = cdr
            default:
                throw Value.Err.notList
            }
        }
    }
    
    public func car() throws -> Value {
        switch self {
        case .cons(car: let car, cdr: _):
            return car
        default:
            throw Err.notCons(self)
        }
    }
    
    public func cdr() throws -> Value {
        switch self {
        case .cons(car: _, cdr: let cdr):
            return cdr
        default:
            throw Err.notCons(self)
        }
    }

    public func reversed() throws -> Value {
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
        case .closure(formals: _, body: _, frame: _):
            return "#<procedure>"
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
        case .closure(formals: _, body: _, frame: _):
            return "Closure"
        }
    }
}

extension Value {
    public func toArray() throws -> [Value] {
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
                throw Err.notList
            }
        }
    }
}
