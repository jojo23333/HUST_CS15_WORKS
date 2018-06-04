
%{

// #include <string.h>
// #include <stdio.h>
// #include "scanner.tab.h"
// #include "scanner.h"
// #include "errors.h"

// Control debug info
int show_info = 1;
// #define YY_USER_ACTION \
//     yylloc.first_line = yylloc.last_line = yylineno; \
//     yylloc.first_column = yycolumn; \
//     yylloc.last_column = yycolumn + yyleng - 1; \
//     yycolumn += yyleng;
// enum{
//     KEY_BOOL,KEY_INT,KEY_STRING,KEY_BREAK,KEY_CLASS,KEY_ELSE,
//     KEY_EXTENDS,KEY_FOR,KEY_IF,KEY_NEW,KEY_RETURN,KEY_THIS,KEY_VOID,
//     KEY_WHILE,KEY_STATIC,KEY_PRINT,KEY_READINTEGER,
//     KEY_READLINE,KEY_INSTANCEOF, CONSTANT_NULL,CONSTANT_BOOL,
//     CONSTANT_HEXINT,CONSTANT_INT,CONSTANT_STRING,
//     OP_ADD,OP_SUB ,OP_MUL ,OP_DIV ,OP_MOD ,OP_LESS,
//     OP_LESSEQUAL ,OP_GREATER ,OP_GREATEREQUAL ,OP_ASSGIN ,OP_EQUAL ,OP_NOTEQUAL ,
//     OP_AND ,OP_OR ,OP_NOT ,OP_SEM ,OP_COMMA ,OP_DOT ,
//     OP_LBRACKET ,OP_RBRACKET ,OP_LPARENTHESIS ,OP_RPARENTHESIS,
//     OP_LBRACE ,OP_RBRACE ,
//     INDENTIFIER ,
//     COMMENT , BLANK ,ENTER ,WRONGSTRING ,WRONGIDENTIFIER,
// }
%}
%option yylineno

KEY_BOOL        "bool"
KEY_INT         "int"
KEY_STRING      "string"
KEY_BREAK       "break"
KEY_CLASS       "class"
KEY_ELSE        "else"
KEY_EXTENDS     "extends"
KEY_FOR         "for"
KEY_IF          "if"
KEY_NEW         "new"
KEY_RETURN      "return"
KEY_THIS        "this"
KEY_VOID        "void"
KEY_WHILE       "while"
KEY_STATIC      "static"
KEY_PRINT       "Print"
KEY_READINTEGER "ReadInteger"
KEY_READLINE    "ReadLine"
KEY_INSTANCEOF  "instaceof"

DECIMAL         [0-9]
HEXDICIMAL      {DECIMAL}|[a-fA-F]
CONSTANT_NULL   "null"
CONSTANT_BOOL   "true"|"false"
CONSTANT_HEXINT	[+-]?0[Xx]{HEXDICIMAL}+
CONSTANT_INT    [+-]?{DECIMAL}+
CONSTANT_STRING \"[^"\n]*\"

OP_ADD          "+"  
OP_SUB          "-"
OP_MUL          "*"
OP_DIV          "/"
OP_MOD          "%"
OP_LESS         "<"
OP_LESSEQUAL    "<="
OP_GREATER      ">"
OP_GREATEREQUAL ">="
OP_ASSGIN       "="
OP_EQUAL        "=="
OP_NOTEQUAL     "!="
OP_AND          "&&"
OP_OR           "||"
OP_NOT          "!"
OP_SEM          ";"
OP_COMMA        ","
OP_DOT          "."
OP_LBRACKET     "["
OP_RBRACKET     "]"
OP_LPARENTHESIS "("
OP_RPARENTHESIS ")"
OP_LBRACE       "{"
OP_RBRACE       "}"

INDENTIFIER     [a-zA-Z][a-zA-Z0-9_]* 
COMMENT         (\/\/.*)|(\/\*((\*[^\/]?)|[^\*]*)*\*\/)
BLANK           " "|\t
ENTER           \n
WRONGSTRING     \"[^\"\n]*$
WRONGIDENTIFIER [0-9_][a-zA-Z0-9_]* 
AERROR          .


