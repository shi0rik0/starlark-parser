cmake_minimum_required(VERSION 3.14)

# suppress warning about DOWNLOAD_EXTRACT_TIMESTAMP
cmake_policy(SET CMP0135 NEW)

set(CMAKE_CXX_STANDARD 14)

project(StarlarkParser)

set(SRC_DIR "src")
set(PARSER_DIR "${CMAKE_CURRENT_BINARY_DIR}")

find_package(FLEX 2.6 REQUIRED)
find_package(BISON 3.0 REQUIRED)

set(LEXER_OUT "${PARSER_DIR}/lexer.c")
set(PARSER_OUT "${PARSER_DIR}/parser.c")

flex_target(LEXER "${SRC_DIR}/lexer.l" "${LEXER_OUT}" DEFINES_FILE "${PARSER_DIR}/lexer.h")
bison_target(PARSER "${SRC_DIR}/parser.y" "${PARSER_OUT}" DEFINES_FILE "${PARSER_DIR}/parser.h")
add_flex_bison_dependency(LEXER PARSER)

set(SRCS "src/debug.c" "src/types.c" "src/utils.c" "${LEXER_OUT}" "${PARSER_OUT}")
set(INCLUDES "${PARSER_DIR}" "include")

add_executable(parser "src/main_parser.c" ${SRCS})
target_include_directories(parser PRIVATE ${INCLUDES})

add_executable(lexer "src/main_lexer.c" ${SRCS})
target_include_directories(lexer PRIVATE ${INCLUDES})


### import GoogleTest

include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/03597a01ee50ed33e9dfd640b249b4be3799d395.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

add_executable(
  main_test
  tests/main_test.cpp
)
target_link_libraries(
  main_test
  GTest::gtest_main
)

include(GoogleTest)
gtest_discover_tests(main_test)
