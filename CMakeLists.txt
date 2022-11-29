cmake_minimum_required(VERSION 3.14)

# suppress warning about DOWNLOAD_EXTRACT_TIMESTAMP
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
		cmake_policy(SET CMP0135 NEW)
endif()

set(CMAKE_CXX_STANDARD 17)

project(StarlarkParser)

set(SRC_DIR "src")
set(PARSER_DIR "${CMAKE_CURRENT_BINARY_DIR}")

find_package(FLEX 2.6 REQUIRED)
find_package(BISON 3.0 REQUIRED)

set(LEXER_OUT "${PARSER_DIR}/lexer.cpp")
set(PARSER_OUT "${PARSER_DIR}/parser.cpp")

flex_target(LEXER "${SRC_DIR}/lexer.l" "${LEXER_OUT}" DEFINES_FILE "${PARSER_DIR}/lexer.h")
bison_target(PARSER "${SRC_DIR}/parser.y" "${PARSER_OUT}" DEFINES_FILE "${PARSER_DIR}/parser.h")
add_flex_bison_dependency(LEXER PARSER)

set(SRCS "src/types.cpp" "src/utils.cpp" "src/expr.cpp" "${LEXER_OUT}" "${PARSER_OUT}")
set(INCLUDES "${PARSER_DIR}" "include")

add_executable(parser "src/main_parser.cpp" ${SRCS})
target_include_directories(parser PRIVATE ${INCLUDES})
target_compile_definitions(parser PRIVATE DEBUG)

add_executable(lexer "src/main_lexer.cpp" ${SRCS})
target_include_directories(lexer PRIVATE ${INCLUDES})
target_compile_definitions(lexer PRIVATE DEBUG)


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

add_executable(main_test tests/main_test.cpp ${SRCS})
target_include_directories(main_test PRIVATE ${INCLUDES})
target_link_libraries(main_test GTest::gtest_main)
target_compile_definitions(main_test PRIVATE WORKING_DIR="${CMAKE_SOURCE_DIR}/tests")

include(GoogleTest)
gtest_discover_tests(main_test)

