//
//  Errors.swift
//  Interpreter
//
//  Created by Alex Davis on 5/20/18.
//

import Foundation

public protocol KurtError: Error {
    var message: String { get }
}

extension Evaluator {
    public enum Err: KurtError {
        case arity(procedure: String?, expected: Int, given: Int)
        case noProc
        case notProc(Value)
        case procArgsNotList
        case invalidFormals
        case specialForm(String)
        
        public var message: String {
            let s = "Evaluation Error: "
            switch self {
            case .arity(procedure: let proc, expected: let exp, given: let given):
                if proc == nil {
                    return "Arity Mismatch: The procedure takes \(exp) arguments; \(given) given"
                } else {
                    return "Arity Mismatch: `\(proc!)` takes \(exp) arguments; \(given) given"
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
