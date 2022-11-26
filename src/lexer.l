%option noyywrap
%option yylineno


%top{
    // This part will be copied to lexer.h
    #include "parser.h"
    #include "utils.h"
}


%{
    // This part will be copied to lexer.cpp
    #include <stack>
    using namespace std;
    static char indent_char = 0;
    static int indent_length_temp = 0;

    static stack<int> indent_lengths;
    static stack<char> braces;
    
    static char get_all_same(const char* str) {
        if (str == nullptr || str[0] == '\0') {
            return 0;
        }
        char c = str[0];
        for (int i = 1; str[i] != '\0'; ++i) {
            if (str[i] != c) {
                return 0;
            }
        }
        return c;
    }
%}


IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*
INT -?[0-9]+
FLOAT -?((([0-9]*\.[0-9]*)(e-?[0-9]+)?)|([0-9]+(e-?[0-9]+)))
/* ord('[')==91 ord('\')==92 ord(']')==93*/
STRING \"([ -\x5b\x5d-~]|\\a|\\b|\\f|\\n|\\r|\\t|\\v)*\"|'([ -\x5b\x5d-~]|\\a|\\b|\\f|\\n|\\r|\\t|\\v)*\'
BYTES b\"([ -\x5b\x5d-~]|\\a|\\b|\\f|\\n|\\r|\\t|\\v)*\"|'([ -\x5b\x5d-~]|\\a|\\b|\\f|\\n|\\r|\\t|\\v)*\'
COMMENT #[^\n]*\n
/* supports both Unix and Windows style new line */
NL \n|\r\n 

%x STATE_LINE_START
%x STATE_NOT_LINE_START
%x STATE_DEDENT

%%

<INITIAL>. {
    // do some initialization work here
    yyless(0);
    indent_lengths.push(0);
    BEGIN(STATE_LINE_START);
}

<STATE_NOT_LINE_START>{COMMENT} {

}

<INITIAL,STATE_LINE_START><<EOF>> {
    if (!braces.empty()) {
        fatal_error("error: lexer: missing closed braces");
    }
    indent_length_temp = 0;
    BEGIN(STATE_DEDENT);
}


    /* add a fake new line if the input doesn't end with a new line */
<STATE_NOT_LINE_START><<EOF>> {
    if (!braces.empty()) {
        fatal_error("error: lexer: missing closed braces");
    }
    BEGIN(STATE_LINE_START);
    return yy::parser::token::NEW_LINE;
}


<STATE_NOT_LINE_START>{NL} {
    // ignore new line if in braces
    if (braces.empty()) {
        BEGIN(STATE_LINE_START);
        return yy::parser::token::NEW_LINE;
    }
}


<STATE_LINE_START>[ \t]+ {
    static const char error_msg[] = "error: lexer: use both spaces and tabs for indent in line %d";
    char c = get_all_same(yytext);
    if (!c) {
        fatal_error(sprintfpp(error_msg, yylineno));
    }
    if (!indent_char) {
        indent_char = c;
    } else if (c != indent_char) {
        fatal_error(sprintfpp(error_msg, yylineno));
    }
    if (yyleng > indent_lengths.top()) {
        indent_lengths.push(yyleng);
        BEGIN(STATE_NOT_LINE_START);
        return yy::parser::token::INDENT;
    }
    if (yyleng < indent_lengths.top()) {
        indent_length_temp = yyleng;
        BEGIN(STATE_DEDENT);
    } else {
        BEGIN(STATE_NOT_LINE_START);
    }
}


    /* empty line */
<STATE_LINE_START>[ \t]*{COMMENT}?{NL}? {
}

<STATE_DEDENT><<EOF>> {
    if (indent_length_temp > indent_lengths.top()) {
        fatal_error(sprintfpp("error: lexer: unknown indent level in line %d", yylineno));
    }
    yyless(0);
    if (indent_length_temp < indent_lengths.top()) {
        indent_lengths.pop();
        return yy::parser::token::DEDENT;
    } else {
        return 0;
    }
}

<STATE_DEDENT>. {
    if (indent_length_temp > indent_lengths.top()) {
        fatal_error(sprintfpp("error: lexer: unknown indent level in line %d", yylineno));
    }
    yyless(0);
    if (indent_length_temp < indent_lengths.top()) {
        indent_lengths.pop();
        return yy::parser::token::DEDENT;
    } 
    BEGIN(STATE_NOT_LINE_START);
}

<STATE_LINE_START>. {
    yyless(0);
    indent_length_temp = 0;
    BEGIN(STATE_DEDENT);
}

<STATE_NOT_LINE_START>[ \t]+ {

}


    /* Punctuations */
<STATE_NOT_LINE_START>"=" { return yy::parser::token::ASSIGN; }
<STATE_NOT_LINE_START>"+" { return yy::parser::token::ADD; }
<STATE_NOT_LINE_START>"-" { return yy::parser::token::SUB; }
<STATE_NOT_LINE_START>"*" { return yy::parser::token::MUL; }
<STATE_NOT_LINE_START>"/" { return yy::parser::token::DIV; }
<STATE_NOT_LINE_START>"//" { return yy::parser::token::FLOORDIV; }
<STATE_NOT_LINE_START>"%" { return yy::parser::token::MOD; }
<STATE_NOT_LINE_START>"**" { return yy::parser::token::POW; }
<STATE_NOT_LINE_START>">>" { return yy::parser::token::RSHIFT; }
<STATE_NOT_LINE_START>"<<" { return yy::parser::token::LSHIFT; }
<STATE_NOT_LINE_START>"&" { return yy::parser::token::BITAND; }
<STATE_NOT_LINE_START>"|" { return yy::parser::token::BITOR; }
<STATE_NOT_LINE_START>"^" { return yy::parser::token::XOR; }

