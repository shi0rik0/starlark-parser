#include "debug.h"
#include "types.h"
#include <stdio.h>
void print_statement_list(StatementList* s)
{
    while (s) {
        print_statement(s->statement);
        s = s->next;
    }
}
void print_statement(Statement* s)
{
    switch (s->type) {
    case Statement_Type_EXPR_STATEMENT:
        print_expr(s->data.expr_statement);
        break;
    }
}
void print_expr(Expr* e)
{
    switch (e->type) {
    case Expr_Type_BINARY_EXPR:
        print_binary_expr(e->data.binary_expr);
        break;
    case Expr_Type_CALL_EXPR:
        print_call_expr(e->data.call_expr);
        break;
    case Expr_Type_IF_EXPR:
        print_if_expr(e->data.if_expr);
        break;
    case Expr_Type_INDEX_EXPR:
        print_index_expr(e->data.index_expr);
        break;
    case Expr_Type_PRIMARY_EXPR:
        print_binary_expr(e->data.binary_expr);
        break;
    case Expr_Type_UNARY_EXPR:
        print_binary_expr(e->data.binary_expr);
        break;
    }
}
void print_if_expr(IfExpr* e)
{
    printf("if (");
    print_expr(e->condition);
    printf(") then (");
    print_expr(e->true_expr);
    printf(") else (");
    print_expr(e->false_expr);
    printf(")");
}

static const char SEP1[] = "";
static const char SEP2[] = ", ";
void print_primary_expr(PrimaryExpr* e)
{
    switch (e->type) {
    case PrimaryExpr_Type_BYTES:
        printf("%s", e->data.bytes);
        break;
    case PrimaryExpr_Type_DICT: {
        const char* sep = SEP1;
        printf("{");
        MappingList* p = e->data.dict;
        while (p) {
            printf("%s", sep);
            print_expr(p->key);
            printf(": ");
            print_expr(p->value);
            sep = SEP2;
            p = p->next;
        }
        printf("}");
    } break;
    case PrimaryExpr_Type_FLOAT:
        printf("%f", e->data.float_);
        break;
    case PrimaryExpr_Type_IDENTIFIER:
        printf("%s", e->data.identifier);
        break;
    case PrimaryExpr_Type_INT:
        printf("%s", e->data.int_);
        break;
    case PrimaryExpr_Type_LIST: {
        const char* sep = SEP1;
        printf("[");
        ExprList* p = e->data.list;
        while (p) {
            printf("%s", sep);
            print_expr(p->expr);
            sep = SEP2;
            p = p->next;
        }
        printf("]");
    } break;
    case PrimaryExpr_Type_STRING:
        printf("%s", e->data.string);
        break;
    case PrimaryExpr_Type_TUPLE: {
        const char* sep = SEP1;
        printf("tuple(");
        ExprList* p = e->data.tuple;
        while (p) {
            printf("%s", sep);
            print_expr(p->expr);
            sep = SEP2;
            p = p->next;
        }
        printf(")");
    } break;
    }
}
void print_unary_expr(UnaryExpr* e)
{
    switch (e->op) {
    case UnaryOperator_POS:
        printf("+");
        break;
    case UnaryOperator_NEG:
        printf("-");
        break;
    case UnaryOperator_INVERT:
        printf("~");
        break;
    case UnaryOperator_NOT:
        printf("not ");
        break;
    }
    printf("(");
    print_expr(e->expr);
    printf(")");
}
void print_binary_expr(BinaryExpr* e)
{
    printf("(");
    print_expr(e->left);
    printf(")");
    switch (e->op) {
    case BinaryOperator_ADD:
        printf(" + ");
        break;
    case BinaryOperator_SUB:
        printf(" - ");
        break;
    case BinaryOperator_MUL:
        printf(" * ");
        break;
    case BinaryOperator_DIV:
        printf(" / ");
        break;
    case BinaryOperator_FLOORDIV:
        printf(" // ");
        break;
    case BinaryOperator_MOD:
        printf(" %% ");
        break;
    case BinaryOperator_POW:
        printf(" ** ");
        break;
    case BinaryOperator_RSHIFT:
        printf(" >> ");
        break;
    case BinaryOperator_LSHIFT:
        printf(" << ");
        break;
    case BinaryOperator_BITAND:
        printf(" & ");
        break;
    case BinaryOperator_BITOR:
        printf(" | ");
        break;
    case BinaryOperator_XOR:
        printf(" ^ ");
        break;
    case BinaryOperator_LT:
        printf(" < ");
        break;
    case BinaryOperator_GT:
        printf(" > ");
        break;
    case BinaryOperator_LE:
        printf(" <= ");
        break;
    case BinaryOperator_GE:
        printf(" >= ");
        break;
    case BinaryOperator_EQ:
        printf(" == ");
        break;
    case BinaryOperator_NE:
        printf(" != ");
        break;
    case BinaryOperator_AND:
        printf(" and ");
        break;
    case BinaryOperator_OR:
        printf(" or ");
        break;
    case BinaryOperator_IN:
        printf(" in ");
        break;
    case BinaryOperator_NOT_IN:
        printf(" not in ");
        break;
    case BinaryOperator_DOT:
        printf(".");
        break;
    }
    printf("(");
    print_expr(e->right);
    printf(")");
}
void print_lambda_expr(LambdaExpr* e)
{
    // TODO
}
void print_list_comprehension(ListComprehension* e)
{
    // TODO
}
void print_dict_comprehension(DictComprehension* e)
{
    // TODO
}
void print_call_expr(CallExpr* e)
{
    printf("(");
    print_expr(e->callee);
    printf(").CALL(");
    const char* sep = SEP1;
    ExprList* p = e->arg_list;
    while (p) {
        printf("%s", sep);
        print_expr(p->expr);
        sep = SEP2;
        p = p->next;
    }
    printf(")");
}
void print_index_expr(IndexExpr* e)
{
    printf("(");
    print_expr(e->container);
    printf(")");
    printf("[");
    print_expr(e->first);
    if (e->second) {
        printf(":");
        print_expr(e->second);
        if (e->third) {
            printf(":");
            print_expr(e->third);
        }
    }
    printf("]");
}