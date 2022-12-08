## Introduction

This is a simple parser of Starlark implemented with flex and bison.

## Building Requirements

You should make sure that these commands are available in your environment: `make`, `cmake`, `flex`, `bison` and `g++`.

## How to Build and Execute

First run `make clean && make test`. If you see a message saying all tests are passed, the building is successful. The compiled program is `build/parser`. You can also run the parser by executing `make run-parser`.

## Known Issues

This parser can't handle non-ASCII characters properly.
