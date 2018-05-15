//
//  Errors.swift
//  kurtscheme
//
//  Created by Alex Davis on 5/15/18.
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation

public enum KurtError: Error {
    case Token
    case Parse
    case Eval
    case Arity
    case Other
}

extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}

private var standardError = FileHandle.standardError

public func error(_ err: KurtError, _ message: String) {
    print(message, to:&standardError)
    switch err {
    case .Token:
        exit(3)
    case .Parse:
        exit(5)
    case .Eval:
        exit(6)
    case .Arity:
        exit(7)
    default:
        exit(1)
    }
    exit(1)
}
