import Interpreter

var tokens = [Value]()

while let line = readLine(strippingNewline: false) {
    do {
        try tokens += Tokenizer(line).array
//        try print(Parser.parse(Tokenizer(line).list).jedTreeString, terminator: "")
    } catch Parser.ParserError.unmatchedOpen {
        print("Parser Error: Unmatched open parenthesis.")
        break
    } catch Parser.ParserError.unmatchedClose {
        print("Parser Error: Unmatched close parenthesis.")
    } catch Tokenizer.TokenizerError.other(let msg) {
        print("Tokenizer Error: " + msg)
        break
    }
}

let tree = try Parser.parse(tokens)

print(Parser.treeToJedString(tree)!)
