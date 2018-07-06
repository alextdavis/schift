//
//  Schift
//  The Scheme interpreter written in Swift.
//  Created by Alex T. Davis.
//  Based on an implementation in C by Anna S. Johnson, Eva D. Grench, and Alex T. Davis.
//
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation

public protocol KurtError: Error {
    var message: String { get }
}

protocol KurtErrorPrintable {
    var kurtErrorMessage: String { get }
}

extension KurtErrorPrintable {
    var kurtErrorMessage: String {
        return String(describing: self)
    }
}

extension PartialRangeFrom: KurtErrorPrintable {
    var kurtErrorMessage: String {
        return "\(self.lowerBound) or more"
    }
}

extension PartialRangeThrough: KurtErrorPrintable {
    var kurtErrorMessage: String {
        return "\(self.upperBound) or less"
    }
}

extension PartialRangeUpTo: KurtErrorPrintable {
    var kurtErrorMessage: String {
        return "up to \(self.upperBound)"
    }
}

extension Int: KurtErrorPrintable {}


extension Evaluator {
    public enum Err: KurtError {
        case arity(procedure: String?, expected: Int, given: Int?)
        case noProc
        case notProc(Value)
        case procArgsNotList
        case invalidFormals
        case specialForm(String)
        case typeError(procedure: String, expected: String, found: Value)

        public var message: String {
            let s = "Evaluation Error: "
            switch self {
            case .arity(procedure:let proc, expected:let exp, given:let given):
                var ending: String
                if given == nil {
                    ending = "."
                } else {
                    ending = "; \(given!) given"
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
                return "Evaluation Type Error: `\(proc)` found value of type \(found.type); " +
                       "expected \(expected)."
            }
        }
    }
}

extension Parser {
    public enum Err: KurtError {
        case unmatchedOpen
        case unmatchedClose

        public var message: String {
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
    public enum Err: KurtError {
        case arity(procedure: String?, expected: KurtErrorPrintable, given: Int?)
        case mathNonNumber(Value)
        case typeError(procedure: String, expected: String, found: Value)
        case divideByZero

        public var message: String {
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
                    return "Arity Mismatch: The procedure takes \(exp.kurtErrorMessage) arguments"
                           + ending
                } else {
                    return "Arity Mismatch: `\(proc!)` takes \(exp.kurtErrorMessage) arguments"
                           + ending
                }
            case .mathNonNumber(let val):
                return s + "Tried to perform numeric operation on non-numeric type \(val.type)."
            case .typeError(procedure:let proc, expected:let expected, found:let found):
                return "Primitive Type Error: `\(proc)` found value of type \(found.type); " +
                       "expected \(expected)."
            case .divideByZero:
                return "Divide By Zero."
            }
        }
    }
}

extension Frame {
    public enum Err: KurtError {
        case bindToNonSymbol(Value)
        case lookupNonSymbol(Value)
        case unboundVariable(String)

        public var message: String {
            let s = "Frame Error: "
            switch self {
            case .bindToNonSymbol(let val):
                return s + "Tried to bind to a value of type \(val.type); expected Symbol."
            case .lookupNonSymbol(let val):
                return s + "Tried to look up a value of type \(val.type); expected Symbol."
            case .unboundVariable(let str):
                return s + "Unbound variable `\(str)`."
            }
        }
    }
}

extension Tokenizer {
    public enum Err: KurtError {
        case other(String)

        public var message: String {
            let s = "Token Error: "
            switch self {
            case .other(let str):
                return s + str
            }
        }
    }
}

extension Value {
    public enum Err: KurtError {
        case notCons(Value)
        case notList

        public var message: String {
            let s = "Value Error: "
            switch self {
            case .notCons(let val):
                return s + "Tried to take the car or cdr of a value of type \(val.type); expected Cons."
            case .notList:
                return s + "Tried to perform a list action on an improper list."
            }
        }
    }
}
