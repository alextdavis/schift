//
//  Parser.swift
//  Interpreter
//
//  Created by Alex Davis on 5/15/18.
//

public final class Parser {
    private static func addToParseTree(_ tree: inout Value, depth: inout Int, token: Value) throws {
        switch token {
        case .open:
            depth += 1
            tree = Value.cons(car: token, cdr: tree)

        case .close:
            depth -= 1
            if depth < 0 {
                throw ParserError.unmatchedClose
            }

            var subTree = Value.null
            while true {
                if case .open = tree.car {
                    break
                }
                subTree = Value.cons(car: tree.car, cdr: subTree)
                tree = tree.cdr
            }

            tree = tree.cdr
            tree = Value.cons(car: subTree, cdr: tree)

        default:
            tree = Value.cons(car: token, cdr: tree)
        }
    }

    public static func parse(_ tokens: [Value]) throws -> Value {
        var tree = Value.null
        var depth = 0

        for token in tokens {
            try addToParseTree(&tree, depth: &depth, token: token)
        }

        if depth != 0 {
            throw ParserError.unmatchedOpen
        }

        return tree.reversed()
    }
}

extension Parser {
    public enum ParserError: Error {
        case unmatchedOpen, unmatchedClose
    }
}

extension Parser {
    public static func treeToJedString(_ tree: Value) -> String? {
        return tree.toArray()?.joinedStrings(separator: " ")
    }
}

extension Value {
    public var jedTreeString: String {
        var str = ""
        var cell = self
        while true {
            switch cell {
            case .cons(car: let car, cdr: let cdr):
                str += car.description + " "
                cell = cdr
            case .null:
                return str
            default:
                preconditionFailure("Can't get the jedTreeString of a non-proper list")
            }
        }
    }
}
