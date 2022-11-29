%language "c++"
%define api.value.type variant
%parse-param {std::deque<Statement>& ret}

%code requires {
    // This part will be copied to the beginning of parser.h
    #include "types.h"
    #include <deque>
}

%code provides
{
    // This part will be copied to the end of parser.h
    #define YY_DECL int yylex(yy::parser::semantic_type *yylval)
    YY_DECL;
    
    typedef yy::parser::semantic_type YYSTYPE;
}

%code {
    // This part will be copied to parser.cpp
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
// POS and NEG are dummy tokens used to specify precedence. The lexer shouldn't return them.
%token <NoneType> POS NEG INVERT
//                .   ,     ;         :        PS: dot can be regarded as a binary op
%token <NoneType> DOT COMMA SEMICOLON COLON
//                (      )      [        ]        {      }
%token <NoneType> LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE

// Keywords
// "not" is a unary op, and "and", "or", "in" and "not in" are binary ops.
%token <NoneType> AND ELIF IN OR BREAK ELSE LAMBDA PASS CONTINUE FOR LOAD RETURN DEF IF NOT WHILE NOT_IN

// Precedence and associativity
// ref: https://docs.python.org/3/reference/expressions.html#operator-precedence
%left OR
%left AND
%left NOT
%left LT GT LE GE EQ NE IN NOT_IN
%left BITOR
%left XOR
%left BITAND
%left LSHIFT RSHIFT
%left ADD SUB
%left MUL DIV FLOORDIV MOD
%left POS NEG INVERT
%right POW // TODO: POW seems to be more complicated. See https://docs.python.org/3/reference/expressions.html#the-power-operator

%type < std::deque<Statement> > Start Statements CompoundStatement
%type <Statement> Statement SmallStatement
%type <ExprStatement> ExprStatement
%type <Expr> Expr IfExpr PrimaryExpr UnaryExpr BinaryExpr LambdaExpr
%type <Expr> Operand List Dict Tuple ListComp DictComp
%type < std::deque<Expr> > ListItems ListItems_WITHCOMMA// some Exprs concatenated with commas
%type < std::deque< std::pair<Expr, Expr> > > DictItems

%start Start

%%

// Grammar rules

Start 
    : Statements {
        ret = std::move($1);
    }
;

Statements
    : Statement {
        $$.emplace_front(std::move($1));
    }
    | Statement Statements {
        $2.emplace_front(std::move($1));
        $$ = std::move($2);
    }
    | CompoundStatement {
        for (auto it = $1.rbegin(); it != $1.rend(); ++it) {
            $$.emplace_front(std::move(*it));
        }
    }
    | CompoundStatement Statements {
        for (auto it = $1.rbegin(); it != $1.rend(); ++it) {
            $2.emplace_front(std::move(*it));
        }
        $$ = std::move($2);
    }
;

Statement
    : INVERT {
        
    }
;

CompoundStatement
    : SmallStatement NEW_LINE {
        $$.emplace_front(std::move($1));
    }
    | SmallStatement SEMICOLON NEW_LINE {
        $$.emplace_front(std::move($1));
    }
    | SmallStatement SEMICOLON CompoundStatement {
        $3.emplace_front(std::move($1));
        $$ = std::move($3);
    }
;

SmallStatement
    : ExprStatement {
        Statement s;
        s.data = std::move($1);
        $$ = std::move(s);
    }
;

ExprStatement
    : Expr {
        ExprStatement e;
        e.expr = std::move($1);
        $$ = std::move(e);
    }
;

Expr
    : PrimaryExpr {
        $$ = std::move($1);
    }
    | UnaryExpr {
        $$ = std::move($1);
    }
    | BinaryExpr {
        $$ = std::move($1);
    }
    | List {
        $$ = std::move($1);
    }
;

PrimaryExpr
    : Operand {
        $$ = std::move($1);
    }
;

Operand
    : IDENTIFIER {
        Expr e;
        e.type = Expr::Type::IDENTIFIER;
        e.data = $1;
        $$ = std::move(e);
    }
    | INT {
        Expr e;
        e.type = Expr::Type::INT;
        e.data = $1;
        $$ = std::move(e);
    }
    | FLOAT {
        Expr e;
        e.type = Expr::Type::FLOAT;
        e.data = $1;
        $$ = std::move(e);
    }
    | STRING {
        Expr e;
        e.type = Expr::Type::STRING;
        e.data = $1;
        $$ = std::move(e);
    }
    | BYTES {
        Expr e;
        e.type = Expr::Type::BYTES;
        e.data = $1;
        $$ = std::move(e);
    }
;

UnaryExpr
    : ADD Expr %prec POS {
        $$.type = Expr::Type::POS;
        $$.data = make_unique<Expr>(std::move($2));
    }
    | SUB Expr %prec NEG {
        $$.type = Expr::Type::NEG;
        $$.data = make_unique<Expr>(std::move($2));
    }
    | NOT Expr {
        $$.type = Expr::Type::NOT;
        $$.data = make_unique<Expr>(std::move($2));
    }
    | INVERT Expr {
        $$.type = Expr::Type::INVERT;
        $$.data = make_unique<Expr>(std::move($2));
    }
;

BinaryExpr
    : Expr ADD Expr {
        $$.type = Expr::Type::ADD;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr SUB Expr {
        $$.type = Expr::Type::SUB;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr MUL Expr {
        $$.type = Expr::Type::MUL;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr DIV Expr {
        $$.type = Expr::Type::DIV;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr FLOORDIV Expr {
        $$.type = Expr::Type::FLOORDIV;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr MOD Expr {
        $$.type = Expr::Type::MOD;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr POW Expr {
        $$.type = Expr::Type::POW;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr RSHIFT Expr {
        $$.type = Expr::Type::RSHIFT;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr LSHIFT Expr {
        $$.type = Expr::Type::LSHIFT;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr BITAND Expr {
        $$.type = Expr::Type::BITAND;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr BITOR Expr {
        $$.type = Expr::Type::BITOR;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr XOR Expr {
        $$.type = Expr::Type::XOR;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr LT Expr {
        $$.type = Expr::Type::LT;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr GT Expr {
        $$.type = Expr::Type::GT;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr LE Expr {
        $$.type = Expr::Type::LE;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr GE Expr {
        $$.type = Expr::Type::GE;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr EQ Expr {
        $$.type = Expr::Type::EQ;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr NE Expr {
        $$.type = Expr::Type::NE;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr AND Expr {
        $$.type = Expr::Type::AND;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr OR Expr {
        $$.type = Expr::Type::OR;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr IN Expr {
        $$.type = Expr::Type::IN;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
    | Expr NOT_IN Expr {
        $$.type = Expr::Type::NOT_IN;
        $$.data = make_pair(make_unique<Expr>(std::move($1)), make_unique<Expr>(std::move($3)));
    }
;

ListItems:
    Expr {
        $$.emplace_front(std::move($1));
    }
    | Expr COMMA ListItems {
        $3.emplace_front(std::move($1));
        $$ = std::move($3);
    }
    | Expr COMMA NEW_LINE ListItems {
        $4.emplace_front(std::move($1));
        $$ = std::move($4);
    }
;

ListItems_WITHCOMMA:
    ListItems COMMA{
        $$ = std::move($1);
    }
;

List: 
    LBRACKET RBRACKET {
        $$.type = Expr::Type::LIST;
        std::deque<Expr> tmp;
        $$.data = std::move(tmp);
    } 
    | LBRACKET ListItems RBRACKET {
        $$.type = Expr::Type::LIST;
        $$.data = std::move($2);
        
    }
    | LBRACKET ListItems_WITHCOMMA RBRACKET {
        cout << "test list comma" << endl;
        $$.type = Expr::Type::LIST;
        $$.data = std::move($2);
    }
; 

