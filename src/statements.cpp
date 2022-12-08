#include "statements.h"
#include "utils.h"
#include <deque>
#include <ostream>
#include <variant>

using namespace std;

namespace {
int indent_level = 0;
}

void print_indent(std::ostream& os)
{
    for (int i = 0; i < indent_level * 4; ++i) {
        os << ' ';
    }
}

std::ostream& operator<<(std::ostream& os, const Statement& s)
{
    print_indent(os);
    if (auto p = get_if<ExprStatement>(&s.data)) {
        os << "[Expr] " << *p << endl;
    } else if (auto p = get_if<ReturnStatement>(&s.data)) {
        os << "[Return] " << *p << endl;
    } else if (auto p = get_if<BreakStatement>(&s.data)) {
        os << "[Break] " << endl;
    } else if (auto p = get_if<ContinueStatement>(&s.data)) {
        os << "[Continue] " << endl;
    } else if (auto p = get_if<PassStatement>(&s.data)) {
        os << "[Pass] " << endl;
    } else if (auto p = get_if<IfStatement>(&s.data)) {
        os << "[If] " << *p;
    } else if (auto p = get_if<AssignStatement>(&s.data)) {
        os << "[Assign] " << *p << endl;
    } else if (auto p = get_if<ForStatement>(&s.data)) {
        os << "[For] " << *p;
    } else if (auto p = get_if<DefStatement>(&s.data)) {
        os << "[Def] " << *p;
    } else if (auto p = get_if<LoadStatement>(&s.data)) {
        os << "[Load] " << *p << endl;
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

std::ostream& operator<<(std::ostream& os, const IfStatement& s)
{
    os << endl;
    for (const auto& i : s.if_elif_branches) {
        print_indent(os);
        os << i.first << "->{\n";
        ++indent_level;
        for (const auto& j : i.second) {
            os << j;
        }
        --indent_level;
        print_indent(os);
        os << "}\n";
    }
    if (s.else_branch.has_value()) {
        auto& value = s.else_branch.value();
        print_indent(os);
        os << "Otherwise->{\n";
        ++indent_level;
        for (const auto& j : value) {
            os << j;
        }
        --indent_level;
        print_indent(os);
        os << "}\n";
    }
    return os;
}

std::ostream& operator<<(std::ostream& os, const ForStatement& s)
{
    os << s.for_what << "=" << s.in_what << "{\n";
    ++indent_level;
    for (const auto& i : s.body) {
        os << i;
    }
    --indent_level;
    print_indent(os);
    os << "}\n";
    return os;
}

std::ostream& operator<<(std::ostream& os, const DefStatement& s)
{
    os << s.name << "(";
    print_sequence(s.parameters, os, ",");
    os << ")->{\n";
    ++indent_level;
    for (const auto& i : s.body) {
        os << i;
    }
    --indent_level;
    print_indent(os);
    os << "}\n";
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
