#include "statements.h"
#include "utils.h"

using namespace std;

std::ostream& operator<<(std::ostream& os, const Statement& s)
{
    if (auto p = get_if<ExprStatement>(&s.data)) {
        os << "ExprStatement(" << *p << ")";
    } else if (auto p = get_if<ReturnStatement>(&s.data)) {
        os << "ReturnStatement(" << *p << ")";
    } else if (auto p = get_if<BreakStatement>(&s.data)) {
        os << "BreakStatement(" << *p << ")";
    } else if (auto p = get_if<ContinueStatement>(&s.data)) {
        os << "ContinueStatement(" << *p << ")";
    } else if (auto p = get_if<PassStatement>(&s.data)) {
        os << "PassStatement(" << *p << ")";
    } else if (auto p = get_if<IfStatement>(&s.data)) {
        os << "IfStatement(" << *p << ")";
    } else if (auto p = get_if<AssignStatement>(&s.data)) {
        os << "AssignStatement(" << *p << ")";
    } else if (auto p = get_if<ForStatement>(&s.data)) {
        os << "ForStatement(" << *p << ")";
    } else if (auto p = get_if<DefStatement>(&s.data)) {
        os << "DefStatement(" << *p << ")";
    } else if (auto p = get_if<LoadStatement>(&s.data)) {
        os << "LoadStatement(" << *p << ")";
    } else {
        FATAL_ERROR("TODO");
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
    os << "TODO";
    return os;
}

std::ostream& operator<<(std::ostream& os, const ForStatement& s)
{
    os << "TODO";
    return os;
}

std::ostream& operator<<(std::ostream& os, const DefStatement& s)
{
    os << "TODO";
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
