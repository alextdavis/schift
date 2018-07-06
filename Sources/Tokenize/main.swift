//
//  Schift
//  The Scheme interpreter written in Swift.
//  Created by Alex T. Davis.
//  Based on an implementation in C by Anna S. Johnson, Eva D. Grench, and Alex T. Davis.
//
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation
import Interpreter

extension Tokenizer {
    public var jedString: String {
        return array.map({ $0.tokenOutputString }).joined()
    }
}

fileprivate extension Value {
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


while let line = readLine(strippingNewline: false) {
    do {
        try print(Tokenizer(line).jedString, terminator: "")
    } catch let error as KurtError {
        print("\nTokenizer Error: " + error.message)
        break
    }
}
