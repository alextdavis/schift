import XCTest
@testable import Interpreter

public final class ParserTests: XCTestCase {
    func testGodel() throws {
        for i in 1...5 {
            print("Testing file \(i)")
            let input = try String(contentsOfFile: "/Users/alex/college/PL/kurtscheme/testfiles/test.parser.input.0\(i)")
            let output = try String(contentsOfFile: "/Users/alex/college/PL/kurtscheme/testfiles/test.parser.output.0\(i)")
            try XCTAssertEqual(
                    Parser.treeToJedString(Parser.parse(Tokenizer(input).array))! + "\n",
                    output)
        }
    }

    func testEmptyParens() {
        do {
            let tree = try Parser.parse(try Tokenizer("()").array)
            print(tree)
        } catch {

        }
    }

    static var allTests = [
        ("testGodel", testGodel),
    ]
}
