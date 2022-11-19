%option noyywrap

%top {
    #include "parser.h"
}

INTEGER [0-9]+

%%

"+" { return ADD; }
"-" { return SUB; }
"*" { return MUL; }
"(" { return LPAREN; }
")" { return RPAREN; }

{INTEGER} {
    yylval.i = atoi(yytext);
    return INTEGER;
}

. {

}
