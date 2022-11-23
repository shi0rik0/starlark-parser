%option noyywrap


%top{
    // This part will be copied to lexer.h
    #include "types.h"
    #include "parser.h"
    #include "utils.h"
}


%{
    // This part will be copied to lexer.c
    #define RETURN_NOT_NEW_LINE(x) do { at_line_start = 0; return (x); } while (0)
    static int at_line_start = 1;
    char indent_char;
    int indent_num = 0;

    // str_all_eq("aaaaa", 'a') -> 1
    // str_all_eq("aaaab", 'a') -> 0
    int str_all_eq(const char* str, char c) {
        for (int i = 0; str[i] != '\0'; ++i) {
            if (str[i] != c) {
                return 0;
            }
        }
        return 1;
    }
%}

INT -?[0-9]+
IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*
FLOAT -?([0-9]+|[0-9]*.[0-9]*)(e[-?[0-9]+])?
STRING \".*\"|'.*'
BYTES b\".*\"|b'.*'

%%
    /* White spaces */
\n|\r\n {
    at_line_start = 1;
    return NEW_LINE;
}

<<EOF>> {
    return NEW_LINE;
}


[ \t]+ {
    if (indent_num == 0) {
        if (!str_all_eq(yytext + 1, yytext[0])) {
            // error
        }
        indent_char = yytext[0];
        indent_num = yyleng;
        RETURN_NOT_NEW_LINE(INDENT);
    }
    if (!(str_all_eq(yytext, indent_char) && indent_num == yyleng)) {
        // error
    }
    RETURN_NOT_NEW_LINE(INDENT);
}


    /* Punctuations */
"+" { RETURN_NOT_NEW_LINE(ADD); }
"-" { RETURN_NOT_NEW_LINE(SUB); }
"*" { RETURN_NOT_NEW_LINE(MUL); }
"/" { RETURN_NOT_NEW_LINE(DIV); }
"//" { RETURN_NOT_NEW_LINE(FLOORDIV); }
"%" { RETURN_NOT_NEW_LINE(MOD); }
"**" { RETURN_NOT_NEW_LINE(POW); }
">>" { RETURN_NOT_NEW_LINE(RSHIFT); }
"<<" { RETURN_NOT_NEW_LINE(LSHIFT); }
"&" { RETURN_NOT_NEW_LINE(BITAND); }
"|" { RETURN_NOT_NEW_LINE(BITOR); }
"^" { RETURN_NOT_NEW_LINE(XOR); }

"+=" { RETURN_NOT_NEW_LINE(IADD); }
"-=" { RETURN_NOT_NEW_LINE(ISUB); }
"*=" { RETURN_NOT_NEW_LINE(IMUL); }
"/=" { RETURN_NOT_NEW_LINE(IDIV); }
"//=" { RETURN_NOT_NEW_LINE(IFLOORDIV); }
"%=" { RETURN_NOT_NEW_LINE(IMOD); }
"**=" { RETURN_NOT_NEW_LINE(IPOW); }
"<<=" { RETURN_NOT_NEW_LINE(IRSHIFT); }
">>=" { RETURN_NOT_NEW_LINE(ILSHIFT); }
"&=" { RETURN_NOT_NEW_LINE(IBITAND); }
"|=" { RETURN_NOT_NEW_LINE(IBITOR); }
"^=" { RETURN_NOT_NEW_LINE(IXOR); }

"<" { RETURN_NOT_NEW_LINE(LT); }
">" { RETURN_NOT_NEW_LINE(GT); }
"<=" { RETURN_NOT_NEW_LINE(LE); }
">=" { RETURN_NOT_NEW_LINE(GE); }
"==" { RETURN_NOT_NEW_LINE(EQ); }
"!=" { RETURN_NOT_NEW_LINE(NE); }

"+" { RETURN_NOT_NEW_LINE(POS); }
"-" { RETURN_NOT_NEW_LINE(NEG); }
"~" { RETURN_NOT_NEW_LINE(INVERT); }

"." { RETURN_NOT_NEW_LINE(DOT); }
"," { RETURN_NOT_NEW_LINE(COMMA); }
";" { RETURN_NOT_NEW_LINE(SEMICOLON); }
":" { RETURN_NOT_NEW_LINE(COLON); }

"(" { RETURN_NOT_NEW_LINE(LPAREN); }
")" { RETURN_NOT_NEW_LINE(RPAREN); }
"[" { RETURN_NOT_NEW_LINE(LBRACKET); }
"]" { RETURN_NOT_NEW_LINE(RBRACKET); }
"{" { RETURN_NOT_NEW_LINE(LBRACE); }
"}" { RETURN_NOT_NEW_LINE(RBRACE); }

    /* Keywords */
"and" { RETURN_NOT_NEW_LINE(AND); }
"elif" { RETURN_NOT_NEW_LINE(ELIF); }
"in" { RETURN_NOT_NEW_LINE(IN); }
"or" { RETURN_NOT_NEW_LINE(OR); }
"break" { RETURN_NOT_NEW_LINE(BREAK); }
"else" { RETURN_NOT_NEW_LINE(ELSE); }
"lambda" { RETURN_NOT_NEW_LINE(LAMBDA); }
"pass" { RETURN_NOT_NEW_LINE(PASS); }
"continue" { RETURN_NOT_NEW_LINE(CONTINUE); }
"for" { RETURN_NOT_NEW_LINE(FOR); }
"load" { RETURN_NOT_NEW_LINE(LOAD); }
"return" { RETURN_NOT_NEW_LINE(RETURN); }
"def" { RETURN_NOT_NEW_LINE(DEF); }
"if" { RETURN_NOT_NEW_LINE(IF); }
"not" { RETURN_NOT_NEW_LINE(NOT); }
"while" { RETURN_NOT_NEW_LINE(WHILE); }


{IDENTIFIER} {
    
    RETURN_NOT_NEW_LINE(IDENTIFIER);
}

{INT} {
    yylval.string = yytext;
    RETURN_NOT_NEW_LINE(INT);
}

{FLOAT} {
    
    RETURN_NOT_NEW_LINE(FLOAT);
}

{STRING} {
    
    RETURN_NOT_NEW_LINE(STRING);
}

{BYTES} {
    
    RETURN_NOT_NEW_LINE(BYTES);
}

{LIST} {
    
    RETURN_NOT_NEW_LINE(LIST);
}

{TUPLE} {
    
    RETURN_NOT_NEW_LINE(TUPLE);
}

{DICT} {
    
    RETURN_NOT_NEW_LINE(DICT);
}


    /* Default */
. {
    // error
}
