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
        output << i;
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

TEST(MainTest, TestParser3)
{
    test_parser("3");
}

TEST(MainTest, TestParser4)
{
    test_parser("4");
}

TEST(MainTest, TestParser5)
{
    test_parser("5");
}

TEST(MainTest, TestParser6)
{
    test_parser("6");
}

TEST(MainTest, TestParser7)
{
    test_parser("7");
}

TEST(MainTest, TestExpr)
{
    // atom
    Expr id;
    id.type = Expr::Type::IDENTIFIER;
    id.data = "var";

    // unary expr
    Expr uexpr;
    uexpr.type = Expr::Type::INVERT;
    uexpr.data = make_unique<Expr>(std::move(id));

    // binary expr
    Expr id1;
    id1.type = Expr::Type::IDENTIFIER;
    id1.data = "var1";
    Expr id2;
    id2.type = Expr::Type::IDENTIFIER;
    id2.data = "var2";
    Expr bexpr;
    bexpr.type = Expr::Type::ADD;
    bexpr.data = make_pair(make_unique<Expr>(std::move(id1)), make_unique<Expr>(std::move(id2)));
}