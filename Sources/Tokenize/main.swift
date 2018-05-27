//
//  main.swift
//  kurtscheme
//
//  Created by Alex Davis on 5/14/18.
//  Copyright © 2018 Alex T. Davis. All rights reserved.
//

import Foundation
import Interpreter

while let line = readLine(strippingNewline: false) {
    do {
        try print(Tokenizer(line).jedString, terminator: "")
    } catch let error as KurtError {
        print("\nTokenizer Error: " + error.message)
        break
    }
}
