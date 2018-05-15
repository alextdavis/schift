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
    print(Tokenizer(line).jedString, terminator: "")
}
