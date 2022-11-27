%language "c++"
%define api.value.type variant
%parse-param {std::vector<Statement>& ret}

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

    using namespace std;
    
    namespace yy
    {
    // Report an error to the user.
    void parser::error (const std::string& msg)
    {
        std::cerr << msg << '\n';
    }
    }
}


%token <std::string> IDENTIFIER
%token <std::string> INT
%token <double> FLOAT
%token <std::string> STRING
%token <std::string> BYTES

// White spaces
%token <NoneType> NEW_LINE INDENT DEDENT

// Punctuations
//                =
%token <NoneType> ASSIGN
// binary op:     +   -   *   /   //       %   **  >>     <<     &      |     ^
%token <NoneType> ADD SUB MUL DIV FLOORDIV MOD POW RSHIFT LSHIFT BITAND BITOR XOR
//                +=   -=   *=   /=   //=       %=   **=  <<=     >>=     &=      |=     ^=
%token <NoneType> IADD ISUB IMUL IDIV IFLOORDIV IMOD IPOW IRSHIFT ILSHIFT IBITAND IBITOR IXOR
// binary op:     <  >  <= >= == !=
%token <NoneType> LT GT LE GE EQ NE
// unary op:      +   -   ~
%token <NoneType> POS NEG INVERT
//                .   ,     ;         :        PS: dot can be regarded as a binary op
%token <NoneType> DOT COMMA SEMICOLON COLON
//                (      )      [        ]        {      }
%token <NoneType> LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE

// Keywords
// "not" is a unary op, and "and", "or", "in" and "not in" are binary ops.
%token <NoneType> AND ELIF IN OR BREAK ELSE LAMBDA PASS CONTINUE FOR LOAD RETURN DEF IF NOT WHILE

// Precedence and associativity

/* %left PLUS MINUS
%left TIMES
%left UMINUS */

/* %type <i> Start Expr */
%type <std::vector<Statement>> Start Statements 
%type <Statement> Statement
%type <ExprStatement> ExprStatement
%type <Expr> Expr IfExpr PrimaryExpr UnaryExpr BinaryExpr LambdaExpr
%type <Expr> Operand List Dict Tuple ListComp DictComp

%start Start

%%

// Grammar rules

Start 
    : Statements {
        // ret = std::move($1);
    }
;

Statements
    : Statement {
        // $$ = { $1 };
    }
    | Statements Statement {
        // $1.push_back($2);
        // $$ = std::move($1);
    }
;

Statement
    : ExprStatement {
        // $$ = Statement($1);
    }
;

ExprStatement
    : Expr NEW_LINE {
        // $$ = ExprStatement($1);
    }
;

Expr
    : PrimaryExpr {
        $$ = std::move($1);
    }
;

PrimaryExpr
    : Operand {
        $$ = std::move($1);
    }

Operand
    : IDENTIFIER {
        // $$ = Expr{.type = Expr::Type::IDENTIFIER, .data=make_unique<std::string*>($1)};
    }
;