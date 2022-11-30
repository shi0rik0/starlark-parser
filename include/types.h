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

struct Statement;

typedef std::deque<Statement> Statements;

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

struct IfStatement {
    std::deque<std::pair<Expr, Statements>> if_elif_branches;
    std::optional<Statements> else_branch;
};

struct ForStatement {
    std::deque<Expr> for_what;
    Expr in_what;
    Statements body;
};

struct DefStatement {
    std::deque<Argument> parameters;
    Statements body;
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
        LoadStatement,
        IfStatement,
        ForStatement,
        DefStatement>
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