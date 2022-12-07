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

struct LoadStatement {
    std::string file;
    struct Symbol {
        Identifier name;
        std::optional<Identifier> alias;
    };
    std::deque<Symbol> symbols;
};

struct AssignStatement {
    Expr leftval;
    Expr rightval;
};

struct IfStatement {
    std::deque<std::pair<Expr, Statements>> if_elif_branches;
    std::optional<Statements> else_branch;
};

struct ForStatement {
    Expr for_what;
    Expr in_what;
    Statements body;
};

struct Parameter {
    struct NORMAL { };
    struct ARGS { };
    struct KWARGS { };
    typedef std::variant<NORMAL, ARGS, KWARGS, Expr> Type;
    // x     -> type == NORMAL()
    // *x    -> type == ARGS()
    // **x   -> type == KWARGS()
    // x = 1 -> type == Expr(1)
    Type type;
    Identifier name;
};

struct DefStatement {
    std::deque<Parameter> parameters;
    Statements body;
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
std::ostream& operator<<(std::ostream& os, const IfStatement& s);
std::ostream& operator<<(std::ostream& os, const AssignStatement& s);
std::ostream& operator<<(std::ostream& os, const ForStatement& s);
std::ostream& operator<<(std::ostream& os, const DefStatement& s);
std::ostream& operator<<(std::ostream& os, const LoadStatement& s);

#endif