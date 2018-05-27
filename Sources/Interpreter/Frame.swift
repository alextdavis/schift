//
//  Frame.swift
//  Interpreter
//
//  Created by Alex Davis on 5/19/18.
//


public final class Frame {
    private var bindings: [String: Value]
    let parent: Frame?
    
    public init(parent: Frame?) {
        self.parent = parent
        self.bindings = [String: Value]()
    }
    
    public func bind(symbol: Value, value: Value) throws {
        guard case .symbol(let sym) = symbol else {
            throw Err.bindToNonSymbol(symbol)
        }
        self.bindings[sym] = value
    }
    
    public func lookup(symbol: String) throws -> Value {
        var frameOpt: Frame? = self
        while let frame = frameOpt {
            if let val = self.bindings[symbol] {
                return val
            }
            frameOpt = frame.parent

            /*for binding in try bindings.toArray() {
                guard case .cons(car: let car, cdr: let cdr) = binding else {
                    preconditionFailure("Found )
                }
                guard case .symbol(let bound) = binding else {
                    preconditionFailure("Found binding of non-symbol")
                }
                if look == bound {
                    
                }
            }*/
        }
        
        throw Err.unboundVariable(symbol)
    }
}
