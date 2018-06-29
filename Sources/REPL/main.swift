import Interpreter

var tokens = [Value]()

print("KurtScheme 0.0.1")
print("KS> ", terminator: "")
let interpreter = Interpreter.instance
while let line = readLine(strippingNewline: false) {
    if line == "exit\n" {
        break
    }
    do {
        try tokens += Tokenizer(line).array
        let vals = try interpreter.interpret(source: line)
        for val in vals {
            print(val)
        }
    } catch let error as KurtError {
        print(error.message)
    }
    print("\nKS> ", terminator: "")
}
