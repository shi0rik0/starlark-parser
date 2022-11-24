#include "debug.h"
#include "lexer.h"
#include "parser.h"
#include "types.h"
#include "utils.h"
#include <stdio.h>

int main(void)
{

    StatementList* ret;

    if (yyparse(&ret) == 0) {
        puts("parse success");
    }

    return 0;
}
