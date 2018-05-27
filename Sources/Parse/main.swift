import Interpreter

var tokens = [Value]()

while let line = readLine(strippingNewline: false) {
    do {
        try tokens += Tokenizer(line).array
//        try print(Parser.parse(Tokenizer(line).list).jedTreeString, terminator: "")
    } catch let error as KurtError {
        print(error.message)
    }
}

let tree = try Parser.parse(tokens)

print(try Parser.treeToJedString(tree)!)
