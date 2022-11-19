#ifndef F84986B2_6819_11ED_9F39_00155DC446E4
#define F84986B2_6819_11ED_9F39_00155DC446E4

#ifdef __cplusplus
extern "C"
{
#endif
    typedef enum
    {
        Statement_Type_DEF_STATEMENT,
        Statement_Type_IF_STATEMENT,
        Statement_Type_FOR_STATEMENT,
        Statement_Type_SIMPLE_STATEMENT,
    } Statement_Type;

    typedef struct
    {
        // todo
    } DefStatement;

    typedef struct
    {
        // todo
    } IfStatement;

    typedef struct
    {
        // todo
    } ForStatement;

    typedef struct
    {
        // todo
    } SimpleStatement;

    typedef struct
    {
        Statement_Type type;
        union
        {
            DefStatement *def_statement;
            IfStatement *if_statement;
            ForStatement *for_statement;
            SimpleStatement *simple_statement;

        } data;
    } Statement;

    typedef struct StatementList
    {
        Statement *current;
        struct StatementList *next;
    } StatementList;

#ifdef __cplusplus
}
#endif

#endif