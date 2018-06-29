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

    public func bind(symbol: Value, primitive: @escaping ([Value]) throws -> Value) throws {
        guard case .symbol(let sym) = symbol else {
            throw Err.bindToNonSymbol(symbol)
        }
        self.bind(sym, primitive: primitive);
    }

    public func bind(_ str: String, primitive: @escaping ([Value]) throws -> Value) {
        self.bind(str, value: Value.primitive(primitive))
    }

    public func lookupInSingleFrame(_ str: String) -> Value? {
        return self.bindings[str]
    }

    public func lookupInSingleFrame(symbol: Value) throws -> Value? {
        guard case .symbol(let str) = symbol else {
            throw Err.lookupNonSymbol(symbol)
        }

        return lookupInSingleFrame(str)
    }

    public static func lookup(_ symbol: String, env frame: Frame) throws -> Value {
        var curFrame: Frame? = frame
        while curFrame != nil {
            if let val = curFrame?.lookupInSingleFrame(symbol) {
                return val
            }
            curFrame = curFrame?.parent
        }
        throw Err.unboundVariable(symbol)
    }

    public static func setBang(_ str: String, value: Value,
                               env startingFrame: Frame) throws -> Bool {
        var frame: Frame? = startingFrame
        while frame != nil {
            if frame!.bindings[str] != nil {
                frame!.bindings[str] = value
                return true
            }
            frame = frame?.parent
        }
        return false
    }
}
