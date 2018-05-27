import Interpreter

var tokens = [Value]()

print("KurtScheme 0.0.1")
print("KS> ")
while let line = readLine(strippingNewline: false) {
    if line == "exit\n" {
        break
    }
    do {
        try tokens += Tokenizer(line).array
        try print(Parser.parse(Tokenizer(line).list).jedTreeString, terminator: "")
    } catch let error as KurtError {
        print(error.message)
    }
    print("KS> ")
}
