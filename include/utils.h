#ifndef UTILS_H
#define UTILS_H

#include "parser.h"
#include <string>

std::string token_to_str(int token, const YYSTYPE& value);

[[noreturn]] void fatal_error(const std::string& error_msg);

// the type of @format cannot be std::string
std::string sprintfpp(const char* format, ...);

// @msg should be a std::string
#define FATAL_ERROR(msg)                                                             \
    do {                                                                             \
        fatal_error(sprintfpp("error: %s:%d: %s", __FILE__, __LINE__, msg.c_str())); \
    } while (false)

#endif // UTILS_H