#include "types.h"
#include <stdlib.h>

StatementList* new_statement_list(Statement* statement, StatementList* next)
{
    StatementList* p = (StatementList*)malloc(sizeof(StatementList));
    p->statement = statement;
    p->next = next;
    return p;
}

Statement* new_statement(Statement_Type type, void* data)
{
    Statement* p = (Statement*)malloc(sizeof(Statement));
    p->type = type;
    switch (type) {
    case Statement_Type_EXPR_STATEMENT:
        p->data.expr_statement = (Expr*)data;
        break;
    }
    return p;
}

Expr* new_expr(Expr_Type type, void* data)
{
    Expr* p = (Expr*)malloc(sizeof(Expr));
    p->type = type;
    switch (type) {
    case Expr_Type_PRIMARY_EXPR:
        p->data.primary_expr = (PrimaryExpr*)data;
        break;
    }
    return p;
}

PrimaryExpr* new_primary_expr(PrimaryExpr_Type type, void* data)
{
    PrimaryExpr* p = (PrimaryExpr*)malloc(sizeof(PrimaryExpr));
    p->type = type;
    switch (type) {
    case PrimaryExpr_Type_INT:
        p->data.int_ = (char*)data;
        break;
    }
    return p;
}
