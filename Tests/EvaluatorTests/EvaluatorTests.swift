import XCTest
@testable import Interpreter

public final class EvaluatorTests: XCTestCase {
    func testGodel() throws {
        for i in 1...16 {
            print("Testing file \(i)")
            let interpreter = Interpreter()
            let input = try String(contentsOfFile: "/Users/alex/college/PL/kurtscheme/" +
                    "testfiles/test.eval.input.\(String(format: "%02d", i))")
            let output = try String(contentsOfFile: "/Users/alex/college/PL/kurtscheme/" +
                    "testfiles/test.eval.output.\(String(format: "%02d", i))")
            try XCTAssertEqual(
                    interpreter.interpret(source: input).jedEvalString,
                    output)
        }
    }

    static var allTests = [
        ("testGodel", testGodel),
    ]
}
