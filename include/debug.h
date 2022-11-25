#ifndef _2EE631EC_692E_11ED_9E94_00155DC44258
#define _2EE631EC_692E_11ED_9E94_00155DC44258

#include "types.h"

void print_statement_list(StatementList* s);
void print_statement(Statement* s);
void print_expr(Expr* e);
void print_if_expr(IfExpr* e);
void print_primary_expr(PrimaryExpr* e);
void print_unary_expr(UnaryExpr* e);
void print_binary_expr(BinaryExpr* e);
void print_lambda_expr(LambdaExpr* e);
void print_list_comprehension(ListComprehension* e);
void print_dict_comprehension(DictComprehension* e);
void print_call_expr(CallExpr* e);
void print_index_expr(IndexExpr* e);

#endif