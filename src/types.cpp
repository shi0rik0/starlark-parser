#include "types.h"
#include "utils.h"

using namespace std;

std::ostream& operator<<(std::ostream& os, const Statement& s)
{
    os << get<ExprStatement>(s.data);
    return os;
}

std::ostream& operator<<(std::ostream& os, const ExprStatement& s)
{
    os << s.expr;
    return os;
}
