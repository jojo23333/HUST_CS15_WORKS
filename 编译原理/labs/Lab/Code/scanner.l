%{
#include <string.h>
#include <stdio.h>
#include "grammarTree.h"
#include "syntax.tab.h"
	int show_info = 1;
	int yycolumn = 1;
	#define YY_USER_ACTION \
		yylloc.first_line = yylloc.last_line = yylineno; \
    	yylloc.first_column = yycolumn; \
    	yylloc.last_column = yycolumn + yyleng - 1; \
    	yycolumn += yyleng;
%}
%option yylineno

ID			    [a-zA-Z_][a-zA-Z0-9_]* 

SEMI	        ";"
COMMA		    ","
ASSIGNOP	    "="
RELOP		    ">"|"<"|">="|"<="|"=="|"!="
PLUS		    "+"
MINUS		    "-"
STAR		    "*"
DIV			    "/"
AND			    "&&"
OR			    "||"
NOT			    "!"
DOT			    "."
LP			    "("
RP			    ")"
LB			    "["
RB			    "]"
LC			    "{"
RC			    "}"

TYPE			"int"|"float"
STRUCT 			"struct"
RETURN			"return"
IF			    "if"
ELSE			"else"
WHILE			"while"


DECIMAL         	[0-9]
HEXDICIMAL      	{DECIMAL}|[a-fA-F]
CONSTANT_HEXINT		[+-]?0[Xx]{HEXDICIMAL}+
CONSTANT_OCTINT		[+-]?0[0-7]+
CONSTANT_INT    	[+-]?[1-9]{DECIMAL}*
CONSTANT_FLOAT  	[+-]?([0-9]*\.?[0-9]+|[0-9]+\.)
CONSTANT_FLOATE 	[+-]?[0-9]+\.?[0-9]*([eE]{CONSTANT_INT})

COMMENT         	(\/\/.*)|(\/\*((\*[^\/]?)|[^\*]*)*\*\/)
BLANK           	" "|\t
ENTER           	\n
WRONGSTRING     	\"[^\"\n]*$
WRONGIDENTIFIER 	[0-9][a-zA-Z0-9_]* 
AERROR          	.


%%             /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section. 
  */ 
{CONSTANT_INT} {
    if (show_info) 
        printf("(%s, CONSTANT_INT) : %d\n", yytext, yylineno);
	yylval.grammar_node = newGrammarTreeLeaf("CONSTANT_INT",yylineno);
    return INT;
}
{CONSTANT_OCTINT} {
    if (show_info) 
        printf("(%s, CONSTANT_OCTINT) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("CONSTANT_OCTINT",yylineno);
    return INT;
}
{CONSTANT_HEXINT} {
    if (show_info) 
        printf("(%s, CONSTANT_HEXINT) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("CONSTANT_HEXINT",yylineno);
    return INT;
}
{CONSTANT_FLOAT} {
    if (show_info) 
        printf("(%s, CONSTANT_FLOAT) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("CONSTANT_FLOAT",yylineno);
    return FLOAT;
}
{CONSTANT_FLOATE} {
    if (show_info) 
        printf("(%s, CONSTANT_FLOATE) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("CONSTANT_FLOATE",yylineno);
    return FLOAT;
}

{SEMI} {
    if (show_info) 
        printf("(%s, SEMI) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("SEMI",yylineno);
    return SEMI;
}
{COMMA} {
    if (show_info) 
        printf("(%s, COMMA) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("COMMA",yylineno);
    return COMMA;
}
{ASSIGNOP} {
    if (show_info) 
        printf("(%s, ASSIGNOP) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("ASSIGNOP",yylineno);
    return ASSIGNOP;
}
{RELOP} {
    if (show_info) 
        printf("(%s, RELOP) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("RELOP",yylineno);
    return RELOP;
}
{PLUS} {
    if (show_info) 
        printf("(%s, PLUS) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("PLUS",yylineno);
    return PLUS;
}
{MINUS} {
    if (show_info) 
        printf("(%s, MINUS) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("MINUS",yylineno);
	return MINUS;
}
{STAR} {
    if (show_info) 
        printf("(%s, STAR) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("STAR",yylineno);
    return STAR;
}
{DIV} {
    if (show_info) 
        printf("(%s, DIV) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("DIV",yylineno);
    return DIV;
}
{AND} {
    if (show_info) 
        printf("(%s, AND) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("AND",yylineno);
    return AND;
}
{OR} {
    if (show_info) 
        printf("(%s, OR) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("OR",yylineno);
    return OR;
}
{NOT} {
    if (show_info) 
        printf("(%s, NOT) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("NOT",yylineno);
    return NOT;
}
{DOT} {
    if (show_info) 
        printf("(%s, DOT) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("DOT",yylineno);
    return DOT;
}

{TYPE} {
    if (show_info) 
        printf("(%s, TYPE) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("TYPE",yylineno);
    return TYPE;
}
{LP} {
    if (show_info) 
        printf("(%s, LP) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("LP",yylineno);
    return LP;
}
{RP} {
    if (show_info) 
        printf("(%s, RP) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("RP",yylineno);
    return RP;
}
{LB} {
    if (show_info) 
        printf("(%s, LB) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("LB",yylineno);
    return LB;
}
{RB} {
    if (show_info) 
        printf("(%s, RB) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("RB",yylineno);
    return RB;
}
{LC} {
    if (show_info) 
        printf("(%s, LC) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("LC",yylineno);
    return LC;
}
{RC} {
    if (show_info) 
        printf("(%s, RC) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("RC",yylineno);
    return RC;
}
{STRUCT} {
    if (show_info) 
        printf("(%s, struct) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("STRUCT",yylineno);
    return STRUCT;
}
{RETURN} {
    if (show_info) 
        printf("(%s, return) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("RETURN",yylineno);
    return RETURN;
}
{IF} {
    if (show_info) 
        printf("(%s, if) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("IF",yylineno);
    return IF;
}
{ELSE} {
    if (show_info) 
        printf("(%s, else) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("ELSE",yylineno);
    return ELSE;
}
{WHILE} {
    if (show_info) 
        printf("(%s, while) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("WHILE",yylineno);
    return WHILE;
}
{ID} {
    if (show_info) 
        printf("(%s, ID) : %d\n", yytext, yylineno);
    yylval.grammar_node = newGrammarTreeLeaf("ID",yylineno);
    return ID;
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
	yycolumn = 1;
    //return ENTER;
}
{WRONGIDENTIFIER} {
    //printf("Wrong Identifier %s at Line %d column",yytext, yylineno);
    printf("Error type A at Line %d column %d: Wrong format of identifier.\n", yylineno, yylloc.first_column); 
    exit(-1);
}
{AERROR} {
    //printf("Error: %s at Line %d column",yytext, yylineno);
    printf("Error type A at Line %d column %d: Mysterious characters \"%s\".\n", yylineno, yylloc.first_column, yytext); 
    exit(-1);
}


%%
