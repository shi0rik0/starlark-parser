#include "utils.h"
#include "parser.h"
#include "types.h"
#include <iostream>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

void print_token(int token, const YYSTYPE& value)
{
    /*----- Print token names -----*/
    switch (token) {
    case yy::parser::token::IDENTIFIER:
        printf("identifier(%s)\n", value.as<string>().c_str());
        break;
    case yy::parser::token::INT:
        printf("int(%s)\n", value.as<string>().c_str());
        break;
    case yy::parser::token::FLOAT:
        printf("float(%f)\n", value.as<double>());
        break;
    case yy::parser::token::STRING:
        printf("string(%s)\n", value.as<string>().c_str());
        break;
    case yy::parser::token::BYTES:
        printf("bytes\n");
        break;
    case yy::parser::token::NEW_LINE:
        printf("new_line\n");
        break;
    case yy::parser::token::INDENT:
        printf("indent\n");
        break;
    case yy::parser::token::ASSIGN:
        printf("assign\n");
        break;
    case yy::parser::token::ADD:
        printf("add\n");
        break;
    case yy::parser::token::SUB:
        printf("sub\n");
        break;
    case yy::parser::token::MUL:
        printf("mul\n");
        break;
    case yy::parser::token::DIV:
        printf("div\n");
        break;
    case yy::parser::token::FLOORDIV:
        printf("floordiv\n");
        break;
    case yy::parser::token::MOD:
        printf("mod\n");
        break;
    case yy::parser::token::POW:
        printf("pow\n");
        break;
    case yy::parser::token::RSHIFT:
        printf("rshift\n");
        break;
    case yy::parser::token::LSHIFT:
        printf("lshift\n");
        break;
    case yy::parser::token::BITAND:
        printf("bitand\n");
        break;
    case yy::parser::token::BITOR:
        printf("bitor\n");
        break;
    case yy::parser::token::XOR:
        printf("xor\n");
        break;
    case yy::parser::token::IADD:
        printf("iadd\n");
        break;
    case yy::parser::token::ISUB:
        printf("isub\n");
        break;
    case yy::parser::token::IMUL:
        printf("imul\n");
        break;
    case yy::parser::token::IDIV:
        printf("idiv\n");
        break;
    case yy::parser::token::IFLOORDIV:
        printf("ifloordiv\n");
        break;
    case yy::parser::token::IMOD:
        printf("imod\n");
        break;
    case yy::parser::token::IPOW:
        printf("ipow\n");
        break;
    case yy::parser::token::IRSHIFT:
        printf("irshift\n");
        break;
    case yy::parser::token::ILSHIFT:
        printf("ilshift\n");
        break;
    case yy::parser::token::IBITAND:
        printf("ibitand\n");
        break;
    case yy::parser::token::IBITOR:
        printf("ibitor\n");
        break;
    case yy::parser::token::IXOR:
        printf("ixor\n");
        break;
    case yy::parser::token::LT:
        printf("lt\n");
        break;
    case yy::parser::token::GT:
        printf("gt\n");
        break;
    case yy::parser::token::LE:
        printf("le\n");
        break;
    case yy::parser::token::GE:
        printf("ge\n");
        break;
    case yy::parser::token::EQ:
        printf("eq\n");
        break;
    case yy::parser::token::NE:
        printf("ne\n");
        break;
    case yy::parser::token::POS:
        printf("pos\n");
        break;
    case yy::parser::token::NEG:
        printf("neg\n");
        break;
    case yy::parser::token::INVERT:
        printf("invert\n");
        break;
    case yy::parser::token::DOT:
        printf("dot\n");
        break;
    case yy::parser::token::COMMA:
        printf("comma\n");
        break;
    case yy::parser::token::SEMICOLON:
        printf("semicolon\n");
        break;
    case yy::parser::token::COLON:
        printf("colon\n");
        break;
    case yy::parser::token::LPAREN:
        printf("lparen\n");
        break;
    case yy::parser::token::RPAREN:
        printf("rparen\n");
        break;
    case yy::parser::token::LBRACKET:
        printf("lbracket\n");
        break;
    case yy::parser::token::RBRACKET:
        printf("rbracket\n");
        break;
    case yy::parser::token::LBRACE:
        printf("lbrace\n");
        break;
    case yy::parser::token::RBRACE:
        printf("rbrace\n");
        break;
    case yy::parser::token::AND:
        printf("and\n");
        break;
    case yy::parser::token::ELIF:
        printf("elif\n");
        break;
    case yy::parser::token::IN:
        printf("in\n");
        break;
    case yy::parser::token::OR:
        printf("or\n");
        break;
    case yy::parser::token::BREAK:
        printf("break\n");
        break;
    case yy::parser::token::ELSE:
        printf("else\n");
        break;
    case yy::parser::token::LAMBDA:
        printf("lambda\n");
        break;
    case yy::parser::token::PASS:
        printf("pass\n");
        break;
    case yy::parser::token::CONTINUE:
        printf("continue\n");
        break;
    case yy::parser::token::FOR:
        printf("for\n");
        break;
    case yy::parser::token::LOAD:
        printf("load\n");
        break;
    case yy::parser::token::RETURN:
        printf("return\n");
        break;
    case yy::parser::token::DEF:
        printf("def\n");
        break;
    case yy::parser::token::IF:
        printf("if\n");
        break;
    case yy::parser::token::NOT:
        printf("not\n");
        break;
    case yy::parser::token::WHILE:
        printf("while\n");
        break;
    case yy::parser::token::DEDENT:
        printf("dedent\n");
        break;
    default:
        fatal_error("error: unknown token");
        break;
    }
    /*-----  -----*/
}

char* new_str(char* str, int len)
{
    char* res = (char*)malloc(sizeof(char) * (len + 1));
    if (res == NULL) {
        fprintf(stderr, "Failure in malloc.\n");
        exit(1);
    }
    strcpy(res, str);
    return res;
}

void fatal_error(const std::string& error_msg)
{
    cerr << error_msg;
    if (error_msg.empty() || error_msg.back() != '\n') {
        cerr << endl;
    }
    exit(1);
}

std::string sprintfpp(const char* format, ...)
{
    static char buf[1];
    va_list args;
    va_start(args, format);
    int len = vsnprintf(buf, 1, format, args);
    va_end(args);
    char* s = new char[len + 1];
    va_start(args, format);
    vsnprintf(s, len + 1, format, args);
    va_end(args);
    string ret(s);
    delete[] s;
    return ret;
}