//
// Created by alex on 5/15/18.
//

import XCTest
@testable import Interpreter

public final class TokenizeTests: XCTestCase {
    func testPlusSymbol() {
        XCTAssertEqual(Tokenizer("+").jedString, "+:symbol\n")
    }
    
    func testGodel() throws {
        for i in 1...5 {
            print("Testing file \(i)")
            let input = try String(contentsOfFile: "/Users/alex/college/PL/kurtscheme/testfiles/test.tokenizer.input.0\(i)")
            let output = try String(contentsOfFile: "/Users/alex/college/PL/kurtscheme/testfiles/test.tokenizer.output.0\(i)")
            XCTAssertEqual(Tokenizer(input).jedString, output)
        }
    }

    static var allTests = [
        ("testPlusSymbol", testPlusSymbol),
        ("testGodel", testGodel),
    ]
}
