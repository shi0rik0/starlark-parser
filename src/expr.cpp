#include "expr.h"
#include "utils.h"
#include <memory>

using namespace std;

std::ostream& operator<<(std::ostream& os, Expr::Type t)
{
    switch (t) {
    case Expr::Type::IDENTIFIER:
        os << "IDENTIFIER";
        break;
    case Expr::Type::INT:
        os << "INT";
        break;
    case Expr::Type::FLOAT:
        os << "FLOAT";
        break;
    case Expr::Type::STRING:
        os << "STRING";
        break;
    case Expr::Type::BYTES:
        os << "BYTES";
        break;
    case Expr::Type::NONE:
        os << "NONE";
        break;
    case Expr::Type::LIST:
        os << "LIST";
        break;
    case Expr::Type::TUPLE:
        os << "TUPLE";
        break;
    case Expr::Type::DICT:
        os << "DICT";
        break;
    case Expr::Type::POS:
        os << "POS";
        break;
    case Expr::Type::NEG:
        os << "NEG";
        break;
    case Expr::Type::INVERT:
        os << "INVERT";
        break;
    case Expr::Type::NOT:
        os << "NOT";
        break;
    case Expr::Type::ADD:
        os << "ADD";
        break;
    case Expr::Type::SUB:
        os << "SUB";
        break;
    case Expr::Type::MUL:
        os << "MUL";
        break;
    case Expr::Type::DIV:
        os << "DIV";
        break;
    case Expr::Type::FLOORDIV:
        os << "FLOORDIV";
        break;
    case Expr::Type::MOD:
        os << "MOD";
        break;
    case Expr::Type::POW:
        os << "POW";
        break;
    case Expr::Type::RSHIFT:
        os << "RSHIFT";
        break;
    case Expr::Type::LSHIFT:
        os << "LSHIFT";
        break;
    case Expr::Type::BITAND:
        os << "BITAND";
        break;
    case Expr::Type::BITOR:
        os << "BITOR";
        break;
    case Expr::Type::XOR:
        os << "XOR";
        break;
    case Expr::Type::LT:
        os << "LT";
        break;
    case Expr::Type::GT:
        os << "GT";
        break;
    case Expr::Type::LE:
        os << "LE";
        break;
    case Expr::Type::GE:
        os << "GE";
        break;
    case Expr::Type::EQ:
        os << "EQ";
        break;
    case Expr::Type::NE:
        os << "NE";
        break;
    case Expr::Type::AND:
        os << "AND";
        break;
    case Expr::Type::OR:
        os << "OR";
        break;
    case Expr::Type::IN:
        os << "IN";
        break;
    case Expr::Type::NOT_IN:
        os << "NOT_IN";
        break;
    case Expr::Type::IF:
        os << "IF_EXPR";
        break;
    case Expr::Type::CALL:
        os << "CALL";
        break;
    case Expr::Type::DOT:
        os << "DOT";
        break;
    case Expr::Type::SLICE:
        os << "SLICE";
        break;
    case Expr::Type::LIST_COMPREHENSION:
        os << "LIST_COMPREHENSION";
        break;
    case Expr::Type::DICT_COMPREHENSION:
        os << "DICT_COMPREHENSION";
        break;
    case Expr::Type::LAMBDA:
        os << "LAMBDA";
        break;
    }
    return os;
}

std::ostream& operator<<(std::ostream& os, const Expr& e)
{
    os << e.type << "(";
    switch (e.type) {
    case Expr::Type::IDENTIFIER:
    case Expr::Type::INT:
    case Expr::Type::STRING:
    case Expr::Type::BYTES:
        os << get<string>(e.data);
        break;
    case Expr::Type::FLOAT:
        os << get<double>(e.data);
        break;
    case Expr::Type::LIST:
        print_exprs(os, get<std::deque<Expr>>(e.data));
        break;
    case Expr::Type::TUPLE:
        print_exprs(os, get<std::deque<Expr>>(e.data));
        break;
    case Expr::Type::DICT:
        print_dict(os, get<Expr::Dict>(e.data));
        break;
    case Expr::Type::POS:
    case Expr::Type::NEG:
    case Expr::Type::INVERT:
    case Expr::Type::NOT:
        os << *get<PExpr>(e.data);
        break;
    case Expr::Type::ADD:
    case Expr::Type::SUB:
    case Expr::Type::MUL:
    case Expr::Type::DIV:
    case Expr::Type::FLOORDIV:
    case Expr::Type::MOD:
    case Expr::Type::POW:
    case Expr::Type::RSHIFT:
    case Expr::Type::LSHIFT:
    case Expr::Type::BITAND:
    case Expr::Type::BITOR:
    case Expr::Type::XOR:
    case Expr::Type::LT:
    case Expr::Type::GT:
    case Expr::Type::LE:
    case Expr::Type::GE:
    case Expr::Type::EQ:
    case Expr::Type::NE:
    case Expr::Type::AND:
    case Expr::Type::OR:
    case Expr::Type::IN:
    case Expr::Type::NOT_IN: {
        auto& p = get<std::pair<PExpr, PExpr>>(e.data);
        os << *p.first << "," << *p.second;
        break;
    }
    case Expr::Type::IF:
        os << get<IfExpr>(e.data);
        break;
    case Expr::Type::CALL:
        os << get<CallExpr>(e.data);
        break;
    case Expr::Type::DOT:
        os << get<DotExpr>(e.data);
        break;
    case Expr::Type::SLICE:
        os << get<SliceExpr>(e.data);
        break;
    case Expr::Type::LIST_COMPREHENSION:
        os << get<ListComprehension>(e.data);
        break;
    case Expr::Type::DICT_COMPREHENSION:
        os << get<DictComprehension>(e.data);
        break;
    case Expr::Type::LAMBDA:
        os << get<LambdaExpr>(e.data);
        break;
    }
    os << ")";
    return os;
}

