//
//  Evaluator.swift
//  Interpreter
//
//  Created by Alex Davis on 5/19/18.
//

import Foundation

public final class Evaluator {
    
    private static func evalIf(args: Value, frame: Frame) throws -> Value {
        guard try args.length() == 3 else {
            throw Err.arity(procedure: "if", expected: 3, given: try args.length())
        }
        
        let testResult = try eval(args.car(), frame: frame)
        if case .bool(false) = testResult {
            return try eval(args.cdr().cdr().car(), frame: frame)
        } else {
            return try eval(args.cdr().car(), frame: frame)
        }
    }
    
    private static func evalLet(args: Value, frame parentFrame: Frame) throws -> Value {
        guard try args.length() == 2 else {
            throw Err.arity(procedure: "let", expected: 2, given: try args.length())
        }
        
        let frame = Frame(parent: parentFrame)
        
        let bindings = try args.car()
        let body = try args.cdr().car()
        
        guard bindings.isList else {
            throw Err.specialForm("First argument in `let` should be a proper list of bindings.")
        }
        
        for binding in try bindings.toArray() {
            guard try binding.isList && binding.length() == 2 else {
                throw Err.specialForm("Each binging in `let` must be a proper list of length 2.")
            }
            
            try frame.bind(symbol: binding.car(), value: binding.cdr().car())
        }
        
        return try eval(body, frame: frame)
    }
    
    private static func evalDef(args: Value, frame: Frame) throws -> Value {
        guard frame.parent == nil else {
            throw Err.specialForm("Can't call define from inner context.")
        }
        guard try args.length() == 2 else {
            throw Err.arity(procedure: "define", expected: 2, given: try args.length())
        }
        
        let variable = try args.car()
        let expr = try args.cdr().car()
        let val = try eval(expr, frame: frame)
        try frame.bind(symbol: variable, value: val)
        
        return Value.void
    }
    
    private static func evalLambda(args: Value, frame: Frame) throws -> Value {
        guard try args.length() == 2 else {
            throw Err.arity(procedure: "lambda", expected: 2, given: try args.length())
        }
        return try Value.closure(formals: args.car(), body: args.cdr().car(), frame: frame)
    }
    
    private static func apply(_ proc: Value, args: Value) throws -> Value {
        guard case .closure(formals: let formals, body: let body, frame: let parentFrame) = proc else {
            throw Err.notProc(proc)
        }
        guard args.isList else {
            throw Err.procArgsNotList
        }
        
        let newFrame = Frame(parent: parentFrame)
        
        if formals.isList {
            guard try formals.length() == args.length() else {
                throw Err.arity(procedure: "#<procedure>",
                                expected: try! formals.length(),
                                given: try! args.length())
            }
            
            guard let formalAry = try? formals.toArray(), let actualAry = try? args.toArray() else {
                    preconditionFailure("Args or Formals changed since last check.")
            }
            
            for i in formalAry.indices {
                try newFrame.bind(symbol: formalAry[i], value: actualAry[i])
            }
            
        } else if case .symbol(_) = formals { // Variadic
            try newFrame.bind(symbol: formals, value: args)
        } else {
            throw Err.invalidFormals
        }
        
        return try eval(body, frame: newFrame)
    }
    
    static func eval(_ expr: Value, frame: Frame) throws -> Value {
        switch expr {
        case .int(_), .double(_), .string(_), .bool(_):
            return expr
        case .cons(car: let first, cdr: let args):
            // Handle Special Forms
            if case .symbol(let sym) = first {
                switch sym {
                case "if":
                    return try evalIf(args: args, frame: frame)
                case "let":
                    return try evalLet(args: args, frame: frame)
                case "define":
                    return try evalDef(args: args, frame: frame)
                case "lambda":
                    return try evalLambda(args: args, frame: frame)
                default:
                    break
                }
            }
            
            // Evaluate procedure
            let proc = try eval(first, frame: frame)
            guard case .closure(_) = proc else {
                throw Err.notProc(proc)
            }
            
            var actuals = Value.null
            var argsCell = args
            argEvalLoop: while true {
                switch argsCell {
                case .null:
                    break argEvalLoop
                case .cons(car: let car, cdr: let cdr):
                    actuals = .cons(car: try eval(car, frame: frame), cdr: actuals)
                    argsCell = cdr
                default:
                    throw Err.procArgsNotList
                }
            }
            
            return try apply(proc, args: actuals.reversed())
            
        case .symbol(let sym):
            return try frame.lookup(symbol: sym)
        case .null:
            throw Err.noProc
        case .void, .open, .close, .closure(formals: _, body: _, frame: _):
            preconditionFailure("Found Void, Open, Close, or Closure type in Evaluator#eval")
        }
    }
    
}
