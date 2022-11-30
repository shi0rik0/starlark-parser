#ifndef UTILS_H
#define UTILS_H

#include "parser.h"
#include <string>

std::string token_to_str(int token, const YYSTYPE& value);

[[noreturn]] void fatal_error(const std::string& error_msg);

// the type of @format cannot be std::string
std::string sprintfpp(const char* format, ...);

std::ostream& operator<<(std::ostream& os, const std::deque<Expr>& l);

// @msg can be std::string or const char*
#define FATAL_ERROR(msg)                                                      \
    do {                                                                      \
        fatal_error(sprintfpp("error: %s:%d: ", __FILE__, __LINE__) + (msg)); \
    } while (false)

#ifdef DEBUG
#define ASSERT(p)                                 \
    do {                                          \
        if (!(p)) {                               \
            FATAL_ERROR("assertion failed: " #p); \
        }                                         \
    } while (false)
#else
#define ASSERT(p) \
    do {          \
    } while (false)
#endif

#endif // UTILS_H