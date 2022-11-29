#ifndef EXPR_H
#define EXPR_H

#include <deque>
#include <memory>
#include <optional>
#include <ostream>
#include <tuple>
#include <utility>
#include <variant>
#include <vector>
#include <deque>

struct Expr;

typedef std::unique_ptr<Expr> PExpr;

typedef std::string Identifier;

struct CallExpr {
    enum class PositionalArgumentType {
        NORMAL, // f(x)
        AS_SEQUENCE, // f(*x)
        AS_DICT, // f(**x)
    };
    PExpr callee;
    typedef std::variant<std::pair<PositionalArgumentType, PExpr>,
        std::pair<Identifier, PExpr>>
        Argument;
    std::vector<Argument> arguments;
};

struct SliceExpr {
    PExpr sequence;
    typedef std::variant<PExpr,
        std::pair<std::optional<PExpr>, std::optional<PExpr>>,
        std::tuple<std::optional<PExpr>, std::optional<PExpr>, std::optional<PExpr>>>
        Slice;
    Slice slice;
};

struct LambdaExpr {
    std::vector<Identifier> arguments;
    PExpr return_val;
};

struct DotExpr {
    PExpr obj;
    Identifier attr;
};

struct ListComprehension {
    // TODO
};

struct DictComprehension {
    // TODO
};

struct Expr {
    typedef std::deque<std::pair<Expr, Expr>> Dict;
    typedef std::variant<
        std::string,
        double,
        PExpr,
        std::pair<PExpr, PExpr>,
        std::tuple<PExpr, PExpr, PExpr>,
        std::deque<Expr>,
        Dict,
        CallExpr,
        SliceExpr,
        LambdaExpr,
        DotExpr,
        ListComprehension,
        DictComprehension>
        Data;
    enum class Type {
        // atomic
        IDENTIFIER,
        INT,
        FLOAT,
        STRING,
        BYTES,

        // containers
        LIST,
        TUPLE,
        DICT,

        // unary op
        POS,
        NEG,
        INVERT,
        NOT,

        // binary op
        ADD,
        SUB,
        MUL,
        DIV,
        FLOORDIV,
        MOD,
        POW,
        RSHIFT,
        LSHIFT,
        BITAND,
        BITOR,
        XOR,
        LT,
        GT,
        LE,
        GE,
        EQ,
        NE,
        AND,
        OR,
        IN,
        NOT_IN,

        IF,

        CALL,

        DOT,

        SLICE,

        LIST_COMPREHENSION,

        DICT_COMPREHENSION,

        LAMBDA,
    };

    Type type;
    Data data;
};

std::ostream& operator<<(std::ostream& os, Expr::Type t);
std::ostream& operator<<(std::ostream& os, const Expr& e);
std::ostream& operator<<(std::ostream& os, const CallExpr& e);
std::ostream& operator<<(std::ostream& os, const SliceExpr& e);
std::ostream& operator<<(std::ostream& os, const LambdaExpr& e);
std::ostream& operator<<(std::ostream& os, const DotExpr& e);
std::ostream& operator<<(std::ostream& os, const ListComprehension& e);
std::ostream& operator<<(std::ostream& os, const DictComprehension& e);

void print_dict(std::ostream& os, const Expr::Dict& d);

#endif