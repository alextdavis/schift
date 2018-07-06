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
 * Tokenizes Scheme source
 */
public final class Tokenizer {
    private let input: String
    private var index: String.Index
    
    /// Output array of tokens.
    private(set) public var array: [Value] = []

    /**
     Create a new tokenizer from a string of Scheme source code.
     
     */
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
    /// Returns the current character in the input, without making modification.
    /// If there is no more input, `nil` is returned.
    private func peekChar() -> Character? {
        guard index < input.endIndex else {
            return nil
        }
        return input[index]
    }

    /// Returns the next character in the input, without making modification.
    /// If there is no more input, `nil` is returned.
    private func peekNextChar() -> Character? {
        let nextIndex = input.index(after: index)
        guard nextIndex < input.endIndex else {
            return nil
        }
        return input[nextIndex]
    }

    /// Returns the current character in the input, then advances to the next character.
    /// If there is no more input, `nil` is returned.
    private func popChar() -> Character? {
        if let c = peekChar() {
            index = input.index(after: index)
            return c
        }
        return nil
    }

    /**
     Handles tokenization of a comment. Simply advances through the input until a newline or the
     end of file is reached.
     */
    private func tokenizeComment() {
        while let c = popChar() {
            if c == "\n" {
                return;
            }
        }
    }
    
    /**
     Handles tokenization of a parenthesis.
     
     - Precondition: The current character in the input must be an open or close parenthesis.
     */
    private func tokenizeParen() {
        switch popChar() {
        case "(":
            array.append(.open)
        case ")":
            array.append(.close)
        default:
            assertionFailure("tokenizeParen should only be called when there's a paren.")
        }
    }

    /**
     Handles tokenization of a boolean literal.
     
     - Throws: `Tokenizer.Err` if an invalid Scheme token is found.
     
     - Precondition: The current character must be an octothorpe (`#`).
     */
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

    /**
     Handles the processing of an escape character in a Scheme string literal.
     
     - Throws: `Tokenizer.Err` If the escape sequence is invalid.
     */
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

    /**
     Handles tokenization of a string literal.
     
     - Throws: `Tokenizer.Err` if the string is unterminated, or contains an invalid escape
     sequence.
     
     - Precondition: The current character must be a quote (`"`).
     */
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
                throw Err.other("Unterminated string; file ended mid-string.")
            }
            str.append(c!)
            c = popChar()
        }
        array.append(.string(str))
    }

    /**
     Handles tokenization of a symbol literal.
     
     - Throws: `Tokenizer.Err` if an illegal character is found in the symbol.
     
     - Precondition: The current character is a valid initial symbol character.
     */
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

    /**
     Handles tokenization of a floating point literal. This is called once the integral part of the
     number has already been processed.
     
     - Parameter startString: The string containing the part of the floating point literal which has
     already been processed. By the precondition, this must be exactly the part of the literal
     preceeding the decimal point.
     
     - Throws: `Tokenizer.Err` if the literal is invalid.
     
     - Precondition: The current character must be a period (`.`).
     */
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

    /**
     Handles tokenization of a number literal. If the literal turns out to be a floating point
     number, it will call `tokenizeDouble()` for further processing.
     
     - Parameter startString: The string containing the part of the number literal which has already
     been processed. This is currently only used when the literal has a sign, in which case this
     string contains just that sign.
     
     - Throws: `Tokenizer.Err` if the literal is invalid.
     
     - Precondition: The current character must be a digit.
     */
    private func tokenizeNumber(_ startString: String = "") throws {
        var str   = startString
        let digit = popChar()
        assert(isDigit(digit), "tokenizeNumber should only be called when there's a digit.")
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

    /**
     Handles tokenization of a sign character (`+` or `-`).
     
     - Throws: `Tokenizer.Err` if the sign is the start of an invalid numeric literal.
     
     - Precondition: The current character is a sign.
     */
    private func tokenizeSign() throws {
        assert(isSign(peekChar()), "tokenizeSign should only be called when there's a sign.")
        if isDelineator(peekNextChar()) {
            try tokenizeSymbol() // Should always succeed.
        } else {
            try tokenizeNumber(String(popChar()!))
        }
    }

    /**
     Handles tokenization of a lil' buddy (`'`).
     
     - Precondition: The current character is a quote (`'`).
     */
    private func tokenizeQuote() {
        assert(peekChar() == "'", "tokenizeQuote should only be called when there's a sign.")
        _ = popChar()
        array.append(.quote)
    }
}

extension Tokenizer {
    /**
     Tokenizes the input.
     
     - Throws: `Tokenizer.Err` if the input has invalid tokens.
     */
    private func tokenize() throws {
        while let c = peekChar() {
            switch c {
            case ";":
                tokenizeComment()
            case "(", ")":
                tokenizeParen()
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
}
