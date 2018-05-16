import Interpreter

var tokens = [Value]()

while let line = readLine(strippingNewline: false) {
    tokens += Tokenizer(line)
}

print(Parser.parse(tokens))

