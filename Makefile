.PHONY: all
all: lexer parser ;

.PHONY: lexer
lexer: build
	cmake --build build --target lexer

.PHONY: parser
parser: build
	cmake --build build --target parser

build: CMakeLists.txt
	cmake -DCMAKE_C_COMPILER:FILEPATH=/usr/bin/gcc -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++ -Bbuild

.PHONY: run-lexer
run-lexer: lexer
	./build/lexer

.PHONY: run-parser
run-parser: parser
	./build/parser

.PHONY: test
test: lexer parser
	cd build && ctest -j18 -C Debug -T test --output-on-failure

.PHONY: clean
clean:
	rm -rf build