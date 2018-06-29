.PHONY: build test xcode diffs

build:
	swift build

test:
	swift test

xcode:
	osascript -e "tell application \"Xcode\" to quit"
	swift package generate-xcodeproj
	open Kurtscheme.xcodeproj

diffs: build
	./.build/debug/Tokenize < testfiles/test.tokenizer.input.01 | diff - testfiles/test.tokenizer.output.01
	./.build/debug/Tokenize < testfiles/test.tokenizer.input.02 | diff - testfiles/test.tokenizer.output.02
	./.build/debug/Tokenize < testfiles/test.tokenizer.input.03 | diff - testfiles/test.tokenizer.output.03
	./.build/debug/Tokenize < testfiles/test.tokenizer.input.04 | diff - testfiles/test.tokenizer.output.04
	./.build/debug/Tokenize < testfiles/test.tokenizer.input.05 | diff - testfiles/test.tokenizer.output.05
	./.build/debug/Parse < testfiles/test.parser.input.01 | diff - testfiles/test.parser.output.01
	./.build/debug/Parse < testfiles/test.parser.input.02 | diff - testfiles/test.parser.output.02
	./.build/debug/Parse < testfiles/test.parser.input.03 | diff - testfiles/test.parser.output.03
	./.build/debug/Parse < testfiles/test.parser.input.04 | diff - testfiles/test.parser.output.04
	./.build/debug/Parse < testfiles/test.parser.input.05 | diff - testfiles/test.parser.output.05
#	./interpreter < test.interpreter.input.01 | diff - test.interpreter.output.01
#	./interpreter < test.interpreter.input.02 | diff - test.interpreter.output.02
#	./interpreter < test.interpreter.input.03 | diff - test.interpreter.output.03
#	./interpreter < test.interpreter.input.04 | diff - test.interpreter.output.04
#	./interpreter < test.interpreter.input.05 | diff - test.interpreter.output.05
#	./interpreter < test.interpreter.input.06 | diff - test.interpreter.output.06

