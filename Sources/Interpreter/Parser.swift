//
//  Schift
//  The Scheme interpreter written in Swift.
//  Created by Alex T. Davis.
//  Based on an implementation in C by Anna S. Johnson, Eva D. Grench, and Alex T. Davis.
//
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

/**
 Parses Scheme token lists to generate an Abstract Syntax Tree.
 */
public struct Parser {
    /**
     Parses the given scheme tokens to produce an Abstract Syntax Tree.
     
     - Throws: `Parser.Err` if parenthesis are unmatched.
     */
    public static func parse(_ tokens: [Value]) throws -> Value {
        var tree = Value.null
        var depth = 0
        
        for token in tokens {
            try addToParseTree(&tree, depth: &depth, token: token)
        }
        
        if depth != 0 {
            throw Err.unmatchedOpen
        }
        
        return try! tree.reversed()
    }
    
    /**
     Checks to see if the given token list has properly matching parenthesis. Used to decide whether
     to prompt the user for additional input in the REPL.
     
     - Returns:
     `true` if the parenthesis are all properly matched.
     `false` if there are unmatched open parenthesis.
     
     - Throws: `Parser.Err.unmatchedClose` if there are internal unmatched close parenthesis in the
     token list. In this case, appending more tokens cannot remedy the invalidity.
     */
    public static func hasMatchingParens(tokens: [Value]) throws -> Bool {
        var count = 0
        for token in tokens {
            switch token {
            case .open:
                count += 1
            case .close:
                count -= 1
            default:
                break
            }

            if count < 0 {
                throw Err.unmatchedClose
            }
        }
        return count == 0
    }
    
    /**
     Adds the given token to the parse tree, keeping track of depth.
     
     - Throws: `Parser.Err.unmatchedClose` if an unmatched closing parenthesis is found.
     */
    private static func addToParseTree(_ tree: inout Value, depth: inout Int, token: Value) throws {
        switch token {
        case .open:
            depth += 1
            tree = .cons(car: token, cdr: tree)

        case .close:
            depth -= 1
            if depth < 0 {
                throw Err.unmatchedClose
            }

            var subTree = Value.null
            while true {
                if case .open = try! tree.car() { //TODO: Go through these `try` and move to `try!`
                    break
                }
                subTree.prepend(try! tree.car())

                tree = try! tree.cdr()
            }

            tree = try! tree.cdr()

            // Implements lil' buddy.
            if tree.isCons, try! tree.car().isQuote {
                tree = try! tree.cdr()
                subTree = .cons(car: .symbol("quote"),
                                cdr: .cons(car: subTree,
                                           cdr: .null))
            }

            tree.prepend(subTree)

        default:
            if tree.isCons, try! tree.car().isQuote {
                tree = try! tree.cdr()
                tree.prepend(.cons(car: .symbol("quote"),
                                   cdr: .cons(car: token,
                                              cdr: .null)))
                return
            }

            tree = .cons(car: token, cdr: tree)
        }
    }
}
