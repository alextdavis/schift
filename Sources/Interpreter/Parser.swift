//
//  Parser.swift
//  Interpreter
//
//  Created by Alex Davis on 5/15/18.
//

final class Parser {
    private static func addToParseTree(_ tree: inout Value, depth: inout Int, token: Value) {
        switch token {
        case .open:
            depth += 1
            tree = Value.cons(car: token, cdr: tree)

        case .close:
            depth -= 1
            if depth < 0 {
                error(.Parse, "Unmatched close parenthesis.")
            }

            var subTree = Value.null
            while case .open = tree.car {
                subTree = Value.cons(car: tree.car, cdr: subTree)
                tree = tree.cdr
            }

            tree = tree.cdr
            tree = Value.cons(car: subTree, cdr: tree)

        default:
            tree = Value.cons(car: token, cdr: tree)
        }
    }

    public static func parse(_ tokens: [Value]) -> Value {
        var tree = Value.null
        var depth = 0

        for token in tokens {
            addToParseTree(&tree, depth: &depth, token: token)
        }

        if depth != 0 {
            error(.Parse, "Unmatched open parenthesis.")
        }

        return tree.reversed()
    }
}
