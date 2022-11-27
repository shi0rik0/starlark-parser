#include "expr.h"
#include "utils.h"
#include <memory>

using namespace std;

std::ostream& operator<<(std::ostream& os, const Expr& e)
{
    return os;
}
std::ostream& operator<<(std::ostream& os, const CallExpr& e)
{
    return os;
}
std::ostream& operator<<(std::ostream& os, const SliceExpr& e)
{
    return os;
}
std::ostream& operator<<(std::ostream& os, const LambdaExpr& e)
{
    return os;
}
std::ostream& operator<<(std::ostream& os, const DotExpr& e)
{
    return os;
}
std::ostream& operator<<(std::ostream& os, const ListComprehension& e)
{
    return os;
}
std::ostream& operator<<(std::ostream& os, const DictComprehension& e)
{
    return os;
}