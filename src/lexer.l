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
    indent_length_temp = 0;
    BEGIN(STATE_DEDENT);
}


    /* add a fake new line if the input doesn't end with a new line */
<STATE_NOT_LINE_START><<EOF>> {
    BEGIN(STATE_LINE_START);
    return NEW_LINE;
}


<STATE_NOT_LINE_START>{NL} {
    BEGIN(STATE_LINE_START);
    return NEW_LINE;
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
        return INDENT;
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
        return DEDENT;
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
        return DEDENT;
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
<STATE_NOT_LINE_START>"=" { return ASSIGN; }
<STATE_NOT_LINE_START>"+" { return ADD; }
<STATE_NOT_LINE_START>"-" { return SUB; }
<STATE_NOT_LINE_START>"*" { return MUL; }
<STATE_NOT_LINE_START>"/" { return DIV; }
<STATE_NOT_LINE_START>"//" { return FLOORDIV; }
<STATE_NOT_LINE_START>"%" { return MOD; }
<STATE_NOT_LINE_START>"**" { return POW; }
<STATE_NOT_LINE_START>">>" { return RSHIFT; }
<STATE_NOT_LINE_START>"<<" { return LSHIFT; }
<STATE_NOT_LINE_START>"&" { return BITAND; }
<STATE_NOT_LINE_START>"|" { return BITOR; }
<STATE_NOT_LINE_START>"^" { return XOR; }

<STATE_NOT_LINE_START>"+=" { return IADD; }
<STATE_NOT_LINE_START>"-=" { return ISUB; }
<STATE_NOT_LINE_START>"*=" { return IMUL; }
<STATE_NOT_LINE_START>"/=" { return IDIV; }
<STATE_NOT_LINE_START>"//=" { return IFLOORDIV; }
<STATE_NOT_LINE_START>"%=" { return IMOD; }
<STATE_NOT_LINE_START>"**=" { return IPOW; }
<STATE_NOT_LINE_START>"<<=" { return IRSHIFT; }
<STATE_NOT_LINE_START>">>=" { return ILSHIFT; }
<STATE_NOT_LINE_START>"&=" { return IBITAND; }
<STATE_NOT_LINE_START>"|=" { return IBITOR; }
<STATE_NOT_LINE_START>"^=" { return IXOR; }

<STATE_NOT_LINE_START>"<" { return LT; }
<STATE_NOT_LINE_START>">" { return GT; }
<STATE_NOT_LINE_START>"<=" { return LE; }
<STATE_NOT_LINE_START>">=" { return GE; }
<STATE_NOT_LINE_START>"==" { return EQ; }
<STATE_NOT_LINE_START>"!=" { return NE; }

<STATE_NOT_LINE_START>"+" { return POS; }
<STATE_NOT_LINE_START>"-" { return NEG; }
<STATE_NOT_LINE_START>"~" { return INVERT; }

<STATE_NOT_LINE_START>"." { return DOT; }
<STATE_NOT_LINE_START>"," { return COMMA; }
<STATE_NOT_LINE_START>";" { return SEMICOLON; }
<STATE_NOT_LINE_START>":" { return COLON; }

<STATE_NOT_LINE_START>"(" { return LPAREN; }
<STATE_NOT_LINE_START>")" { return RPAREN; }
<STATE_NOT_LINE_START>"[" { return LBRACKET; }
<STATE_NOT_LINE_START>"]" { return RBRACKET; }
<STATE_NOT_LINE_START>"{" { return LBRACE; }
<STATE_NOT_LINE_START>"}" { return RBRACE; }

    /* Keywords */
<STATE_NOT_LINE_START>"and" { return AND; }
<STATE_NOT_LINE_START>"elif" { return ELIF; }
<STATE_NOT_LINE_START>"in" { return IN; }
<STATE_NOT_LINE_START>"or" { return OR; }
<STATE_NOT_LINE_START>"break" { return BREAK; }
<STATE_NOT_LINE_START>"else" { return ELSE; }
<STATE_NOT_LINE_START>"lambda" { return LAMBDA; }
<STATE_NOT_LINE_START>"pass" { return PASS; }
<STATE_NOT_LINE_START>"continue" { return CONTINUE; }
<STATE_NOT_LINE_START>"for" { return FOR; }
<STATE_NOT_LINE_START>"load" { return LOAD; }
<STATE_NOT_LINE_START>"return" { return RETURN; }
<STATE_NOT_LINE_START>"def" { return DEF; }
<STATE_NOT_LINE_START>"if" { return IF; }
<STATE_NOT_LINE_START>"not" { return NOT; }
<STATE_NOT_LINE_START>"while" { return WHILE; }


<STATE_NOT_LINE_START>{FLOAT} {
    yylval.float_ = atof(yytext);
    return FLOAT;
}

<STATE_NOT_LINE_START>{INT} {
    yylval.string = new_str(yytext, yyleng);
    return INT;
}

<STATE_NOT_LINE_START>{IDENTIFIER} {
    yylval.string = new_str(yytext, yyleng);
    return IDENTIFIER;
}

<STATE_NOT_LINE_START>{STRING} {
    yylval.string = new_str(yytext, yyleng);
    return STRING;
}

<STATE_NOT_LINE_START>{BYTES} {
    yylval.string = new_str(yytext, yyleng);
    return BYTES;
}

<STATE_NOT_LINE_START>. {
    fatal_error(sprintfpp("error: lexer: illegal token %s in line %d\n", yytext, yylineno));
}
