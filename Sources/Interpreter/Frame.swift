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

    public func bind(_ str: String, value: Value) {
        self.bindings[str] = value
    }

    public func bind(symbol: Value, value: Value) throws {
        guard case .symbol(let sym) = symbol else {
            throw Err.bindToNonSymbol(symbol)
        }
        self.bind(sym, value: value)
    }

    public func bind(symbol: Value, primitive: @escaping (Value) throws -> Value) throws {
        guard case .symbol(let sym) = symbol else {
            throw Err.bindToNonSymbol(symbol)
        }
        self.bind(sym, primitive: primitive);
    }

    public func bind(_ str: String, primitive: @escaping (Value) throws -> Value) {
        self.bind(str, value: Value.primitive(primitive))
    }

    public func lookup(symbol: String) -> Value? {
        return self.bindings[symbol]
    }

    static public func lookup(_ symbol: String, environment frame: Frame) throws -> Value {
        var curFrame: Frame? = frame
        while curFrame != nil {
            if let val = curFrame?.lookup(symbol: symbol) {
                return val
            }
            curFrame = frame.parent
        }
        throw Err.unboundVariable(symbol)
    }
}
