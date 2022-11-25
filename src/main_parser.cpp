#include "lexer.h"
#include "parser.h"
#include "types.h"
#include "utils.h"
#include <stdio.h>

int main(void)
{
    StatementList* ret;

    yy::parser parser(&ret);
    parser.parse();

    return 0;
}
