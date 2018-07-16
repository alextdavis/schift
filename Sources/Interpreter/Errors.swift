//
//  Schift
//  The Scheme interpreter written in Swift.
//  Created by Alex T. Davis.
//  Based on an implementation in C by Anna S. Johnson, Eva D. Grench, and Alex T. Davis.
//
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation

/**
 A protocol for all errors thrown by Schift.
 */
public protocol SchiftError: Error, CustomStringConvertible {
}

protocol SchiftErrorPrintable {
    var schiftErrorMessage: String { get }
}

extension SchiftErrorPrintable {
    var schiftErrorMessage: String {
        return String(describing: self)
    }
}

extension PartialRangeFrom: SchiftErrorPrintable {
    var schiftErrorMessage: String {
        return "\(self.lowerBound) or more"
    }
}

extension PartialRangeThrough: SchiftErrorPrintable {
    var schiftErrorMessage: String {
        return "\(self.upperBound) or less"
    }
}

extension PartialRangeUpTo: SchiftErrorPrintable {
    var schiftErrorMessage: String {
        return "up to \(self.upperBound)"
    }
}

extension Int: SchiftErrorPrintable {
}


fileprivate extension Value {
    /**
     A string representation of the type of the value.
     */
    var typeDescription: String {
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
        case .pair:
            return "Pair"
        case .procedure:
            return "Procedure"
        case .primitive:
            return "Primitive"
        }
    }
}

extension Evaluator {
    public enum Err: SchiftError {
        case arity(procedure: String?, expected: Int, given: Int?)
        case noProc
        case notProc(Value)
        case procArgsNotList
        case invalidFormals
        case specialForm(String)
        case typeError(procedure: String, expected: String, found: Value)

        public var description: String {
            let s = "Evaluation Error: "
            switch self {
            case .arity(procedure:let proc, expected:let exp, given:let given):
                var ending: String
                if given == nil {
                    ending = "."
                } else {
                    ending = "; \(given!) given."
                }
                if proc == nil {
                    return "Arity Mismatch: The procedure takes \(exp) arguments" + ending
                } else {
                    return "Arity Mismatch: `\(proc!)` takes \(exp) arguments" + ending
                }
            case .noProc:
                return s + "Missing procedure; probably `()`."
            case .notProc(let val):
                return s + "Tried to apply to a value which is not a procedure; found `\(val)`."
            case .procArgsNotList:
                return s + "Tried to apply arguments which are not a proper list."
            case .invalidFormals:
                return s + "Formal parameters invalid."
            case .specialForm(let str):
                return s + str
            case .typeError(procedure:let proc, expected:let expected, found:let found):
                return "Evaluation Type Error: `\(proc)` found value of type " +
                       "\(found.typeDescription); expected \(expected)."
            }
        }
    }
}

extension Parser {
    public enum Err: SchiftError {
        case unmatchedOpen
        case unmatchedClose

        public var description: String {
            let s = "Parser Error: "
            switch self {
            case .unmatchedOpen:
                return s + "Unmatched Open Parenthesis."
            case .unmatchedClose:
                return s + "Unmatched Close Parenthesis."
            }
        }
    }
}

extension Primitives {
    public enum Err: SchiftError {
        case arity(procedure: String?, expected: SchiftErrorPrintable, given: Int?)
        case mathNonNumber(Value)
        case typeError(procedure: String, expected: String, found: Value)
        case divideByZero

        public var description: String {
            let s = "Primitive Error: "
            switch self {
            case .arity(procedure:let proc, expected:let exp, given:let given):
                var ending: String
                if given == nil {
                    ending = "."
                } else {
                    ending = "; \(given!) given."
                }
                if proc == nil {
                    return "Arity Mismatch: The procedure takes \(exp.schiftErrorMessage) arguments"
                           + ending
                } else {
                    return "Arity Mismatch: `\(proc!)` takes \(exp.schiftErrorMessage) arguments"
                           + ending
                }
            case .mathNonNumber(let val):
                return s + "Tried to perform numeric operation on non-numeric type " +
                       "\(val.typeDescription)."
            case .typeError(procedure:let proc, expected:let expected, found:let found):
                return "Primitive Type Error: `\(proc)` found value of type " +
                       "\(found.typeDescription); expected \(expected)."
            case .divideByZero:
                return "Divide By Zero."
            }
        }
    }
}

extension Frame {
    public enum Err: SchiftError {
        case bindToNonSymbol(Value)
        case lookupNonSymbol(Value)
        case unboundVariable(String)

        public var description: String {
            let s = "Frame Error: "
            switch self {
            case .bindToNonSymbol(let val):
                return s + "Tried to bind to a value of type \(val.typeDescription); " +
                       "expected Symbol."
            case .lookupNonSymbol(let val):
                return s + "Tried to look up a value of type \(val.typeDescription); " +
                       "expected Symbol."
            case .unboundVariable(let str):
                return s + "Unbound variable `\(str)`."
            }
        }
    }
}

extension Tokenizer {
    public enum Err: SchiftError {
        case other(String)

        public var description: String {
            let s = "Token Error: "
            switch self {
            case .other(let str):
                return s + str
            }
        }
    }
}

extension Value {
    public enum Err: SchiftError {
        case notPair(Value)
        case notList

        public var description: String {
            let s = "Value Error: "
            switch self {
            case .notPair(let val):
                return s + "Tried to take the car or cdr of a value of type " +
                       "\(val.typeDescription); expected Pair."
            case .notList:
                return s + "Tried to perform a list action on an improper list."
            }
        }
    }
}
