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

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

var inputs = [String]()

for num in 1...26 {
    inputs.append(try String(contentsOfFile:
                             "./testfiles/test.eval.input.\(String(format: "%02d", num))"))
}

let iters: Int

if CommandLine.arguments.count > 1,
   let num = Int(CommandLine.arguments[1]) {
    iters = num
} else {
    iters = 5
}

print("Running \(iters) times")

let start = clock()
for _ in 0..<iters {
    for input in inputs {
        Interpreter.default = Interpreter()
        _ = try Interpreter.default.interpret(source: input)
    }
}
let end = clock()

print("\(Double(end - start) / 1000000) Million time units.")
