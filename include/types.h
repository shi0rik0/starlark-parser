#ifndef TYPES_H
#define TYPES_H

#include "expr.h"
#include <iostream>
#include <optional>
#include <ostream>
#include <string>
#include <tuple>
#include <utility>
#include <variant>
#include <vector>

struct NoneType {
};

struct ExprStatement {
    Expr expr;
};

struct Statement {
    typedef std::variant<ExprStatement> Data;
    Data data;
};

std::ostream& operator<<(std::ostream& os, const Statement& s);
std::ostream& operator<<(std::ostream& os, const ExprStatement& s);

#endif