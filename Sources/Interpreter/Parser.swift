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
                throw Err.unmatchedClose
            }

            var subTree = Value.null
            while true {
                if case .open = try tree.car() {
                    break
                }
                subTree = Value.cons(car: try tree.car(), cdr: subTree)

                tree = try tree.cdr()
            }

            tree = try tree.cdr()

//            // Implements lil' buddy. TODO Fix this
//            let treeCar: Value = try tree.car() // Don't know why this line is necessary
//            if case .cons = tree, case .quote = treeCar {
//                tree = try tree.cdr()
//                subTree = Value.cons(car: .symbol("quote"),
//                                     cdr: .cons(car: subTree,
//                                                cdr: .null))
//            }

            tree = Value.cons(car: subTree, cdr: tree)

        default:
//            if case .cons = tree, case .quote = try tree.car() {
//                tree = try tree.cdr()
//                var subTree = Value.cons(car: .symbol("quote"),
//                                         cdr: .cons(car: token, cdr: .null))
//                tree = .cons(car: subTree, cdr: tree)
//                return
//            }

            tree = Value.cons(car: token, cdr: tree)
        }
    }

    public static func hasMatchingParens(tokens: Value) throws -> Bool {
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

    public static func parse(_ tokens: [Value]) throws -> Value {
        var tree  = Value.null
        var depth = 0

        for token in tokens {
            try addToParseTree(&tree, depth: &depth, token: token)
        }

        if depth != 0 {
            throw Err.unmatchedOpen
        }

        return try tree.reversed()
    }
}

extension Parser {
    public static func treeToJedString(_ tree: Value) throws -> String? {
        return try tree.toArray().joinedStrings(separator: " ")
    }
}

extension Value {
    public var jedTreeString: String {
        var str = ""

        guard self.isList else {
            preconditionFailure("Can't get the jedEvalString of a non-proper list")
        }

        for val in self {
            str += val.description + " "
        }
        return str
    }
}
