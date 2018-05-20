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

extension Tokenizer {
    public enum TokenizerError: Error {
        case other(String)

        public var message: String {
            switch self {
            case .other(let str):
                return str
            }
        }
    }
}

extension Tokenizer {
    private static func isWhitespace(_ c: Character?) -> Bool {
        switch c {
        case " ", "\n", "\r", "\t":
            return true
        default:
            return false
        }
    }

    private static func isDelineator(_ c: Character?) -> Bool {
        switch c {
        case "(", ")", "\"", "'", ";", nil:
            return true
        default:
            return isWhitespace(c)
        }
    }

    private static func isDigit(_ c: Character?) -> Bool {
        return c != nil && "0"..."9" ~= c!
    }

    private static func isSign(_ c: Character?) -> Bool {
        return c == "-" || c == "+"
    }

    private static func isSymbolInitial(_ c: Character?) -> Bool {
        if c == nil {
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

    private static func isSymbolSubsequent(_ c: Character?) -> Bool {
        switch c {
        case ".", "+", "-":
            return true
        default:
            return isSymbolInitial(c) || isDigit(c)
        }
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
            if (Tokenizer.isDelineator(peekChar())) {
                array.append(.bool(tf == "t" || tf == "T"))
            } else {
                throw TokenizerError.other("Boolean literal followed by illegal character.")
            }
        case nil:
            throw TokenizerError.other("Found `#` at end of file.")
        default:
            throw TokenizerError.other("`#` followed by illegal character \(tf!).")
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
            throw TokenizerError.other("Found `\\` at end of file.")
        default:
            throw TokenizerError.other("Unrecognized escape sequence `\\\(c!)`.")
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
                throw TokenizerError.other("Unmatched quote; file ended mid-string.")
            }
            str.append(c!)
            c = popChar()
        }
        array.append(.string(str))
    }

    private func tokenizeSymbol() throws {
        let initial = popChar()
        assert(Tokenizer.isSymbolInitial(initial) || Tokenizer.isSign(initial),
                "tokenizeSymbol should only be called when there's an initial or sign.")

        var sym = String(initial!)

        var c: Character?
        while true {
            if Tokenizer.isDelineator(peekChar()) { // includes `nil`
                break;
            }
            c = popChar()
            if !Tokenizer.isSymbolSubsequent(c) {
                throw TokenizerError.other("Illegal character `\(c!)` in symbol `\(sym)`.")
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
            if Tokenizer.isDelineator(peekChar()) {
                break;
            }

            str.append(popChar()!)
        }

        guard let dbl = Double(str) else {
            throw TokenizerError.other("Invalid format for Double: `\(str)`.")
        }
        array.append(.double(dbl))
    }

    private func tokenizeNumber(_ startString: String = "") throws {
        var str = startString
        let digit = popChar()
        assert(Tokenizer.isDigit(digit),
                "tokenizeNumber should only be called when there's a digit.")
        str.append(digit!)

        while true {
            if Tokenizer.isDelineator(peekChar()) {
                break;
            }

            if peekChar() == "." {
                try tokenizeDouble(str)
                return
            }
            str.append(popChar()!)
        }

        guard let int = Int(str) else {
            throw TokenizerError.other("Invalid format for Integer: `\(str)`.")
        }
        array.append(.int(int))
    }

    private func tokenizeSign() throws {
        assert(Tokenizer.isSign(peekChar()), "tokenizeSign should only be called when there's a sign.")

//        print("Popped sign: \(sign)")
//        print("Peek: \(peekChar())")
//        print("isdelineator: \(Tokenizer.isDelineator(peekChar()))")
//        print(list)
        if Tokenizer.isDelineator(peekNextChar()) {
            try tokenizeSymbol()
        } else {
            try tokenizeNumber(String(popChar()!))
        }
    }
}

extension Tokenizer {
    private func tokenize() throws {
        var done = false
        while (!done) {
            let c = peekChar()
            switch c {
            case nil:
                done = true
            case ";":
                tokenizeComment()
            case "(", ")":
                try tokenizeParen()
            case "#":
                try tokenizeBool()
            case "\"":
                try tokenizeString()
            case _ where Tokenizer.isSymbolInitial(c!):
                try tokenizeSymbol()
            case _ where Tokenizer.isDigit(c!):
                try tokenizeNumber()
            case ".":
                try tokenizeDouble()
            case _ where Tokenizer.isSign(c!):
                try tokenizeSign()
            case _ where Tokenizer.isWhitespace(c!):
                _ = popChar()
            default:
                throw TokenizerError.other("Illegal character `\(c!).")
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
        case .bool(_):
            return "boolean"
        case .string(_):
            return "string"
        case .symbol(_):
            return "symbol"
        case .double(_):
            return "double"
        case .int(_):
            return "integer"
        default:
            assertionFailure("Tried to find token name of non-token value.")
            return nil
        }
    }

    fileprivate var tokenOutputString: String {
        switch self {
        case .open, .close, .bool(_), .string(_), .symbol(_), .double(_), .int(_):
            return self.description + ":" + self.tokenName! + "\n"
        default:
            assertionFailure("Tried to get token output of non-token value.")
            return "Err:Non-token"
        }
    }
}
