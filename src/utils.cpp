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
    case IDENTIFIER:
        printf("identifier(%s)\n", value.string);
        break;
    case INT:
        printf("int(%s)\n", value.string);
        break;
    case FLOAT:
        printf("float(%f)\n", value.float_);
        break;
    case STRING:
        printf("string(%s)\n", value.string);
        break;
    case BYTES:
        printf("bytes\n");
        break;
    case LIST:
        printf("list\n");
        break;
    case TUPLE:
        printf("tuple\n");
        break;
    case DICT:
        printf("dict\n");
        break;
    case NEW_LINE:
        printf("new_line\n");
        break;
    case INDENT:
        printf("indent\n");
        break;
    case ASSIGN:
        printf("assign\n");
        break;
    case ADD:
        printf("add\n");
        break;
    case SUB:
        printf("sub\n");
        break;
    case MUL:
        printf("mul\n");
        break;
    case DIV:
        printf("div\n");
        break;
    case FLOORDIV:
        printf("floordiv\n");
        break;
    case MOD:
        printf("mod\n");
        break;
    case POW:
        printf("pow\n");
        break;
    case RSHIFT:
        printf("rshift\n");
        break;
    case LSHIFT:
        printf("lshift\n");
        break;
    case BITAND:
        printf("bitand\n");
        break;
    case BITOR:
        printf("bitor\n");
        break;
    case XOR:
        printf("xor\n");
        break;
    case IADD:
        printf("iadd\n");
        break;
    case ISUB:
        printf("isub\n");
        break;
    case IMUL:
        printf("imul\n");
        break;
    case IDIV:
        printf("idiv\n");
        break;
    case IFLOORDIV:
        printf("ifloordiv\n");
        break;
    case IMOD:
        printf("imod\n");
        break;
    case IPOW:
        printf("ipow\n");
        break;
    case IRSHIFT:
        printf("irshift\n");
        break;
    case ILSHIFT:
        printf("ilshift\n");
        break;
    case IBITAND:
        printf("ibitand\n");
        break;
    case IBITOR:
        printf("ibitor\n");
        break;
    case IXOR:
        printf("ixor\n");
        break;
    case LT:
        printf("lt\n");
        break;
    case GT:
        printf("gt\n");
        break;
    case LE:
        printf("le\n");
        break;
    case GE:
        printf("ge\n");
        break;
    case EQ:
        printf("eq\n");
        break;
    case NE:
        printf("ne\n");
        break;
    case POS:
        printf("pos\n");
        break;
    case NEG:
        printf("neg\n");
        break;
    case INVERT:
        printf("invert\n");
        break;
    case DOT:
        printf("dot\n");
        break;
    case COMMA:
        printf("comma\n");
        break;
    case SEMICOLON:
        printf("semicolon\n");
        break;
    case COLON:
        printf("colon\n");
        break;
    case LPAREN:
        printf("lparen\n");
        break;
    case RPAREN:
        printf("rparen\n");
        break;
    case LBRACKET:
        printf("lbracket\n");
        break;
    case RBRACKET:
        printf("rbracket\n");
        break;
    case LBRACE:
        printf("lbrace\n");
        break;
    case RBRACE:
        printf("rbrace\n");
        break;
    case AND:
        printf("and\n");
        break;
    case ELIF:
        printf("elif\n");
        break;
    case IN:
        printf("in\n");
        break;
    case OR:
        printf("or\n");
        break;
    case BREAK:
        printf("break\n");
        break;
    case ELSE:
        printf("else\n");
        break;
    case LAMBDA:
        printf("lambda\n");
        break;
    case PASS:
        printf("pass\n");
        break;
    case CONTINUE:
        printf("continue\n");
        break;
    case FOR:
        printf("for\n");
        break;
    case LOAD:
        printf("load\n");
        break;
    case RETURN:
        printf("return\n");
        break;
    case DEF:
        printf("def\n");
        break;
    case IF:
        printf("if\n");
        break;
    case NOT:
        printf("not\n");
        break;
    case WHILE:
        printf("while\n");
        break;
    case DEDENT:
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