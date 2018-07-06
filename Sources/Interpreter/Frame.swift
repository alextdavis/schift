//
//  Schift
//  The Scheme interpreter written in Swift.
//  Created by Alex T. Davis.
//  Based on an implementation in C by Anna S. Johnson, Eva D. Grench, and Alex T. Davis.
//
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

public final class Frame {
    private var bindings: [String: Value]
    public let parent: Frame?

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

    public func bind(_ str: String, primitive: @escaping ([Value]) throws -> Value) {
        self.bind(str, value: Value.primitive(primitive))
    }

    private func lookupInSingleFrame(_ str: String) -> Value? {
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
