#include "utils.h"
#include "parser.h"
#include "types.h"
#include <cstdarg>
#include <iostream>

using namespace std;

string token_to_str(int token, const YYSTYPE& value)
{
    switch (token) {
    case yy::parser::token::IDENTIFIER:
        return sprintfpp("identifier(%s)", value.as<string>().c_str());
        break;
    case yy::parser::token::INT:
        return sprintfpp("int(%s)", value.as<string>().c_str());
        break;
    case yy::parser::token::FLOAT:
        return sprintfpp("float(%f)", value.as<double>());
        break;
    case yy::parser::token::STRING:
        return sprintfpp("string(%s)", value.as<string>().c_str());
        break;
    case yy::parser::token::BYTES:
        return sprintfpp("bytes");
        break;
    case yy::parser::token::NEW_LINE:
        return sprintfpp("new_line");
        break;
    case yy::parser::token::INDENT:
        return sprintfpp("indent");
        break;
    case yy::parser::token::ASSIGN:
        return sprintfpp("assign");
        break;
    case yy::parser::token::ADD:
        return sprintfpp("add");
        break;
    case yy::parser::token::SUB:
        return sprintfpp("sub");
        break;
    case yy::parser::token::MUL:
        return sprintfpp("mul");
        break;
    case yy::parser::token::DIV:
        return sprintfpp("div");
        break;
    case yy::parser::token::FLOORDIV:
        return sprintfpp("floordiv");
        break;
    case yy::parser::token::MOD:
        return sprintfpp("mod");
        break;
    case yy::parser::token::POW:
        return sprintfpp("pow");
        break;
    case yy::parser::token::RSHIFT:
        return sprintfpp("rshift");
        break;
    case yy::parser::token::LSHIFT:
        return sprintfpp("lshift");
        break;
    case yy::parser::token::BITAND:
        return sprintfpp("bitand");
        break;
    case yy::parser::token::BITOR:
        return sprintfpp("bitor");
        break;
    case yy::parser::token::XOR:
        return sprintfpp("xor");
        break;
    case yy::parser::token::IADD:
        return sprintfpp("iadd");
        break;
    case yy::parser::token::ISUB:
        return sprintfpp("isub");
        break;
    case yy::parser::token::IMUL:
        return sprintfpp("imul");
        break;
    case yy::parser::token::IDIV:
        return sprintfpp("idiv");
        break;
    case yy::parser::token::IFLOORDIV:
        return sprintfpp("ifloordiv");
        break;
    case yy::parser::token::IMOD:
        return sprintfpp("imod");
        break;
    case yy::parser::token::IPOW:
        return sprintfpp("ipow");
        break;
    case yy::parser::token::IRSHIFT:
        return sprintfpp("irshift");
        break;
    case yy::parser::token::ILSHIFT:
        return sprintfpp("ilshift");
        break;
    case yy::parser::token::IBITAND:
        return sprintfpp("ibitand");
        break;
    case yy::parser::token::IBITOR:
        return sprintfpp("ibitor");
        break;
    case yy::parser::token::IXOR:
        return sprintfpp("ixor");
        break;
    case yy::parser::token::LT:
        return sprintfpp("lt");
        break;
    case yy::parser::token::GT:
        return sprintfpp("gt");
        break;
    case yy::parser::token::LE:
        return sprintfpp("le");
        break;
    case yy::parser::token::GE:
        return sprintfpp("ge");
        break;
    case yy::parser::token::EQ:
        return sprintfpp("eq");
        break;
    case yy::parser::token::NE:
        return sprintfpp("ne");
        break;
    case yy::parser::token::POS:
        return sprintfpp("pos");
        break;
    case yy::parser::token::NEG:
        return sprintfpp("neg");
        break;
    case yy::parser::token::INVERT:
        return sprintfpp("invert");
        break;
    case yy::parser::token::DOT:
        return sprintfpp("dot");
        break;
    case yy::parser::token::COMMA:
        return sprintfpp("comma");
        break;
    case yy::parser::token::SEMICOLON:
        return sprintfpp("semicolon");
        break;
    case yy::parser::token::COLON:
        return sprintfpp("colon");
        break;
    case yy::parser::token::LPAREN:
        return sprintfpp("lparen");
        break;
    case yy::parser::token::RPAREN:
        return sprintfpp("rparen");
        break;
    case yy::parser::token::LBRACKET:
        return sprintfpp("lbracket");
        break;
    case yy::parser::token::RBRACKET:
        return sprintfpp("rbracket");
        break;
    case yy::parser::token::LBRACE:
        return sprintfpp("lbrace");
        break;
    case yy::parser::token::RBRACE:
        return sprintfpp("rbrace");
        break;
    case yy::parser::token::AND:
        return sprintfpp("and");
        break;
    case yy::parser::token::ELIF:
        return sprintfpp("elif");
        break;
    case yy::parser::token::IN:
        return sprintfpp("in");
        break;
    case yy::parser::token::OR:
        return sprintfpp("or");
        break;
    case yy::parser::token::BREAK:
        return sprintfpp("break");
        break;
    case yy::parser::token::ELSE:
        return sprintfpp("else");
        break;
    case yy::parser::token::LAMBDA:
        return sprintfpp("lambda");
        break;
    case yy::parser::token::PASS:
        return sprintfpp("pass");
        break;
    case yy::parser::token::CONTINUE:
        return sprintfpp("continue");
        break;
    case yy::parser::token::FOR:
        return sprintfpp("for");
        break;
    case yy::parser::token::LOAD:
        return sprintfpp("load");
        break;
    case yy::parser::token::RETURN:
        return sprintfpp("return");
        break;
    case yy::parser::token::DEF:
        return sprintfpp("def");
        break;
    case yy::parser::token::IF:
        return sprintfpp("if");
        break;
    case yy::parser::token::NOT:
        return sprintfpp("not");
        break;
    case yy::parser::token::WHILE:
        return sprintfpp("while");
        break;
    case yy::parser::token::DEDENT:
        return sprintfpp("dedent");
        break;
    default:
        fatal_error("error: unknown token");
        break;
    }
}

std::ostream& operator<<(std::ostream& os, const std::deque<Expr>& l)
{
    for (auto it = l.begin(); it != l.end(); ++it) {
        os << *it;
        if (std::next(it) != l.end()) {
            os << ",";
        }
    }
    return os;
}

void fatal_error(const std::string& error_msg)
{
    cerr << error_msg;
    if (error_msg.empty() || error_msg.back() != '\n') {
        cerr << endl;
    }
    exit(1);
}

std::string sprintfpp(const char* format, ...)
{
    static char buf[1];
    va_list args;
    va_start(args, format);
    int len = vsnprintf(buf, 1, format, args);
    va_end(args);
    char* s = new char[len + 1];
    va_start(args, format);
    vsnprintf(s, len + 1, format, args);
    va_end(args);
    string ret(s);
    delete[] s;
    return ret;
}