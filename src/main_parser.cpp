#include "lexer.h"
#include "parser.h"
#include "statements.h"
#include "utils.h"

using namespace std;

int main(void)
{
    deque<Statement> v;

    yy::parser parser(v);
    parser.parse();

    for (const Statement& i : v) {
        cout << i;
    }

    return 0;
}
