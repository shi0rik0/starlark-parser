#include "lexer.h"
#include "parser.h"
#include "utils.h"
#include <iostream>

using namespace std;

int main()
{
    YYSTYPE yylval;
    for (;;) {
        int token = yylex(&yylval);
        if (!token) {
            break;
        }
        print_token(token, yylval);
    }
}