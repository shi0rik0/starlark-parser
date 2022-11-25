%language "c++"
%define api.value.type variant
%parse-param {StatementList **ret}

%code requires {
    #include "types.h"
}

%code provides
{
    #define YY_DECL int yylex(yy::parser::semantic_type *yylval)
    YY_DECL;
    
    typedef yy::parser::semantic_type YYSTYPE;
}

%code {
    #include "utils.h"
    #include <stdio.h>

    
    namespace yy
    {
    // Report an error to the user.
    void parser::error (const std::string& msg)
    {
        std::cerr << msg << '\n';
    }
    }
}


// See PrimaryExpr_Type in <types.h>
%token <std::string> IDENTIFIER
%token <std::string> INT
%token <double> FLOAT
%token <std::string> STRING
%token <std::string> BYTES

// White spaces
%token <NoneType> NEW_LINE INDENT DEDENT

// Punctuations
//            =
%token <NoneType> ASSIGN
//            +   -   *   /   //       %   **  >>     <<     &      |     ^
%token <NoneType> ADD SUB MUL DIV FLOORDIV MOD POW RSHIFT LSHIFT BITAND BITOR XOR
//            +=   -=   *=   /=   //=       %=   **=  <<=     >>=     &=      |=     ^=
%token <NoneType> IADD ISUB IMUL IDIV IFLOORDIV IMOD IPOW IRSHIFT ILSHIFT IBITAND IBITOR IXOR
//            <  >  <= >= == !=
%token <NoneType> LT GT LE GE EQ NE
//            +   -   ~
%token <NoneType> POS NEG INVERT
//            .   ,     ;         :
%token <NoneType> DOT COMMA SEMICOLON COLON
//            (      )      [        ]        {      }
%token <NoneType> LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE

// Keywords
%token <NoneType> AND ELIF IN OR BREAK ELSE LAMBDA PASS CONTINUE FOR LOAD RETURN DEF IF NOT WHILE

// Precedence and associativity

/* %left PLUS MINUS
%left TIMES
%left UMINUS */

/* %type <i> Start Expr */
%type <StatementList*> Start Statements 
%type <Statement*> ExprStatement
%type <Expr*> Expr PrimaryExpr

%%

// Grammar rules

Start 
    : Statements {
        // *ret = $1;
    }
;

Statements
    : ExprStatement {
        // $$ = new_statement_list($1, NULL);
    }
    | ExprStatement Statements {
        // $$ = new_statement_list($1, $2);
    }
;

ExprStatement
    : Expr NEW_LINE {
        // $$ = new_statement(Statement_Type_EXPR_STATEMENT, $1); 
    }
;

Expr
    : PrimaryExpr {
        // $$ = $1;
    }
    | IDENTIFIER {
        // $$ = $1;
    }
;

PrimaryExpr
    : INT {
        // $$ = new_primary_expr(PrimaryExpr_Type_INT, $1);
    }

