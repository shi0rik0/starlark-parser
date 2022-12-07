#include "statements.h"
#include "utils.h"
#include <deque>
#include <variant>

using namespace std;

std::ostream& operator<<(std::ostream& os, const Statement& s)
{
    if (auto p = get_if<ExprStatement>(&s.data)) {
        os << "Expr[" << *p << "]";
    } else if (auto p = get_if<ReturnStatement>(&s.data)) {
        os << "Return[" << *p << "]";
    } else if (auto p = get_if<BreakStatement>(&s.data)) {
        os << "Break[" << *p << "]";
    } else if (auto p = get_if<ContinueStatement>(&s.data)) {
        os << "Continue[" << *p << "]";
    } else if (auto p = get_if<PassStatement>(&s.data)) {
        os << "Pass[" << *p << "]";
    } else if (auto p = get_if<IfStatement>(&s.data)) {
        os << "If[" << *p << "]";
    } else if (auto p = get_if<AssignStatement>(&s.data)) {
        os << "Assign[" << *p << "]";
    } else if (auto p = get_if<ForStatement>(&s.data)) {
        os << "For[" << *p << "]";
    } else if (auto p = get_if<DefStatement>(&s.data)) {
        os << "Def[" << *p << "]";
    } else if (auto p = get_if<LoadStatement>(&s.data)) {
        os << "Load[" << *p << "]";
    }
    return os;
}

std::ostream& operator<<(std::ostream& os, const ExprStatement& s)
{
    os << s.expr;
    return os;
}

std::ostream& operator<<(std::ostream& os, const ReturnStatement& s)
{
    os << s.return_val;
    return os;
}

std::ostream& operator<<(std::ostream& os, const AssignStatement& s)
{
    os << s.left_val;
    switch (s.type) {
    case AssignStatement::Type::ASSIGN:
        os << "=";
        break;
    case AssignStatement::Type::ADD:
        os << "+=";
        break;
    case AssignStatement::Type::SUB:
        os << "-=";
        break;
    case AssignStatement::Type::MUL:
        os << "*=";
        break;
    case AssignStatement::Type::DIV:
        os << "/=";
        break;
    case AssignStatement::Type::FLOORDIV:
        os << "//=";
        break;
    case AssignStatement::Type::MOD:
        os << "%=";
        break;
    case AssignStatement::Type::POW:
        os << "**=";
        break;
    case AssignStatement::Type::RSHIFT:
        os << ">>=";
        break;
    case AssignStatement::Type::LSHIFT:
        os << "<<=";
        break;
    case AssignStatement::Type::BITAND:
        os << "&=";
        break;
    case AssignStatement::Type::BITOR:
        os << "|=";
        break;
    case AssignStatement::Type::XOR:
        os << "^=";
        break;
    }
    os << s.right_val;
    return os;
}

std::ostream& operator<<(std::ostream& os, const BreakStatement& s)
{
    return os;
}

std::ostream& operator<<(std::ostream& os, const ContinueStatement& s)
{
    return os;
}

std::ostream& operator<<(std::ostream& os, const PassStatement& s)
{
    return os;
}

std::ostream& operator<<(std::ostream& os, const IfStatement& s)
{
    for (const auto& i : s.if_elif_branches) {
        os << i.first << "->{";
        for (const auto& j : i.second) {
            os << j << ";";
        }
        os << "}";
    }
    if (s.else_branch.has_value()) {
        auto& value = s.else_branch.value();
        os << "Otherwise->{";
        for (const auto& j : value) {
            os << j << ";";
        }
        os << "}";
    }
    return os;
}

std::ostream& operator<<(std::ostream& os, const ForStatement& s)
{
    os << s.for_what << "=" << s.in_what << "{";
    for (const auto& i : s.body) {
        os << i << ";";
    }
    os << "}";
    return os;
}

std::ostream& operator<<(std::ostream& os, const DefStatement& s)
{
    os << s.name << "(";
    print_sequence(s.parameters, os, ",");
    os << ")->{";
    for (const auto& i : s.body) {
        os << i << ";";
    }
    os << "}";
    return os;
}

std::ostream& operator<<(std::ostream& os, const LoadStatement& s)
{
    os << s.file;
    for (const LoadStatement::Symbol& i : s.symbols) {
        os << ",";
        if (i.alias.has_value()) {
            os << i.alias.value() << "=";
        }
        os << i.name;
    }
    return os;
}

std::ostream& operator<<(std::ostream& os, const Parameter& p)
{
    if (holds_alternative<Parameter::NORMAL>(p.type)) {
        os << p.name;
    } else if (holds_alternative<Parameter::ARGS>(p.type)) {
        os << "*" << p.name;
    } else if (holds_alternative<Parameter::KWARGS>(p.type)) {
        os << "**" << p.name;
    } else if (auto e = get_if<Expr>(&p.type)) {
        os << p.name << "=" << *e;
    }
    return os;
}
