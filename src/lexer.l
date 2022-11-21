%option noyywrap

%top {
    #include "types.h"
    #include "parser.h"
}

INTEGER [0-9]+

IDENTIFIER 1
INT 1
FLOAT 1
STRING 1
BYTES 1
LIST 1
TUPLE 1
DICT 1

%%

    /* Punctuations */
"+" { return ADD; }
"-" { return SUB; }
"*" { return MUL; }
"/" { return DIV; }
"//" { return FLOORDIV; }
"%" { return MOD; }
"**" { return POW; }
">>" { return RSHIFT; }
"<<" { return LSHIFT; }
"&" { return BITAND; }
"|" { return BITOR; }
"^" { return XOR; }

"+=" { return IADD; }
"-=" { return ISUB; }
"*=" { return IMUL; }
"/=" { return IDIV; }
"//=" { return IFLOORDIV; }
"%=" { return IMOD; }
"**=" { return IPOW; }
"<<=" { return IRSHIFT; }
">>=" { return ILSHIFT; }
"&=" { return IBITAND; }
"|=" { return IBITOR; }
"^=" { return IXOR; }

"<" { return LT; }
">" { return GT; }
"<=" { return LE; }
">=" { return GE; }
"==" { return EQ; }
"!=" { return NE; }

"+" { return POS; }
"-" { return NEG; }
"~" { return INVERT; }

"." { return DOT; }
"," { return COMMA; }
";" { return SEMICOLON; }
":" { return COLON; }

"(" { return LPAREN; }
")" { return RPAREN; }
"[" { return LBRACKET; }
"]" { return RBRACKET; }
"{" { return LBRACE; }
"}" { return RBRACE; }

    /* Keywords */
"and" { return AND; }
"elif" { return ELIF; }
"in" { return IN; }
"or" { return OR; }
"break" { return BREAK; }
"else" { return ELSE; }
"lambda" { return LAMBDA; }
"pass" { return PASS; }
"continue" { return CONTINUE; }
"for" { return FOR; }
"load" { return LOAD; }
"return" { return RETURN; }
"def" { return DEF; }
"if" { return IF; }
"not" { return NOT; }
"while" { return WHILE; }

{INTEGER} {
    yylval.i = atoi(yytext);
    return INTEGER;
}

{IDENTIFIER} {
    
    return IDENTIFIER;
}

{INT} {
    
    return INT;
}

{FLOAT} {
    
    return FLOAT;
}

{STRING} {
    
    return STRING;
}

{BYTES} {
    
    return BYTES;
}

{LIST} {
    
    return LIST;
}

{TUPLE} {
    
    return TUPLE;
}

{DICT} {
    
    return INTEGER;
}


    /* Default */
. {

}
