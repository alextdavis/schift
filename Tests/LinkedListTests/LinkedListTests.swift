//
// Created by alex on 5/15/18.
//

import XCTest
@testable import Interpreter

class LinkedListTests: XCTestCase {
    func testIterator() {
        var value = Value.null
        for i in 0...16 {
            value = Value.cons(car: Value.int(i), cdr: value)
        }
        
        value = try! value.reversed()

        var num = 0
        for val in value {
            guard case .int(let valNum) = val else {
                XCTFail("Found non-int in list")
                return
            }
            print("valnum: \(valNum), num: \(num)")
            XCTAssert(valNum == num)
            num += 1
        }
    }
}
