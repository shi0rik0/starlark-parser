<<<<<<< HEAD
#include "debug.h"
=======
#include <stdio.h>
>>>>>>> update lexer
#include "lexer.h"
#include "parser.h"
#include "types.h"

#include <stdio.h>

int main(void)
{

    StatementList* ret;

    if (yyparse(&ret) == 0) {
        puts("parse success");
    }

    return 0;
}
