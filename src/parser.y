%parse-param {StatementList **ret}

%code requires {
    #include "types.h"
}

%code {
    
    #include <stdio.h>

    extern int yylex(void);

    static void yyerror(StatementList **ret, const char* s) {
        fprintf(stderr, "%s\n", s);
    }
}

%union {
    char* string;
    double float_;
    ExprList* expr_list;
    MappingList* mapping_list;
    StatementList* statement_list;
    Statement* statement;
    Expr* expr;
    struct{} none;
}


// See PrimaryExpr_Type in <types.h>
%token <string> IDENTIFIER
%token <string> INT
%token <float_> FLOAT
%token <string> STRING
%token <string> BYTES
%token <expr_list> LIST
%token <expr_list> TUPLE
%token <mapping_list> DICT

// White spaces
%token <none> NEW_LINE INDENT

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

/* %type <i> Start Expr */
%type <statement_list> Start Statements 
%type <statement> ExprStatement
%type <expr> Expr PrimaryExpr

%%

// Grammar rules

Start 
    : Statements {
        *ret = $1;
    }
;

Statements
    : ExprStatement {
        $$ = new_statement_list($1, NULL);
    }
    | ExprStatement Statements {
        $$ = new_statement_list($1, $2);
    }
;

ExprStatement
    : Expr NEW_LINE {
        $$ = new_statement(Statement_Type_EXPR_STATEMENT, $1); 
    }
;

Expr
    : PrimaryExpr {
        $$ = $1;
    }
    | IDENTIFIER {
        $$ = $1;
    }
;

PrimaryExpr
    : INT {
        $$ = new_primary_expr(PrimaryExpr_Type_INT, $1);
    }