%%             /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section. 
  */ 
{KEY_BOOL} {
    if (show_info) 
        printf("(%s, KEY_BOOL) : %d\n", yytext, yylineno);
    //return KEY_BOOL;
}
{KEY_INT} {
    if (show_info) 
        printf("(%s, KEY_INT) : %d\n", yytext, yylineno);
    //return KEY_INT;
}
{KEY_STRING} {
    if (show_info) 
        printf("(%s, KEY_STRING) : %d\n", yytext, yylineno);
    //return KEY_STRING;
}
{KEY_BREAK} {
    if (show_info) 
        printf("(%s, KEY_BREAK) : %d\n", yytext, yylineno);
    //return KEY_BREAK;
}
{KEY_CLASS} {
    if (show_info) 
        printf("(%s, KEY_CLASS) : %d\n", yytext, yylineno);
    //return KEY_CLASS;
}
{KEY_ELSE} {
    if (show_info) 
        printf("(%s, KEY_ELSE) : %d\n", yytext, yylineno);
    //return KEY_ELSE;
}
{KEY_EXTENDS} {
    if (show_info) 
        printf("(%s, KEY_EXTENDS) : %d\n", yytext, yylineno);
    //return KEY_EXTENDS;
}
{KEY_FOR} {
    if (show_info) 
        printf("(%s, KEY_FOR) : %d\n", yytext, yylineno);
    //return KEY_FOR;
}
{KEY_IF} {
    if (show_info) 
        printf("(%s, KEY_IF) : %d\n", yytext, yylineno);
    //return KEY_IF;
}
{KEY_NEW} {
    if (show_info) 
        printf("(%s, KEY_NEW) : %d\n", yytext, yylineno);
    //return KEY_NEW;
}
{KEY_RETURN} {
    if (show_info) 
        printf("(%s, KEY_RETURN) : %d\n", yytext, yylineno);
    //return KEY_RETURN;
}
{KEY_THIS}  {
    if (show_info) 
        printf("(%s, KEY_THIS) : %d\n", yytext, yylineno);
    //return KEY_THIS;
}
{KEY_VOID} {
    if (show_info) 
        printf("(%s, KEY_VOID) : %d\n", yytext, yylineno);
    //return KEY_VOID;
}
{KEY_WHILE} {
    if (show_info) 
        printf("(%s, KEY_WHILE) : %d\n", yytext, yylineno);
    //return KEY_WHILE;
}
{KEY_STATIC} {
    if (show_info) 
        printf("(%s, KEY_STATIC) : %d\n", yytext, yylineno);
    //return KEY_STATIC;
}
{KEY_PRINT} {
    if (show_info) 
        printf("(%s, KEY_PRINT) : %d\n", yytext, yylineno);
    //return KEY_PRINT;
}
{KEY_READINTEGER} {
    if (show_info) 
        printf("(%s, KEY_READINTEGER) : %d\n", yytext, yylineno);
    //return KEY_READINTEGER;
}
{KEY_READLINE} {
    if (show_info) 
        printf("(%s, KEY_READLINE) : %d\n", yytext, yylineno);
    //return KEY_READLINE;
}
{KEY_INSTANCEOF} {
    if (show_info) 
        printf("(%s, KEY_INSTANCEOF) : %d\n", yytext, yylineno);
    //return KEY_INSTANCEOF;
}

{CONSTANT_NULL} {
    if (show_info) 
        printf("(%s, CONSTANT_NULL) : %d\n", yytext, yylineno);
    //return CONSTANT_NULL;
}
{CONSTANT_BOOL} {
    if (show_info) 
        printf("(%s, CONSTANT_BOOL) : %d\n", yytext, yylineno);
    //return CONSTANT_BOOL;
}
{CONSTANT_HEXINT} {
    if (show_info) 
        printf("(%s, CONSTANT_HEXINT) : %d\n", yytext, yylineno);
    //return CONSTANT_BOOL;
}
{CONSTANT_INT} {
    if (show_info) 
        printf("(%s, CONSTANT_INT) : %d\n", yytext, yylineno);
    //return CONSTANT_BOOL;
}
{CONSTANT_STRING} {
    if (show_info) 
        printf("(%s, CONSTANT_STRING) : %d\n", yytext, yylineno);
    //return CONSTANT_STRING;
}

