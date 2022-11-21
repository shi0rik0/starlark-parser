%parse-param {int *ret}

%code top {
    #include "types.h"
    #include <stdio.h>

    extern int yylex(void);

    static void yyerror(int *ret, const char* s) {
        fprintf(stderr, "%s\n", s);
    }
}

%union {
    int i;
    char* string;
    double float_;
    ExprList* expr_list;
    MappingList* mapping_list;
    struct{} none;
}





// Literals
%token <i> INTEGER

// See PrimaryExpr_Type in <types.h>
%token <string> IDENTIFIER
%token <string> INT
%token <float_> FLOAT
%token <string> STRING
%token <string> BYTES
%token <expr_list> LIST
%token <expr_list> TUPLE
%token <mapping_list> DICT

// Punctuations
//            =
%token <none> ASSIGN
//            +   -   *   /   //       %   **  >>     <<     &      |     ^
%token <none> ADD SUB MUL DIV FLOORDIV MOD POW RSHIFT LSHIFT BITAND BITOR XOR
//            +=   -=   *=   /=   //=       %=   **=  <<=     >>=     &=      |=     ^=
%token <none> IADD ISUB IMUL IDIV IFLOORDIV IMOD IPOW IRSHIFT ILSHIFT IBITAND IBITOR IXOR
//            <  >  <= >= == !=
%token <none> LT GT LE GE EQ NE
//            +   -   ~
%token <none> POS NEG INVERT
//            .   ,     ;         :
%token <none> DOT COMMA SEMICOLON COLON
//            (      )      [        ]        {      }
%token <none> LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE

// Keywords
%token <none> AND ELIF IN OR BREAK ELSE LAMBDA PASS CONTINUE FOR LOAD RETURN DEF IF NOT WHILE

// Precedence and associativity

/* %left PLUS MINUS
%left TIMES
%left UMINUS */

%type <i> Start Expr

%%

// Grammar rules

Start 
    : Expr {
        *ret = $1;
    }
;

Expr
    : Expr ADD Expr {
        $$ = $1 + $3;
    }
    | Expr SUB Expr {
        $$ = $1 - $3;
    }
    | Expr MUL Expr {
        $$ = $1 * $3;
    }
    | SUB Expr %prec NEG {
        $$ = -$2;
    }
    | LPAREN Expr RPAREN {
        $$ = $2;
    }
    | INTEGER {
        $$ = $1;
    }
;
