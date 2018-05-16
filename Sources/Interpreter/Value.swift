//
//  LinkedList.swift
//  kurtscheme
//
//  Created by Alex Davis on 5/14/18.
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation

enum Value {
    case null
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case open
    case close
    case symbol(String)
    indirect case cons(car: Value, cdr: Value)
    
    var length: Int {
        switch self {
        case .null:
            return 0
        case .cons(car: _, cdr: let cdr):
            return 1 + cdr.length
        default:
            assertionFailure("Can't find the length of a non-list")
            return -1
        }
    }
    
    func reversed() -> Value {
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
                assertionFailure("Tried to reverse non-list")
            }
        }
    }
}

extension Value: CustomStringConvertible {
    var description: String {
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
                    return str + ")"
                default:
                    return str + " . " + cell.description + ")"
                }
            }
        }
    }
}