{OP_ADD} {
    if (show_info) 
        printf("(%s, OP_ADD) : %d\n", yytext, yylineno);
    //return OP_ADD;
}
{OP_SUB} {
    if (show_info) 
        printf("(%s, OP_SUB) : %d\n", yytext, yylineno);
    //return OP_SUB;
}
{OP_MUL} {
    if (show_info) 
        printf("(%s, OP_MUL) : %d\n", yytext, yylineno);
    //return OP_MUL;
}
{OP_DIV} {
    if (show_info) 
        printf("(%s, OP_DIV) : %d\n", yytext, yylineno);
    //return OP_DIV;
}
{OP_MOD} {
    if (show_info) 
        printf("(%s, OP_MOD) : %d\n", yytext, yylineno);
    //return OP_MOD;
}
{OP_LESS} {
    if (show_info) 
        printf("(%s, OP_LESS) : %d\n", yytext, yylineno);
    //return OP_LESS;
}
{OP_LESSEQUAL} {
    if (show_info) 
        printf("(%s, OP_LESSEQUAL) : %d\n", yytext, yylineno);
    //return OP_LESSEQUAL;
}
{OP_GREATER} {
    if (show_info) 
        printf("(%s, OP_GREATER) : %d\n", yytext, yylineno);
    //return OP_GREATER;
}
{OP_GREATEREQUAL} {
    if (show_info) 
        printf("(%s, OP_GREATEREQUAL) : %d\n", yytext, yylineno);
    //return OP_GREATEREQUAL;
}
{OP_ASSGIN} {
    if (show_info) 
        printf("(%s, OP_ASSGIN) : %d\n", yytext, yylineno);
    //return OP_ASSGIN;
}
{OP_EQUAL} {
    if (show_info) 
        printf("(%s, OP_EQUAL) : %d\n", yytext, yylineno);
    //return OP_EQUAL;
}
{OP_NOTEQUAL} {
    if (show_info) 
        printf("(%s, OP_NOTEQUAL) : %d\n", yytext, yylineno);
    //return OP_NOTEQUAL;
}
{OP_AND} {
    if (show_info) 
        printf("(%s, OP_AND) : %d\n", yytext, yylineno);
    //return OP_AND;
}
{OP_OR} {
    if (show_info) 
        printf("(%s, OP_OR) : %d\n", yytext, yylineno);
    //return OP_OR;
}
{OP_NOT} {
    if (show_info) 
        printf("(%s, OP_NOT) : %d\n", yytext, yylineno);
    //return OP_NOT;
}
{OP_SEM} {
    if (show_info) 
        printf("(%s, OP_SEM) : %d\n", yytext, yylineno);
    //return OP_SEM;
}
{OP_COMMA} {
    if (show_info) 
        printf("(%s, OP_COMMA) : %d\n", yytext, yylineno);
    //return OP_COMMA;
}
{OP_DOT} {
    if (show_info) 
        printf("(%s, OP_DOT) : %d\n", yytext, yylineno);
    //return OP_DOT;
}
{OP_LBRACKET} {
    if (show_info) 
        printf("(%s, OP_LBRACKET) : %d\n", yytext, yylineno);
    //return OP_LBRACKET;
}
{OP_RBRACKET} {
    if (show_info) 
        printf("(%s, OP_RBRACKET) : %d\n", yytext, yylineno);
    //return OP_RBRACKET;
}
{OP_LPARENTHESIS} {
    if (show_info) 
        printf("(%s, OP_LPARENTHESIS) : %d\n", yytext, yylineno);
    //return OP_LPARENTHESIS;
}
{OP_RPARENTHESIS} {
    if (show_info) 
        printf("(%s, OP_RPARENTHESIS) : %d\n", yytext, yylineno);
    //return OP_RPARENTHESIS;
}
{OP_LBRACE} {
    if (show_info) 
        printf("(%s, OP_LBRACE) : %d\n", yytext, yylineno);
    //return OP_LBRACE;
}
{OP_RBRACE} {
    if (show_info) 
        printf("(%s, OP_RBRACE) : %d\n", yytext, yylineno);
    //return OP_RBRACE;
}

{COMMENT} {
    if (show_info) 
        printf("(%s, COMMENT) : %d\n", yytext, yylineno);
    //return COMMENT;
}
{BLANK} {
    // if (show_info) 
        // printf("(%s, BLANK) : %d\n", yytext, yylineno);
    //return BLANK;
}
{ENTER} {
    // if (show_info) 
        // printf("(ENTER) : %d\n", yylineno);
    //return ENTER;
}
{INDENTIFIER} {
    if (show_info) 
        printf("(%s, INDENTIFIER) : %d\n", yytext, yylineno);
    //return INDENTIFIER;
}
{WRONGSTRING} {
    printf("Error: %s at Line %d column",yytext, yylineno);
    // printf("Error type A at Line %d\n column %d: Missing \"\"\".\n", yylineno, yylloc.last_column); 
    exit(-1);
}
{WRONGIDENTIFIER} {
    printf("Error: %s at Line %d column",yytext, yylineno);
    // printf("Error type A at Line %d column %d: Wrong format of identifier.\n", yylineno, yylloc.first_column); 
    exit(-1);
}
{AERROR} {
    printf("Error: %s at Line %d column",yytext, yylineno);
    // printf("Error type A at Line %d column %d: Mysterious characters \"%s\".\n", yylineno, yylloc.first_column, yytext); 
    exit(-1); 
}


%%
