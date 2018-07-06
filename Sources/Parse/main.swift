//
//  Schift
//  The Scheme interpreter written in Swift.
//  Created by Alex T. Davis.
//  Based on an implementation in C by Anna S. Johnson, Eva D. Grench, and Alex T. Davis.
//
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Interpreter

extension Parser {
    public static func treeToJedString(_ tree: Value) throws -> String? {
        return try tree.toArray().joinedStrings(separator: " ")
    }
}

extension Value {
    var jedTreeString: String {
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

var tokens = [Value]()

while let line = readLine(strippingNewline: false) {
    do {
        try tokens += Tokenizer(line).array
//        try print(Parser.parse(Tokenizer(line).list).jedTreeString, terminator: "")
    } catch let error as KurtError {
        print(error.message)
    }
}

let tree = try Parser.parse(tokens)

print(try Parser.treeToJedString(tree)!)
