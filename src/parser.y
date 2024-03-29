%language "c++"
%define api.value.type variant
%parse-param {std::deque<Statement>& ret}

%code requires {
    // This part will be copied to the beginning of parser.h
    #include "statements.h"
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
// dummy tokens for * and ** in parameters or arguments
%token <NoneType> STAR DOUBLE_STAR

// Keywords
// "not" is a unary op, and "and", "or", "in" and "not in" are binary ops.
%token <NoneType> AND ELIF IN OR BREAK ELSE LAMBDA PASS CONTINUE FOR LOAD RETURN DEF IF NOT NOT_IN

// Precedence and associativity
// ref: https://docs.python.org/3/reference/expressions.html#operator-precedence
%left STAR DOUBLE_STAR
%left LAMBDA
%left IF ELSE
%left ASSIGN
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
%right POW

%type <Statements> Start Statements CompoundStatement
%type <Statement> BlockStatement SmallStatement
%type <IfStatement> IfStatement
%type <std::pair<Expr, Statements>> IfPart
%type <std::deque<std::pair<Expr, Statements>>> ElifPart
%type <Statements> ElsePart
%type <Statements> BlockBody
%type <DefStatement> DefStatement
%type <ForStatement> ForStatement
%type <LoadStatement> LoadStatement
%type <AssignStatement> AssignStatement
%type <Expr> Expr IfExpr PrimaryExpr UnaryExpr BinaryExpr LambdaExpr DotExpr SliceExpr CallExpr
%type <Expr> Expr_Loose
%type <Expr> Operand List Dict Tuple Tuple_NoParen
%type <std::deque<Expr>> ListItems
%type <std::deque<Expr>> TupleItems
%type <std::deque<std::pair<Expr, Expr>>> DictItems
%type <Expr> ForLoopVars
%type <Expr> ForLoopVars_Tuple_NoParen
%type <std::deque<Expr>> ForLoopVars_TupleItems
%type <std::deque<Parameter>> Parameters
%type <Parameter> Parameter
%type <std::deque<Argument>> Arguments
%type <Argument> Argument
%type <std::deque<LoadStatement::Symbol>> Symbols
%type <LoadStatement::Symbol> Symbol
%type <std::deque<ComprehensionClause>> CompClauses
%type <ComprehensionClause> CompClause
%type <ForClause> ForClause
%type <IfClause> IfClause

%start Start

%%

// Grammar rules

Start 
    : Statements {
        ret = std::move($1);
    }
;

Statements
    : BlockStatement {
        $$.emplace_front(std::move($1));
    }
    | BlockStatement Statements {
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

BlockStatement
    : IfStatement {
        $$.data = std::move($1);
    }
    | ForStatement {
        $$.data = std::move($1);
    }
    | DefStatement {
        $$.data = std::move($1);
    }
;


IfStatement
    : IfPart {
        $$.if_elif_branches.emplace_front(std::move($1));
    }
    | IfPart ElsePart {
        $$.if_elif_branches.emplace_front(std::move($1));
        $$.else_branch = std::move($2);
    }
    | IfPart ElifPart {
        $2.emplace_front(std::move($1));
        $$.if_elif_branches = std::move($2);
    }
    | IfPart ElifPart ElsePart {
        $2.emplace_front(std::move($1));
        $$.if_elif_branches = std::move($2);
        $$.else_branch = std::move($3);
    }
;

IfPart
    : IF Expr COLON BlockBody {
        $$ = make_pair(std::move($2), std::move($4));
    }
;

ElifPart
    : ELIF Expr COLON BlockBody {
        $$.emplace_front(make_pair(std::move($2), std::move($4)));
    }
    | ELIF Expr COLON BlockBody ElifPart {
        $5.emplace_front(make_pair(std::move($2), std::move($4)));
        $$ = std::move($5);
    }
;

ElsePart
    : ELSE COLON BlockBody {
        $$ = std::move($3);
    }
;

ForStatement
    : FOR ForLoopVars IN Expr_Loose COLON BlockBody {
        $$.for_what = std::move($2);
        $$.in_what = std::move($4);
        $$.body = std::move($6);
    }
;

DefStatement
    : DEF IDENTIFIER LPAREN Parameters RPAREN COLON BlockBody {
        $$.name = std::move($2);
        $$.parameters = std::move($4);
        $$.body = std::move($7);
    }
;

BlockBody
    : CompoundStatement {
        $$ = std::move($1);
    }
    | NEW_LINE INDENT Statements DEDENT {
        $$ = std::move($3);
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
    : Expr_Loose {
        ExprStatement es;
        es.expr = std::move($1);
        Statement s;
        s.data = std::move(es);
        $$ = std::move(s);
    }
    | RETURN Expr_Loose {
        ReturnStatement rs;
        rs.return_val = std::move($2);
        Statement s;
        s.data = std::move(rs);
        $$ = std::move(s);
    }
    | AssignStatement {
        $$.data = std::move($1);
    }
    | BREAK {
        $$.data = BreakStatement();
    }
    | CONTINUE {
        $$.data = ContinueStatement();
    }
    | PASS {
        $$.data = PassStatement();
    }
    | LoadStatement {
        $$.data = std::move($1);
    }
;

AssignStatement
    : Expr_Loose ASSIGN Expr_Loose {
        $$.type = AssignStatement::Type::ASSIGN;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose IADD Expr_Loose {
        $$.type = AssignStatement::Type::ADD;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose ISUB Expr_Loose {
        $$.type = AssignStatement::Type::SUB;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose IMUL Expr_Loose {
        $$.type = AssignStatement::Type::MUL;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose IDIV Expr_Loose {
        $$.type = AssignStatement::Type::DIV;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose IFLOORDIV Expr_Loose {
        $$.type = AssignStatement::Type::FLOORDIV;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose IMOD Expr_Loose {
        $$.type = AssignStatement::Type::MOD;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose IPOW Expr_Loose {
        $$.type = AssignStatement::Type::POW;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose IRSHIFT Expr_Loose {
        $$.type = AssignStatement::Type::RSHIFT;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose ILSHIFT Expr_Loose {
        $$.type = AssignStatement::Type::LSHIFT;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose IBITAND Expr_Loose {
        $$.type = AssignStatement::Type::BITAND;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose IBITOR Expr_Loose {
        $$.type = AssignStatement::Type::BITOR;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
    | Expr_Loose IXOR Expr_Loose {
        $$.type = AssignStatement::Type::XOR;
        $$.left_val = std::move($1);
        $$.right_val = std::move($3);
    }
;

LoadStatement
    : LOAD LPAREN STRING RPAREN {
        $$.file = std::move($3);
    }
    | LOAD LPAREN STRING COMMA RPAREN {
        $$.file = std::move($3);
    }
    | LOAD LPAREN STRING COMMA Symbols RPAREN {
        $$.file = std::move($3);
        $$.symbols = std::move($5);
    }
;

Symbols
    : Symbol {
        $$.emplace_front(std::move($1));
    }
    | Symbol COMMA {
        $$.emplace_front(std::move($1));
    }
    | Symbol COMMA Symbols {
        $3.emplace_front(std::move($1));
        $$ = std::move($3);
    }
;

Symbol
    : STRING {
        $$.name = std::move($1);
    }
    | IDENTIFIER ASSIGN STRING {
        $$.name = std::move($3);
        $$.alias = std::move($1);
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
    | IfExpr {
        $$ = std::move($1);
    }
    | LambdaExpr {
        $$ = std::move($1);
    }
;

Expr_Loose
    : Expr {
        $$ = std::move($1);
    }
    | Tuple_NoParen {
        $$ = std::move($1);
    }
;

PrimaryExpr
    : Operand {
        $$ = std::move($1);
    }
    | DotExpr {
        $$ = std::move($1);
    } 
    | SliceExpr {
        $$ = std::move($1);
    }
    | CallExpr {
        $$ = std::move($1);
    }
    | LPAREN Expr RPAREN {
        $$ = (std::move($2));
    } 
;

DotExpr
    : PrimaryExpr DOT IDENTIFIER {
        Expr e;
        e.type = Expr::Type::DOT;
        DotExpr de;
        de.obj = make_unique<Expr>(std::move($1));
        de.attr = std::move($3);
        e.data = std::move(de);
        $$ = std::move(e);
    }
;

SliceExpr 
    : PrimaryExpr LBRACKET Expr_Loose RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_unique<Expr>(std::move($3));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET Expr_Loose COLON Expr RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_pair(make_unique<Expr>(std::move($3)), make_unique<Expr>(std::move($5)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET COLON RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        Expr none0, none1;
        none0.type = none1.type = Expr::Type::NONE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_pair(make_unique<Expr>(std::move(none0)), make_unique<Expr>(std::move(none1)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET Expr_Loose COLON RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        Expr none0, none1;
        none0.type = none1.type = Expr::Type::NONE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_pair(make_unique<Expr>(std::move($3)), make_unique<Expr>(std::move(none1)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET COLON Expr RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        Expr none0, none1;
        none0.type = none1.type = Expr::Type::NONE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_pair(make_unique<Expr>(std::move(none0)), make_unique<Expr>(std::move($4)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET Expr_Loose COLON Expr COLON Expr RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_tuple(make_unique<Expr>(std::move($3)), make_unique<Expr>(std::move($5)), make_unique<Expr>(std::move($7)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET COLON COLON RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        Expr none0, none1, none2;
        none0.type = none1.type = none2.type = Expr::Type::NONE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_tuple(make_unique<Expr>(std::move(none0)), make_unique<Expr>(std::move(none1)), make_unique<Expr>(std::move(none2)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET Expr_Loose COLON COLON RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        Expr none0, none1, none2;
        none0.type = none1.type = none2.type = Expr::Type::NONE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_tuple(make_unique<Expr>(std::move($3)), make_unique<Expr>(std::move(none1)), make_unique<Expr>(std::move(none2)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET COLON Expr COLON RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        Expr none0, none1, none2;
        none0.type = none1.type = none2.type = Expr::Type::NONE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_tuple(make_unique<Expr>(std::move(none0)), make_unique<Expr>(std::move($4)), make_unique<Expr>(std::move(none2)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET Expr_Loose COLON Expr COLON RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        Expr none0, none1, none2;
        none0.type = none1.type = none2.type = Expr::Type::NONE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_tuple(make_unique<Expr>(std::move($3)), make_unique<Expr>(std::move($5)), make_unique<Expr>(std::move(none2)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET COLON COLON Expr RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        Expr none0, none1, none2;
        none0.type = none1.type = none2.type = Expr::Type::NONE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_tuple(make_unique<Expr>(std::move(none0)), make_unique<Expr>(std::move(none1)), make_unique<Expr>(std::move($5)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET Expr_Loose COLON COLON Expr RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        Expr none0, none1, none2;
        none0.type = none1.type = none2.type = Expr::Type::NONE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_tuple(make_unique<Expr>(std::move($3)), make_unique<Expr>(std::move(none1)), make_unique<Expr>(std::move($6)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
    | PrimaryExpr LBRACKET COLON Expr COLON Expr RBRACKET { 
        Expr e;
        e.type = Expr::Type::SLICE;
        Expr none0, none1, none2;
        none0.type = none1.type = none2.type = Expr::Type::NONE;
        SliceExpr se;
        se.sequence = make_unique<Expr>(std::move($1));
        se.slice = make_tuple(make_unique<Expr>(std::move(none0)), make_unique<Expr>(std::move($4)), make_unique<Expr>(std::move($6)));
        e.data = std::move(se);
        $$ = std::move(e);
    }
;

CallExpr 
    : PrimaryExpr LPAREN RPAREN{
        Expr e;
        e.type = Expr::Type::CALL;
        CallExpr ce;
        ce.callee = make_unique<Expr>(std::move($1));
        ce.arguments = std::deque<Argument>();
        e.data = std::move(ce);
        $$ = std::move(e);
    }
    | PrimaryExpr LPAREN Arguments RPAREN{
        Expr e;
        e.type = Expr::Type::CALL;
        CallExpr ce;
        ce.callee = make_unique<Expr>(std::move($1));
        ce.arguments = std::move($3);
        e.data = std::move(ce);
        $$ = std::move(e);
    }
;

LambdaExpr
    : LAMBDA Parameters COLON Expr %prec LAMBDA {
        LambdaExpr e;
        e.parameters = std::move($2);
        e.return_val = make_unique<Expr>(std::move($4));
        $$.type = Expr::Type::LAMBDA;
        $$.data = std::move(e);
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
    | List {
        $$ = std::move($1);
    }
    | Tuple {
        $$ = std::move($1);
    }
    | Dict {
        $$ = std::move($1);
    }
    | LBRACKET Expr ForClause CompClauses RBRACKET {
        ListComprehension c;
        c.item = make_unique<Expr>(std::move($2));
        $4.emplace_front(std::move($3));
        c.clauses = std::move($4);
        $$.type = Expr::Type::LIST_COMPREHENSION;
        $$.data = std::move(c);
    }
    | LBRACE Expr COLON Expr ForClause CompClauses RBRACE {
        DictComprehension c;
        c.item = make_pair(make_unique<Expr>(std::move($2)), make_unique<Expr>(std::move($4)));
        $6.emplace_front(std::move($5));
        c.clauses = std::move($6);
        $$.type = Expr::Type::DICT_COMPREHENSION;
        $$.data = std::move(c);
    }
;

CompClauses
    : %empty {

    }
    | CompClause CompClauses {
        $2.emplace_front(std::move($1));
        $$ = std::move($2);
    }
;

CompClause
    : IfClause {
        $$ = std::move($1);
    }
    | ForClause {
        $$ = std::move($1);
    }
;

IfClause
    : IF Expr {
        $$.condition = make_unique<Expr>(std::move($2));
    }
;

ForClause
    : FOR ForLoopVars IN Expr {
        $$.for_what = make_unique<Expr>(std::move($2));
        $$.in_what = make_unique<Expr>(std::move($4));
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

IfExpr 
    : Expr IF Expr ELSE Expr {
        IfExpr expr;
        expr.condition = make_unique<Expr>(std::move($3));
        expr.true_val = make_unique<Expr>(std::move($1));
        expr.false_val = make_unique<Expr>(std::move($5));
        $$.type = Expr::Type::IF;
        $$.data = std::move(expr);
    }
;

ListItems
    : Expr {
        $$.emplace_front(std::move($1));
    }
    | Expr COMMA {
        $$.emplace_front(std::move($1));
    }
    | Expr COMMA ListItems {
        $3.emplace_front(std::move($1));
        $$ = std::move($3);
    }
;


List
    : LBRACKET RBRACKET {
        $$.type = Expr::Type::LIST;
        $$.data = std::deque<Expr>();
    } 
    | LBRACKET ListItems RBRACKET {
        $$.type = Expr::Type::LIST;
        $$.data = std::move($2);
    }
; 

TupleItems 
    : Expr COMMA {
        $$.emplace_front(std::move($1));
    }
    | Expr COMMA Expr {
        $$.emplace_front(std::move($3));
        $$.emplace_front(std::move($1));
    }
    | Expr COMMA TupleItems {
        $3.emplace_front(std::move($1));
        $$ = std::move($3);
    }
;


Tuple
    : LPAREN RPAREN {
        $$.type = Expr::Type::TUPLE;
        $$.data = std::deque<Expr>();
    } 
    | LPAREN TupleItems RPAREN{
        $$.type = Expr::Type::TUPLE;
        $$.data = std::move($2);
    }
;

Tuple_NoParen
    : TupleItems {
        $$.type = Expr::Type::TUPLE;
        $$.data = std::move($1);
    }
;

DictItems
    : Expr COLON Expr {
        $$.emplace_front(make_pair(std::move($1), std::move($3)));
    }
    | Expr COLON Expr COMMA {
        $$.emplace_front(make_pair(std::move($1), std::move($3)));
    }
    | Expr COLON Expr COMMA DictItems {
        $5.emplace_front(make_pair(std::move($1), std::move($3)));
        $$ = std::move($5);
    }
;

Dict
    : LBRACE RBRACE {
        $$.type = Expr::Type::DICT;
        $$.data = deque<pair<Expr,Expr>>();
    } 
    | LBRACE DictItems RBRACE {
        $$.type = Expr::Type::DICT;
        $$.data = std::move($2);
    }
;

ForLoopVars
    : PrimaryExpr {
        $$ = std::move($1);
    }
    | ForLoopVars_Tuple_NoParen {
        $$ = std::move($1);
    }
;

ForLoopVars_TupleItems 
    : PrimaryExpr COMMA {
        $$.emplace_front(std::move($1));
    }
    | PrimaryExpr COMMA PrimaryExpr {
        $$.emplace_front(std::move($3));
        $$.emplace_front(std::move($1));
    }
    | PrimaryExpr COMMA ForLoopVars_TupleItems {
        $3.emplace_front(std::move($1));
        $$ = std::move($3);
    }
;


ForLoopVars_Tuple_NoParen
    : ForLoopVars_TupleItems {
        $$.type = Expr::Type::TUPLE;
        $$.data = std::move($1);
    }
;

Parameters
    : %empty {
        
    }
    | Parameter {
        $$.emplace_front(std::move($1));
    }
    | Parameter COMMA Parameters {
        $3.emplace_front(std::move($1));
        $$ = std::move($3);
    }
;

Parameter
    : IDENTIFIER {
        $$.type = Parameter::NORMAL();
        $$.name = std::move($1);
    }
    | MUL IDENTIFIER %prec STAR {
        $$.type = Parameter::ARGS();
        $$.name = std::move($2);
    }
    | POW IDENTIFIER %prec DOUBLE_STAR {
        $$.type = Parameter::KWARGS();
        $$.name = std::move($2);
    }
    | IDENTIFIER ASSIGN Expr {
        $$.type = std::move($3);
        $$.name = std::move($1);
    }
;

Arguments
    : Argument {
        $$.emplace_front(std::move($1));
    }
    | Argument COMMA {
        $$.emplace_front(std::move($1));
    }
    | Argument COMMA Arguments {
        $3.emplace_front(std::move($1));
        $$ = std::move($3);
    }
;

Argument
    : Expr {
        $$.type = Argument::NORMAL();
        $$.value = make_unique<Expr>(std::move($1));
    }
    | MUL Expr %prec STAR {
        $$.type = Argument::UNPACK_SEQUENCE();
        $$.value = make_unique<Expr>(std::move($2));
    }
    | POW Expr %prec DOUBLE_STAR {
        $$.type = Argument::UNPACK_DICT();
        $$.value = make_unique<Expr>(std::move($2));
    }
    | IDENTIFIER ASSIGN Expr {
        $$.type = $1;
        $$.value = make_unique<Expr>(std::move($3));
    }
;