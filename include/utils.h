#ifndef UTILS_H
#define UTILS_H

#include "parser.h"
#include <string>

char* new_str(char* str, int len);
void print_token(int token, const YYSTYPE& value);
void fatal_error(const std::string& error_msg);

// the type of @format cannot be std::string
std::string sprintfpp(const char* format, ...);

#endif // UTILS_H