std::ostream& operator<<(std::ostream& os, const IfExpr& e)
{
    os << *e.condition << "," << *e.true_val << "," << *e.false_val;
    return os;
}

std::ostream& operator<<(std::ostream& os, const CallExpr& e)
{
    os << *e.callee;
    for (auto arg = e.arguments.begin(); arg != e.arguments.end(); ++arg) {
        os << "," << *arg;
    }
    return os;
}
std::ostream& operator<<(std::ostream& os, const SliceExpr& e)
{
    os << *e.sequence << ","
       << "Slice(";
    if (auto p1 = get_if<PExpr>(&e.slice)) {
        os << **p1;
    }
    if (auto p1 = get_if<std::pair<std::optional<PExpr>, std::optional<PExpr>>>(&e.slice)) {
        os << **(p1->first) << ":" << **(p1->second);
    }
    if (auto p1 = get_if<std::tuple<std::optional<PExpr>, std::optional<PExpr>, std::optional<PExpr>>>(&e.slice)) {
        os << **(std::get<0>(*p1)) << ":"
           << **(std::get<1>(*p1)) << ":"
           << **(std::get<2>(*p1));
    }
    return os;
}
std::ostream& operator<<(std::ostream& os, const DotExpr& e)
{
    os << *e.obj << "," << e.attr;
    return os;
}
std::ostream& operator<<(std::ostream& os, const LambdaExpr& e)
{
    static const char SEP_0[] = "";
    static const char SEP_1[] = ",";
    const char* sep = SEP_0;
    for (const Parameter& i : e.parameters) {
        os << sep << i;
        sep = SEP_1;
    }
    os << "," << *e.return_val;
    return os;
}
std::ostream& operator<<(std::ostream& os, const ListComprehension& e)
{
    os << *e.item;
    for (const ComprehensionClause& i : e.clauses) {
        os << "," << i;
    }
    return os;
}
std::ostream& operator<<(std::ostream& os, const DictComprehension& e)
{
    os << *e.item.first << ":" << *e.item.second;
    for (const ComprehensionClause& i : e.clauses) {
        os << "," << i;
    }
    return os;
}

std::ostream& operator<<(std::ostream& os, const Argument& arg)
{
    if (get_if<Argument::NORMAL>(&arg.type)) {
        os << *arg.value;
    } else if (get_if<Argument::UNPACK_SEQUENCE>(&arg.type)) {
        os << "*" << *arg.value;
    } else if (get_if<Argument::UNPACK_DICT>(&arg.type)) {
        os << "**" << *arg.value;
    } else if (auto kw = get_if<Identifier>(&arg.type)) {
        os << *kw << "=" << *arg.value;
    }
    return os;
}

void print_dict(std::ostream& os, const Expr::Dict& d)
{
    static const char SEP_0[] = "";
    static const char SEP_1[] = ",";
    const char* sep = SEP_0;
    for (const pair<Expr, Expr>& i : d) {
        os << sep << i.first << ":" << i.second;
        sep = SEP_1;
    }
}

void print_exprs(std::ostream& os, const std::deque<Expr>& l)
{
    for (auto it = l.begin(); it != l.end(); ++it) {
        os << *it;
        if (std::next(it) != l.end()) {
            os << ",";
        }
    }
}

std::ostream& operator<<(std::ostream& os, const ComprehensionClause& c)
{
    if (auto p = get_if<ForClause>(&c)) {
        os << "FOR(" << *p->for_what << "," << *p->in_what << ")";
    } else if (auto p = get_if<IfClause>(&c)) {
        os << "IF(" << *p->condition << ")";
    }
    return os;
}
