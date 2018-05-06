%{
#include <stdio.h>
#include <stdlib.h>
%}
//Keywords
//KEY_WORD ["bool"|"break"|"class"|"else"|"extends"|"for"|"if"|"int"|"int"|"new"|\
//			 "null"|"return"|"string"|"this"|"void"|"while"|"static"|"Print"|"ReadInteger"|"ReadLine"|"instaceof"]

//Identifier
IDENTIFIER ([a-zA-Z][a-zA-Z0-9_]*)

//white
BLANK ([ \t\n]*)

//boolVal
BOOL_VAL = [true|false] 

//Constant
decimal	[0-9]
hexdecimal ({decimal}|[a-fA-F])+

HEX_INT_CONSTANT 0[Xx]{HEX_decimal}+
INT_CONSTANT	{decimal}+
STRING_CONSTANT [\"[^"\n]*]\"]

//Operator
OPERATOR [+-*/%=<>=!;,.[](){}| <= | >= | && | \|\| | == | != ]

%%

%%
