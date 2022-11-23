#include "lexer.h"
#include "utils.h"
int main(void) {
    int c;
  while (1) {
    c = yylex();
    if (c != 0) {
      print_token(c);
    }
    else {
      break;
    }
  }
}