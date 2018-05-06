/* File:  scanner.l
 * ----------------
 * Lex input file to generate the scanner for the compiler.
 */
%{

#include <string.h>
#include "scanner.h"
#include "errors.h"

// Control debug info
bool show_info = true;

/* Global variable: yylval
 * -----------------------
 * This global variable is how we get attribute information about the token
 * just scanned to the client. The scanner sets the global variable
 * appropriately and since it's global the client can just read it.  In the
 * future, this variable will be declared for us in the y.tab.c file
 * produced by Yacc, but for now, we declare it manually.
 */
YYSTYPE yylval;  // manually declared for pp1, later Yacc provides

/* Global variable: yylloc
 * -----------------------
 * This global variable is how we get position information about the token
 * just scanned to the client. (Operates similarly to yylval above)
 */
struct yyltype yylloc; // manually dclared for pp1, later Yacc provides

/* Macro: YY_USER_ACTION 
 * ---------------------
 * This flex built-in macro can be defined to provide an action which is
 * always executed prior to any matched rule's action. Basically, it is
 * a way of having a piece of code common to all actions factored out to
 * this routine.  We already defined it for you and left the empty
 * function DoBeforeEachAction ready for your use as needed. It will
 * be called once for each pattern scanned from the file, before
 * executing its action.
 */
static void DoBeforeEachAction(); 
#define YY_USER_ACTION DoBeforeEachAction();

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

%%             /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section. 
  */ 
KEY_BOOL {
    if (show_info) 
        printf("(%s, KEY_BOOL) : %d", yytext, yylineno);
    return KEY_BOOL;
}
KEY_INT {
    if (show_info) 
        printf("(%s, KEY_INT) : %d", yytext, yylineno);
    return KEY_INT;
}
KEY_STRING {
    if (show_info) 
        printf("(%s, KEY_STRING) : %d", yytext, yylineno);
    return KEY_STRING;
}
KEY_BREAK {
    if (show_info) 
        printf("(%s, KEY_BREAK) : %d", yytext, yylineno);
    return KEY_BREAK;
}
KEY_CLASS {
    if (show_info) 
        printf("(%s, KEY_CLASS) : %d", yytext, yylineno);
    return KEY_CLASS;
}
KEY_ELSE {
    if (show_info) 
        printf("(%s, KEY_ELSE) : %d", yytext, yylineno);
    return KEY_ELSE;
}
KEY_EXTENDS {
    if (show_info) 
        printf("(%s, KEY_EXTENDS) : %d", yytext, yylineno);
    return KEY_EXTENDS;
}
KEY_FOR {
    if (show_info) 
        printf("(%s, KEY_FOR) : %d", yytext, yylineno);
    return KEY_FOR;
}
KEY_IF {
    if (show_info) 
        printf("(%s, KEY_IF) : %d", yytext, yylineno);
    return KEY_IF;
}
KEY_NEW {
    if (show_info) 
        printf("(%s, KEY_NEW) : %d", yytext, yylineno);
    return KEY_NEW;
}
KEY_RETURN {
    if (show_info) 
        printf("(%s, KEY_RETURN) : %d", yytext, yylineno);
    return KEY_RETURN;
}
KEY_THIS  {
    if (show_info) 
        printf("(%s, KEY_THIS) : %d", yytext, yylineno);
    return KEY_THIS;
}
KEY_VOID {
    if (show_info) 
        printf("(%s, KEY_VOID) : %d", yytext, yylineno);
    return KEY_VOID;
}
KEY_WHILE {
    if (show_info) 
        printf("(%s, KEY_WHILE) : %d", yytext, yylineno);
    return KEY_WHILE;
}
KEY_STATIC {
    if (show_info) 
        printf("(%s, KEY_STATIC) : %d", yytext, yylineno);
    return KEY_STATIC;
}
KEY_PRINT {
    if (show_info) 
        printf("(%s, KEY_PRINT) : %d", yytext, yylineno);
    return KEY_PRINT;
}
KEY_READINTEGER {
    if (show_info) 
        printf("(%s, KEY_READINTEGER) : %d", yytext, yylineno);
    return KEY_READINTEGER;
}
KEY_READLINE {
    if (show_info) 
        printf("(%s, KEY_READLINE) : %d", yytext, yylineno);
    return KEY_READLINE;
}
KEY_INSTANCEOF {
    if (show_info) 
        printf("(%s, KEY_INSTANCEOF) : %d", yytext, yylineno);
    return KEY_INSTANCEOF;
}

CONSTANT_NULL {
    if (show_info) 
        printf("(%s, CONSTANT_NULL) : %d", yytext, yylineno);
    return CONSTANT_NULL;
}
CONSTANT_BOOL {
    if (show_info) 
        printf("(%s, CONSTANT_BOOL) : %d", yytext, yylineno);
    return CONSTANT_BOOL;
}
CONSTANT_HEXINT	{
    if (show_info) 
        printf("(%s, CONSTANT_HEXINT) : %d", yytext, yylineno);
    return CONSTANT_BOOL;
}
CONSTANT_INT {
    if (show_info) 
        printf("(%s, CONSTANT_INT) : %d", yytext, yylineno);
    return CONSTANT_BOOL;
}
CONSTANT_STRING {
    if (show_info) 
        printf("(%s, CONSTANT_STRING) : %d", yytext, yylineno);
    return CONSTANT_STRING;
}

OP_ADD {
    if (show_info) 
        printf("(%s, OP_ADD) : %d", yytext, yylineno);
    return OP_ADD;
}
OP_SUB {
    if (show_info) 
        printf("(%s, OP_SUB) : %d", yytext, yylineno);
    return OP_SUB;
}
OP_MUL {
    if (show_info) 
        printf("(%s, OP_MUL) : %d", yytext, yylineno);
    return OP_MUL;
}
OP_DIV {
    if (show_info) 
        printf("(%s, OP_DIV) : %d", yytext, yylineno);
    return OP_DIV;
}
OP_MOD {
    if (show_info) 
        printf("(%s, OP_MOD) : %d", yytext, yylineno);
    return OP_MOD;
}
OP_LESS {
    if (show_info) 
        printf("(%s, OP_LESS) : %d", yytext, yylineno);
    return OP_LESS;
}
OP_LESSEQUAL {
    if (show_info) 
        printf("(%s, OP_LESSEQUAL) : %d", yytext, yylineno);
    return OP_LESSEQUAL;
}
OP_GREATER {
    if (show_info) 
        printf("(%s, OP_GREATER) : %d", yytext, yylineno);
    return OP_GREATER;
}
OP_GREATEREQUAL {
    if (show_info) 
        printf("(%s, OP_GREATEREQUAL) : %d", yytext, yylineno);
    return OP_GREATEREQUAL;
}
OP_ASSGIN {
    if (show_info) 
        printf("(%s, OP_ASSGIN) : %d", yytext, yylineno);
    return OP_ASSGIN;
}
OP_EQUAL {
    if (show_info) 
        printf("(%s, OP_EQUAL) : %d", yytext, yylineno);
    return OP_EQUAL;
}
OP_NOTEQUAL {
    if (show_info) 
        printf("(%s, OP_NOTEQUAL) : %d", yytext, yylineno);
    return OP_NOTEQUAL;
}
OP_AND {
    if (show_info) 
        printf("(%s, OP_AND) : %d", yytext, yylineno);
    return OP_AND;
}
OP_OR {
    if (show_info) 
        printf("(%s, OP_OR) : %d", yytext, yylineno);
    return OP_OR;
}
OP_NOT {
    if (show_info) 
        printf("(%s, OP_NOT) : %d", yytext, yylineno);
    return OP_NOT;
}
OP_SEM {
    if (show_info) 
        printf("(%s, OP_SEM) : %d", yytext, yylineno);
    return OP_SEM;
}
OP_COMMA {
    if (show_info) 
        printf("(%s, OP_COMMA) : %d", yytext, yylineno);
    return OP_COMMA;
}
OP_DOT {
    if (show_info) 
        printf("(%s, OP_DOT) : %d", yytext, yylineno);
    return OP_DOT;
}
OP_LBRACKET {
    if (show_info) 
        printf("(%s, OP_LBRACKET) : %d", yytext, yylineno);
    return OP_LBRACKET;
}
OP_RBRACKET {
    if (show_info) 
        printf("(%s, OP_RBRACKET) : %d", yytext, yylineno);
    return OP_RBRACKET;
}
OP_LPARENTHESIS {
    if (show_info) 
        printf("(%s, OP_LPARENTHESIS) : %d", yytext, yylineno);
    return OP_LPARENTHESIS;
}
OP_RPARENTHESIS {
    if (show_info) 
        printf("(%s, OP_RPARENTHESIS) : %d", yytext, yylineno);
    return OP_RPARENTHESIS;
}
OP_LBRACE {
    if (show_info) 
        printf("(%s, OP_LBRACE) : %d", yytext, yylineno);
    return OP_LBRACE;
}
OP_RBRACE {
    if (show_info) 
        printf("(%s, OP_RBRACE) : %d", yytext, yylineno);
    return OP_RBRACE;
}

COMMENT {
    if (show_info) 
        printf("(%s, COMMENT) : %d", yytext, yylineno);
    return COMMENT;
}
BLANK {
    if (show_info) 
        printf("(%s, BLANK) : %d", yytext, yylineno);
    return BLANK;
}
ENTER {
    if (show_info) 
        printf("(%s, ENTER) : %d", yytext, yylineno);
    return ENTER;
}
INDENTIFIER {
    if (show_info) 
        printf("(%s, INDENTIFIER) : %d", yytext, yylineno);
    return INDENTIFIER;
}
. {
    printf("Error type A at Line %d: Mysterious characters \'%s\'\n", yylineno, yytext);
}

%%

/* Function: InitScanner
 * ---------------------
 * This function will be called before any calls to yylex().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the scanner (set global variables, configure starting state, etc.). One
 * thing it already does for you is assign the value of the global variable
 * yy_flex_debug that controls whether flex prints debugging information
 * about each token and what rule was matched. If set to false, no information
 * is printed. Setting it to true will give you a running trail that might
 * be helpful when debugging your scanner. Please be sure the variable is
 * set to false when submitting your final version.
 */
void InitScanner()
{
    PrintDebug("lex", "Initializing scanner");
    yy_flex_debug = false;
}


/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{
}
