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

struct ReturnStatement {
    Expr return_val;
};

struct BreakStatement {
};

struct ContinueStatement {
};

struct PassStatement {
};

struct AssginStatement {
    // TODO
};

struct LoadStatement {
    // TODO
};

struct AssignStatement {
    Expr leftval, rightval;
};

struct Statement {
    typedef std::variant<
        ExprStatement,
        ReturnStatement,
        BreakStatement,
        ContinueStatement,
        PassStatement,
        AssignStatement,
        LoadStatement>
        Data;
    Data data;
};

std::ostream& operator<<(std::ostream& os, const Statement& s);
std::ostream& operator<<(std::ostream& os, const ExprStatement& s);
std::ostream& operator<<(std::ostream& os, const ReturnStatement& s);
std::ostream& operator<<(std::ostream& os, const BreakStatement& s);
std::ostream& operator<<(std::ostream& os, const ContinueStatement& s);
std::ostream& operator<<(std::ostream& os, const PassStatement& s);
std::ostream& operator<<(std::ostream& os, const AssignStatement& s);

#endif