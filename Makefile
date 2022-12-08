RELEASE := 0

ifeq ($(RELEASE),0)
# debug
CMAKE_BUILD_TYPE := Debug
else
ifeq ($(RELEASE),1)
# release
CMAKE_BUILD_TYPE := Release
else
$(error RELEASE should be 0 or 1)
endif
endif

.PHONY: all
all: lexer parser unittest;

.PHONY: lexer
lexer: build
	cmake --build build --target lexer -j 18

.PHONY: parser
parser: build
	cmake --build build --target parser -j 18

.PHONY: unittest
unittest: build
	cmake --build build --target main_test -j 18

build: CMakeLists.txt
	cmake -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) -DCMAKE_C_COMPILER:FILEPATH=gcc \
		  -DCMAKE_CXX_COMPILER:FILEPATH=g++ -Bbuild -G "Unix Makefiles"

.PHONY: run-lexer
run-lexer: lexer
	./build/lexer

.PHONY: run-parser
run-parser: parser
	./build/parser

.PHONY: test
test: lexer parser unittest
	cd build && ctest -j18 -C Debug -T test --output-on-failure

.PHONY: clean
clean:
	rm -rf build

.PHONY: bison-verbose
bison-verbose:
	bison src/parser.y --output=/dev/null \
	--verbose --report-file=temp/bison-verbose.txt > temp/bison-warnings.txt 2>&1
