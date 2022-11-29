#include "expr.h"
#include "lexer.h"
#include "parser.h"
#include <cstdio>
#include <fstream>
#include <gtest/gtest.h>
#include <iostream>
#include <memory>
#include <sstream>
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
    EXPECT_TRUE(output == expected_output) << "[Actual]\n"
                                           << output << "\n[Expected]\n"
                                           << expected_output << endl;
}

void test_parser(const string& name)
{
    string program_file_path = string(WORKING_DIR) + "/programs/" + name + ".bzl";
    FILE* fp = fopen(program_file_path.c_str(), "r");
    EXPECT_TRUE(fp != nullptr);
    yyin = fp;
    string expected_output_path = string(WORKING_DIR) + "/expected_parser_output/" + name + ".txt";
    ifstream ifs(expected_output_path);
    EXPECT_TRUE(ifs.good());
    string expected_output((istreambuf_iterator<char>(ifs)), (istreambuf_iterator<char>()));
    stringstream output;

    deque<Statement> v;

    yy::parser parser(v);
    parser.parse();

    for (const Statement& i : v) {
        output << i << endl;
    }

    EXPECT_TRUE(output.str() == expected_output) << "[Actual]\n"
                                                 << output.str() << "\n[Expected]\n"
                                                 << expected_output << endl;
}

TEST(MainTest, TestLexer1)
{
    test_lexer("1");
}

TEST(MainTest, TestParser2)
{
    test_parser("2");
}

TEST(MainTest, TestExpr)
{
    DotExpr dot_expr;
    dot_expr.attr = "ok";
    dot_expr.obj = make_unique<Expr>();
    dot_expr.obj->data = "ok";
    dot_expr.obj->type = Expr::Type::STRING;
    Expr expr;
    expr.type = Expr::Type::DOT;
    expr.data = std::move(dot_expr);
    EXPECT_TRUE(get<DotExpr>(expr.data).attr == "ok");
}