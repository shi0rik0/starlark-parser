#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "types.h"
#include "utils.h"
#include "parser.h"

void print_token(int c) {
    switch (c) {
    case ADD:
        printf("ADD");
        break;
    case IDENTIFIER:
        printf("IDENTIFIER");
        break;
    }
  
}

char * new_str(char * str, int len) {
  char * res = (char *) malloc(sizeof(char) * (len + 1));
  if (res == NULL) {
    printf("Failure in malloc.\n");
    exit(0);
  }
  strcpy(res, str);
  return res;
}