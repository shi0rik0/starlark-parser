#ifndef _F84986B2_6819_11ED_9F39_00155DC446E4
#define _F84986B2_6819_11ED_9F39_00155DC446E4

#ifdef __cplusplus
extern "C" {
#endif

struct Expr;

typedef enum Statement_Type {
    Statement_Type_DEF_STATEMENT,
    Statement_Type_IF_STATEMENT,
    Statement_Type_FOR_STATEMENT,
    Statement_Type_BREAK_STATEMENT,
    Statement_Type_CONTINUE_STATEMENT,
    Statement_Type_PASS_STATEMENT,
    Statement_Type_ASSIGN_STATEMENT,
    Statement_Type_EXPR_STATEMENT,
    Statement_Type_LOAD_STATEMENT,
} Statement_Type;

typedef struct DefStatement {
    // TODO
} DefStatement;

typedef struct IfStatement {
    // TODO
} IfStatement;

typedef struct ForStatement {
    // TODO
} ForStatement;

typedef struct AssignStatement {
    // TODO
} AssignStatement;

typedef struct LoadStatement {
    // TODO
} LoadStatement;

typedef struct Statement {
    Statement_Type type;
    union {
        DefStatement* def_statement;
        IfStatement* if_statement;
        ForStatement* for_statement;
        AssignStatement* assign_statement;
        struct Expr* expr_statement;
        LoadStatement* load_statement;
    } data;
} Statement;

typedef struct StatementList {
    Statement* statement;
    struct StatementList* next;
} StatementList;

/// Expressions

// true_expr if condition else false_expr
typedef struct IfExpr {
    struct Expr* condition;
    struct Expr* true_expr;
    struct Expr* false_expr;
} IfExpr;

typedef enum PrimaryExpr_Type {
    PrimaryExpr_Type_IDENTIFIER,
    PrimaryExpr_Type_INT,
    PrimaryExpr_Type_FLOAT,
    PrimaryExpr_Type_STRING,
    PrimaryExpr_Type_BYTES,
    PrimaryExpr_Type_LIST,
    PrimaryExpr_Type_TUPLE,
    PrimaryExpr_Type_DICT,
} PrimaryExpr_Type;

typedef struct ExprList {
    struct Expr* expr;
    struct ExprList* next;
} ExprList;

typedef struct MappingList {
    struct Expr* key;
    struct Expr* value;
    struct MappingList* next;
} MappingList;

typedef struct PrimaryExpr {
    PrimaryExpr_Type type;
    union {
        char* identifier;
        char* int_;
        double float_;
        char* string;
        char* bytes;
        ExprList* list;
        ExprList* tuple;
        MappingList* dict;
    } data;
} PrimaryExpr;

typedef enum UnaryOperator {
    UnaryOperator_POS, // +3
    UnaryOperator_NEG, // -3
    UnaryOperator_INVERT, // ~3
    UnaryOperator_NOT, // not True
} UnaryOperator;

typedef struct UnaryExpr {
    UnaryOperator op;
    struct Expr* expr;
} UnaryExpr;

typedef enum BinaryOperator {
    BinaryOperator_ADD,
    BinaryOperator_SUB,
    BinaryOperator_MUL,
    BinaryOperator_DIV,
    BinaryOperator_FLOORDIV,
    BinaryOperator_MOD,
    BinaryOperator_POW,
    BinaryOperator_RSHIFT,
    BinaryOperator_LSHIFT,
    BinaryOperator_BITAND,
    BinaryOperator_BITOR,
    BinaryOperator_XOR,
    BinaryOperator_LT,
    BinaryOperator_GT,
    BinaryOperator_LE,
    BinaryOperator_GE,
    BinaryOperator_EQ,
    BinaryOperator_NE,
    BinaryOperator_AND,
    BinaryOperator_OR,
    BinaryOperator_IN,
    BinaryOperator_NOT_IN,
    BinaryOperator_DOT, // obj.attr
} BinaryOperator;

typedef struct BinaryExpr {
    BinaryOperator op;
    struct Expr* left;
    struct Expr* right;
} BinaryExpr;

typedef struct LambdaExpr {
    // TODO
} LambdaExpr;

typedef struct ListComprehension {
    // TODO
} ListComprehension;

typedef struct DictComprehension {
    // TODO
} DictComprehension;

typedef struct CallExpr {
    struct Expr* callee;
    ExprList* arg_list;
} CallExpr;

// _list[first:second:third] or _dict[first]
typedef struct IndexExpr {
    struct Expr* container;
    struct Expr* first;
    struct Expr* second;
    struct Expr* third;
} IndexExpr;

typedef enum Expr_Type {
    Expr_Type_IF_EXPR,
    Expr_Type_PRIMARY_EXPR,
    Expr_Type_UNARY_EXPR,
    Expr_Type_BINARY_EXPR,
    Expr_Type_LAMBDA_EXPR,
    Expr_Type_LIST_COMPREHENSION,
    Expr_Type_DICT_COMPREHENSION,
    Expr_Type_CALL_EXPR,
    Expr_Type_INDEX_EXPR,
} Expr_Type;

typedef struct Expr {
    Expr_Type type;
    union {
        IfExpr if_expr;
        PrimaryExpr primary_expr;
        UnaryExpr unary_expr;
        BinaryExpr binary_expr;
        LambdaExpr lambda_expr;
        ListComprehension list_comprehension;
        DictComprehension dict_comprehension;
        CallExpr call_expr;
        IndexExpr index_expr;
    } data;
} Expr;

#ifdef __cplusplus
}
#endif

#endif