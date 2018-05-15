//
// Created by alex on 5/15/18.
//

import XCTest
@testable import Interpreter

public final class TokenizeTests: XCTestCase {
    func godel01() {
        XCTAssertEqual(Tokenizer("+").jedString, "+:string")
    }

    static var allTests = [
        ("godel01", godel01),
    ]
}