<STATE_NOT_LINE_START>"+=" { return yy::parser::token::IADD; }
<STATE_NOT_LINE_START>"-=" { return yy::parser::token::ISUB; }
<STATE_NOT_LINE_START>"*=" { return yy::parser::token::IMUL; }
<STATE_NOT_LINE_START>"/=" { return yy::parser::token::IDIV; }
<STATE_NOT_LINE_START>"//=" { return yy::parser::token::IFLOORDIV; }
<STATE_NOT_LINE_START>"%=" { return yy::parser::token::IMOD; }
<STATE_NOT_LINE_START>"**=" { return yy::parser::token::IPOW; }
<STATE_NOT_LINE_START>"<<=" { return yy::parser::token::IRSHIFT; }
<STATE_NOT_LINE_START>">>=" { return yy::parser::token::ILSHIFT; }
<STATE_NOT_LINE_START>"&=" { return yy::parser::token::IBITAND; }
<STATE_NOT_LINE_START>"|=" { return yy::parser::token::IBITOR; }
<STATE_NOT_LINE_START>"^=" { return yy::parser::token::IXOR; }

<STATE_NOT_LINE_START>"<" { return yy::parser::token::LT; }
<STATE_NOT_LINE_START>">" { return yy::parser::token::GT; }
<STATE_NOT_LINE_START>"<=" { return yy::parser::token::LE; }
<STATE_NOT_LINE_START>">=" { return yy::parser::token::GE; }
<STATE_NOT_LINE_START>"==" { return yy::parser::token::EQ; }
<STATE_NOT_LINE_START>"!=" { return yy::parser::token::NE; }

<STATE_NOT_LINE_START>"+" { return yy::parser::token::POS; }
<STATE_NOT_LINE_START>"-" { return yy::parser::token::NEG; }
<STATE_NOT_LINE_START>"~" { return yy::parser::token::INVERT; }

<STATE_NOT_LINE_START>"." { return yy::parser::token::DOT; }
<STATE_NOT_LINE_START>"," { return yy::parser::token::COMMA; }
<STATE_NOT_LINE_START>";" { return yy::parser::token::SEMICOLON; }
<STATE_NOT_LINE_START>":" { return yy::parser::token::COLON; }

<STATE_NOT_LINE_START>"(" {
    braces.push('(');
    return yy::parser::token::LPAREN;
}
<STATE_NOT_LINE_START>")" {
    if (braces.empty() || braces.top() != '(') {
        fatal_error("error: lexer: unmatched braces");
    }
    braces.pop();
    return yy::parser::token::RPAREN;
}
<STATE_NOT_LINE_START>"[" {
    braces.push('[');
    return yy::parser::token::LBRACKET;
}
<STATE_NOT_LINE_START>"]" {
    if (braces.empty() || braces.top() != '[') {
        fatal_error("error: lexer: unmatched braces");
    }
    braces.pop();
    return yy::parser::token::RBRACKET;
}
<STATE_NOT_LINE_START>"{" {
    braces.push('{');
    return yy::parser::token::LBRACE;
}
<STATE_NOT_LINE_START>"}" {
    if (braces.empty() || braces.top() != '{') {
        fatal_error("error: lexer: unmatched braces");
    }
    braces.pop();
    return yy::parser::token::RBRACE;
}

    /* Keywords */
<STATE_NOT_LINE_START>"and" { return yy::parser::token::AND; }
<STATE_NOT_LINE_START>"elif" { return yy::parser::token::ELIF; }
<STATE_NOT_LINE_START>"in" { return yy::parser::token::IN; }
<STATE_NOT_LINE_START>"or" { return yy::parser::token::OR; }
<STATE_NOT_LINE_START>"break" { return yy::parser::token::BREAK; }
<STATE_NOT_LINE_START>"else" { return yy::parser::token::ELSE; }
<STATE_NOT_LINE_START>"lambda" { return yy::parser::token::LAMBDA; }
<STATE_NOT_LINE_START>"pass" { return yy::parser::token::PASS; }
<STATE_NOT_LINE_START>"continue" { return yy::parser::token::CONTINUE; }
<STATE_NOT_LINE_START>"for" { return yy::parser::token::FOR; }
<STATE_NOT_LINE_START>"load" { return yy::parser::token::LOAD; }
<STATE_NOT_LINE_START>"return" { return yy::parser::token::RETURN; }
<STATE_NOT_LINE_START>"def" { return yy::parser::token::DEF; }
<STATE_NOT_LINE_START>"if" { return yy::parser::token::IF; }
<STATE_NOT_LINE_START>"not" { return yy::parser::token::NOT; }
<STATE_NOT_LINE_START>"while" { return yy::parser::token::WHILE; }


<STATE_NOT_LINE_START>{FLOAT} {
    yylval->emplace<double>(atof(yytext));
    return yy::parser::token::FLOAT;
}

<STATE_NOT_LINE_START>{INT} {
    yylval->emplace<string>(yytext);
    return yy::parser::token::INT;
}

<STATE_NOT_LINE_START>{IDENTIFIER} {
    yylval->emplace<string>(yytext);
    return yy::parser::token::IDENTIFIER;
}

<STATE_NOT_LINE_START>{STRING} {
    yylval->emplace<string>(yytext);
    return yy::parser::token::STRING;
}

<STATE_NOT_LINE_START>{BYTES} {
    yylval->emplace<string>(yytext);
    return yy::parser::token::BYTES;
}

<STATE_NOT_LINE_START>. {
    fatal_error(sprintfpp("error: lexer: illegal token %s in line %d\n", yytext, yylineno));
}
