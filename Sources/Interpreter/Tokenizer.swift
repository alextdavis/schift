//
//  Tokenizer.swift
//  kurtscheme
//
//  Created by Alex Davis on 5/14/18.
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation

public final class Tokenizer {
    private let input: String
    private var index: String.Index
    private(set) public var array: [Value] = []

    public init(_ str: String) throws {
        input = str
        index = str.startIndex
        try tokenize()
    }
}

fileprivate func isWhitespace(_ c: Character?) -> Bool {
    switch c {
    case " ", "\n", "\r", "\t":
        return true
    default:
        return false
    }
}

fileprivate func isDelineator(_ c: Character?) -> Bool {
    switch c {
    case "(", ")", "\"", "'", ";", nil:
        return true
    default:
        return isWhitespace(c)
    }
}

fileprivate func isDigit(_ c: Character?) -> Bool {
    guard c != nil else { // Necessary to use range in the switch.
        return false
    }
    switch c! {
    case "0"..."9":
        return true
    default:
        return false
    }
}

fileprivate func isSign(_ c: Character?) -> Bool {
    switch c {
    case "+", "-":
        return true
    default:
        return false
    }
}

fileprivate func isSymbolInitial(_ c: Character?) -> Bool {
    guard c != nil else {
        return false
    }
    switch c! {
    case "A"..."Z", "a"..."z",
         "!", "$", "%", "&", "*", "/", ":", "<", "=", ">", "?", "~", "_", "`":
        return true
    default:
        return false
    }
}

fileprivate func isSymbolSubsequent(_ c: Character?) -> Bool {
    switch c {
    case ".", "+", "-":
        return true
    default:
        return isSymbolInitial(c) || isDigit(c)
    }
}

extension Tokenizer {
    private func peekChar() -> Character? {
        guard index < input.endIndex else {
            return nil
        }
        return input[index]
    }

    private func peekNextChar() -> Character? {
        let nextIndex = input.index(after: index)
        guard nextIndex < input.endIndex else {
            return nil
        }
        return input[nextIndex]
    }

    private func popChar() -> Character? {
        if let c = peekChar() {
            index = input.index(after: index)
            return c
        }
        return nil
    }

    private func tokenizeComment() {
        while true {
            let c = popChar()
            if c == nil || c == "\n" {
                return;
            }
        }
    }

    private func tokenizeParen() throws {
        switch popChar() {
        case "(":
            array.append(.open)
        case ")":
            array.append(.close)
        default:
            assertionFailure("tokenizeParen should only be called when there's a paren.")
        }
    }

    private func tokenizeBool() throws {
        let octo = popChar()
        assert(octo == "#", "tokenizeBool should only be called when there's a `#`.")

        let tf = popChar()
        switch tf {
        case "f", "F", "t", "T":
            if (isDelineator(peekChar())) {
                array.append(.bool(tf == "t" || tf == "T"))
            } else {
                throw Err.other("Boolean literal followed by illegal character.")
            }
        case nil:
            throw Err.other("Found `#` at end of file.")
        default:
            throw Err.other("`#` followed by illegal character \(tf!).")
        }
    }

    private func handleEscapeChar(_ str: inout String) throws {
        let c = popChar()
        switch c {
        case "n":
            str.append("\n")
        case "t":
            str.append("\t")
        case "\\":
            str.append("\\")
        case "'":
            str.append("'")
        case "\"":
            str.append("\"")
        case nil:
            throw Err.other("Found `\\` at end of file.")
        default:
            throw Err.other("Unrecognized escape sequence `\\\(c!)`.")
        }
    }

    private func tokenizeString() throws {
        let startQuote = popChar()
        assert(startQuote == "\"", "tokenizeString should only be called when there's a `\"`.")

        var str = ""

        var c = popChar()
        while c != "\"" {
            if c == "\\" {
                try handleEscapeChar(&str)
                continue
            }
            if c == nil {
                throw Err.other("Unmatched quote; file ended mid-string.")
            }
            str.append(c!)
            c = popChar()
        }
        array.append(.string(str))
    }

    private func tokenizeSymbol() throws {
        let initial = popChar()
        assert(isSymbolInitial(initial) || isSign(initial),
               "tokenizeSymbol should only be called when there's an initial or sign.")

        var sym = String(initial!)

        var c: Character?
        while true {
            if isDelineator(peekChar()) { // includes `nil`
                break;
            }
            c = popChar()
            if !isSymbolSubsequent(c) {
                throw Err.other("Illegal character `\(c!)` in symbol `\(sym)`.")
            }
            sym.append(c!)
        }
        array.append(.symbol(sym))
    }

    private func tokenizeDouble(_ startString: String = "") throws {
        var str = startString
        let dot = popChar()
        assert(dot == ".", "Should be a dot, I think")
        str.append(dot!)

        while true {
            if isDelineator(peekChar()) {
                break;
            }

            str.append(popChar()!)
        }

        guard let dbl = Double(str) else {
            throw Err.other("Invalid format for Double: `\(str)`.")
        }
        array.append(.double(dbl))
    }

    private func tokenizeNumber(_ startString: String = "") throws {
        var str   = startString
        let digit = popChar()
        assert(isDigit(digit),
               "tokenizeNumber should only be called when there's a digit.")
        str.append(digit!)

        while true {
            if isDelineator(peekChar()) {
                break;
            }

            if peekChar() == "." {
                try tokenizeDouble(str)
                return
            }
            str.append(popChar()!)
        }

        guard let int = Int(str) else {
            throw Err.other("Invalid format for Integer: `\(str)`.")
        }
        array.append(.int(int))
    }

    private func tokenizeSign() throws {
        assert(isSign(peekChar()),
               "tokenizeSign should only be called when there's a sign.")
        if isDelineator(peekNextChar()) {
            try tokenizeSymbol()
        } else {
            try tokenizeNumber(String(popChar()!))
        }
    }

    private func tokenizeQuote() {
        _ = popChar()
        array.append(.quote)
    }
}

extension Tokenizer {
    private func tokenize() throws {
        while let c = peekChar() {
            switch c {
            case ";":
                tokenizeComment()
            case "(", ")":
                try tokenizeParen()
            case "#":
                try tokenizeBool()
            case "\"":
                try tokenizeString()
            case "'":
                tokenizeQuote()
            case _ where isSymbolInitial(c):
                try tokenizeSymbol()
            case _ where isDigit(c):
                try tokenizeNumber()
            case ".":
                try tokenizeDouble()
            case _ where isSign(c):
                try tokenizeSign()
            case _ where isWhitespace(c):
                _ = popChar()
            default:
                throw Err.other("Illegal character `\(c)`.")
            }
        }
    }

    public var jedString: String {
        return array.map({ $0.tokenOutputString }).joined()
    }
}

extension Value {
    fileprivate var tokenName: String? {
        switch self {
        case .open:
            return "open"
        case .close:
            return "close"
        case .quote:
            return "quote"
        case .bool:
            return "boolean"
        case .string:
            return "string"
        case .symbol:
            return "symbol"
        case .double:
            return "double"
        case .int:
            return "integer"
        default:
            assertionFailure("Tried to find token name of non-token value.")
            return nil
        }
    }

    fileprivate var tokenOutputString: String {
        switch self {
        case .open, .close, .bool, .string, .symbol, .double, .int:
            return self.description + ":" + self.tokenName! + "\n"
        default:
            assertionFailure("Tried to get token output of non-token value.")
            return "Err:Non-token"
        }
    }
}
