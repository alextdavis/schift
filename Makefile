.PHONY: build release test xcode clean repl bench diffs

build:
	swift build

release:
	swift build -c release

test:
	swift test

xcode:
	osascript -e "tell application \"Xcode\" to quit"
	swift package generate-xcodeproj
	open Kurtscheme.xcodeproj

clean:
	rm -r .build/

repl: build
	./.build/debug/Schift

bench: release
	./.build/release/Benchmark

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
	./.build/debug/Schift testfiles/test.eval.input.01 | diff - testfiles/test.eval.output.01
	./.build/debug/Schift testfiles/test.eval.input.02 | diff - testfiles/test.eval.output.02
	./.build/debug/Schift testfiles/test.eval.input.03 | diff - testfiles/test.eval.output.03
	./.build/debug/Schift testfiles/test.eval.input.04 | diff - testfiles/test.eval.output.04
	./.build/debug/Schift testfiles/test.eval.input.05 | diff - testfiles/test.eval.output.05
	./.build/debug/Schift testfiles/test.eval.input.06 | diff - testfiles/test.eval.output.06
	./.build/debug/Schift testfiles/test.eval.input.07 | diff - testfiles/test.eval.output.07
	./.build/debug/Schift testfiles/test.eval.input.08 | diff - testfiles/test.eval.output.08
	./.build/debug/Schift testfiles/test.eval.input.09 | diff - testfiles/test.eval.output.09
	./.build/debug/Schift testfiles/test.eval.input.10 | diff - testfiles/test.eval.output.10
	./.build/debug/Schift testfiles/test.eval.input.11 | diff - testfiles/test.eval.output.11
	./.build/debug/Schift testfiles/test.eval.input.12 | diff - testfiles/test.eval.output.12
	./.build/debug/Schift testfiles/test.eval.input.13 | diff - testfiles/test.eval.output.13
	./.build/debug/Schift testfiles/test.eval.input.14 | diff - testfiles/test.eval.output.14
	./.build/debug/Schift testfiles/test.eval.input.15 | diff - testfiles/test.eval.output.15
	./.build/debug/Schift testfiles/test.eval.input.16 | diff - testfiles/test.eval.output.16
	./.build/debug/Schift testfiles/test.eval.input.17 | diff - testfiles/test.eval.output.17
	./.build/debug/Schift testfiles/test.eval.input.18 | diff - testfiles/test.eval.output.18
	./.build/debug/Schift testfiles/test.eval.input.19 | diff - testfiles/test.eval.output.19
	./.build/debug/Schift testfiles/test.eval.input.20 | diff - testfiles/test.eval.output.20
	./.build/debug/Schift testfiles/test.eval.input.21 | diff - testfiles/test.eval.output.21
	./.build/debug/Schift testfiles/test.eval.input.22 | diff - testfiles/test.eval.output.22
	./.build/debug/Schift testfiles/test.eval.input.23 | diff - testfiles/test.eval.output.23
	./.build/debug/Schift testfiles/test.eval.input.24 | diff - testfiles/test.eval.output.24
	./.build/debug/Schift testfiles/test.eval.input.25 | diff - testfiles/test.eval.output.25
	./.build/debug/Schift testfiles/test.eval.input.26 | diff - testfiles/test.eval.output.26
