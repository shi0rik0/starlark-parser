#include "lexer.h"
#include "parser.h"
#include <cstdio>
#include <fstream>
#include <gtest/gtest.h>
#include <iostream>
#include <string>

using namespace std;

void test_lexer(const string& name)
{
    string program_file_path = string(WORKING_DIR) + "/programs/" + name + ".bzl";
    FILE* fp = fopen(program_file_path.c_str(), "r");
    EXPECT_TRUE(fp != nullptr);
    yyin = fp;
    string expected_output_path = string(WORKING_DIR) + "/expected_lexer_output/" + name + ".txt";
    ifstream ifs(expected_output_path);
    EXPECT_TRUE(ifs.good());
    string expected_output((istreambuf_iterator<char>(ifs)), (istreambuf_iterator<char>()));
    string output;
    YYSTYPE yylval;
    for (;;) {
        int token = yylex(&yylval);
        if (!token) {
            break;
        }
        output += token_to_str(token, yylval) + '\n';
    }
    EXPECT_TRUE(output == expected_output) << output;
}

TEST(MainTest, TestLexer1)
{
    test_lexer("1");
}