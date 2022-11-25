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
        cout << token_to_str(token, yylval) << endl;
    }
}