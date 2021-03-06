%locations 
%{
#include "stdio.h"
#include "string.h"
#include "stdbool.h"
#include "stdarg.h"
#include "stdlib.h"
#include "lex.yy.c"
#include "grammarTree.h"
#include "semantic.h"
#include "symbolTable.h"

void yyerror(const char* fmt, ...);
int print_grammar_tree;
// yydebug = 1;
%}
/*Declare tokens*/
%error-verbose
%union {
    GrammarTree grammar_node;
}

/*Define priority*/
%right 	ASSIGNOP
%left 	OR
%left 	AND
%left 	RELOP
%left 	MINUS PLUS
%left 	DIV STAR
%right 	NOT
%left	DOT
%left 	LB RB
%left 	LP RP

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%token INT_TYPE FLOAT_TYPE

%token <grammar_node> INT 
%token <grammar_node> FLOAT 
%token <grammar_node> ID TYPE
%token <grammar_node> SEMI COMMA ASSIGNOP RELOP
%token <grammar_node> PLUS MINUS STAR DIV AND OR NOT
%token <grammar_node> DOT LP RP LB RB LC RC
%token <grammar_node> STRUCT RETURN IF ELSE WHILE

%type <grammar_node> Program ExtDefList ExtDef ExtDecList;
%type <grammar_node> Specifier StructSpecifier OptTag Tag;
%type <grammar_node> VarDec FunDec VarList ParamDec;
%type <grammar_node> CompSt StmtList Stmt;
%type <grammar_node> DefList Def DecList Dec;
%type <grammar_node> Exp Args;

%% 
// High level definitions
Program : ExtDefList {
        $$ = newGrammarTreeNode("Program", 1, $1); 
        if (error_count==0) {
            if (print_grammar_tree){
                printf("\nNow print the grammar-tree of \"Grammar Analyzing\":\n");
                printf("__________________________________________________\n\n"); 
                traverseGrammerTree($$, 0);
                printf("__________________________________________________\n\n"); 
                printf("The grammar-tree of \"Grammar Analyzing\" is printed!\n\n"); 
                printf("Initialize symbol table\n");
            }
            initSymbolTable();
            printf("Start Semantic analyse");
		    semanticAnalyse($$);
        }
};
ExtDefList : ExtDef ExtDefList {$$ = newGrammarTreeNode("ExtDefList", 2, $1, $2); }
| {$$ = newGrammarTreeLeaf("Empty", -1); }
;
ExtDef : Specifier ExtDecList SEMI {$$ = newGrammarTreeNode("ExtDef", 3, $1, $2, $3); }
| Specifier SEMI {$$ = newGrammarTreeNode("ExtDef", 2, $1, $2); }
| Specifier FunDec CompSt {$$ = newGrammarTreeNode("ExtDef", 3, $1, $2, $3); }
| error SEMI {
    error_count++;

}
;
ExtDecList : VarDec {$$ = newGrammarTreeNode("ExtDecList", 1, $1); }
| VarDec COMMA ExtDecList {$$ = newGrammarTreeNode("ExtDecList", 3, $1, $2, $3); }
;

// Specifiers
Specifier : TYPE {$$ = newGrammarTreeNode("Specifier", 1, $1); }
| StructSpecifier {$$ = newGrammarTreeNode("Specifier", 1, $1); }
;
StructSpecifier : STRUCT OptTag LC DefList RC {$$ = newGrammarTreeNode("StructSpecifier", 5, $1, $2, $3, $4, $5); }
| STRUCT Tag {$$ = newGrammarTreeNode("StructSpecifier", 2, $1, $2);}
; 
OptTag : ID {$$ = newGrammarTreeNode("OptTag", 1, $1); }
| {$$ = newGrammarTreeLeaf("Empty", -1); }
;
Tag : ID {$$ = newGrammarTreeNode("Tag", 1, $1); }
;

// Declarators
VarDec : ID {$$ = newGrammarTreeNode("VarDec", 1, $1); }
| VarDec LB INT RB {$$ = newGrammarTreeNode("VarDec", 4, $1, $2, $3, $4); }
;
FunDec : ID LP VarList RP {$$ = newGrammarTreeNode("FunDec", 4, $1, $2, $3, $4); }
| ID LP RP {$$ = newGrammarTreeNode("FunDec", 3, $1, $2, $3); }
| error RP {error_count++;}
;
VarList : ParamDec COMMA VarList {$$ = newGrammarTreeNode("VarList", 3, $1, $2, $3); }
| ParamDec {$$ = newGrammarTreeNode("VarList", 1, $1); }
;
ParamDec : Specifier VarDec {$$ = newGrammarTreeNode("ParamDec", 2, $1, $2); }
| error COMMA { error_count++;}
| error RB {
    error_count++;
}
;

// Statements
CompSt : LC DefList StmtList RC {$$ = newGrammarTreeNode("CompSt", 4, $1, $2, $3, $4); }
| error RC { $$ = newGrammarTreeNode("CompSt", 1, $2); 
    fprintf(stderr, "error CompSt!!\n");
    error_count++;}
;
StmtList : Stmt StmtList {$$ = newGrammarTreeNode("StmtList", 2, $1, $2); }
| {$$ = newGrammarTreeLeaf("Empty", -1); }
;
Stmt : Exp SEMI  {$$ = newGrammarTreeNode("Stmt", 2, $1, $2); }
| CompSt  {$$ = newGrammarTreeNode("Stmt", 1, $1); }
| RETURN Exp SEMI   {$$ = newGrammarTreeNode("Stmt", 3, $1, $2, $3); }
| IF LP Exp RP Stmt  %prec LOWER_THAN_ELSE  {$$ = newGrammarTreeNode("Stmt", 5, $1, $2, $3, $4, $5); }
| IF LP Exp RP Stmt ELSE Stmt   {$$ = newGrammarTreeNode("Stmt", 7, $1, $2, $3, $4, $5, $6, $7); }
| WHILE LP Exp RP Stmt  {$$ = newGrammarTreeNode("Stmt", 5, $1, $2, $3, $4, $5); }
| error SEMI {$$ = newGrammarTreeNode("Stmt", 1, $2); 
    error_count++;}
; 

// Local Definitions
DefList : Def DefList {$$ = newGrammarTreeNode("DefList", 2, $1, $2); }
| {$$ = newGrammarTreeLeaf("Empty", -1); }
;
Def : Specifier DecList SEMI {$$ = newGrammarTreeNode("Def", 3, $1, $2, $3); }
| error SEMI { error_count++; }
;
DecList : Dec {$$ = newGrammarTreeNode("DecList", 1, $1); }
| Dec COMMA DecList {$$ = newGrammarTreeNode("DecList", 3, $1, $2, $3); }
;  
Dec : VarDec    {$$ = newGrammarTreeNode("Dec", 1, $1); }
| VarDec ASSIGNOP Exp   {$$ = newGrammarTreeNode("Dec", 3, $1, $2, $3); }
;

// Expressions
Exp : Exp ASSIGNOP Exp {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| Exp AND Exp   {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| Exp OR Exp    {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| Exp RELOP Exp {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| Exp PLUS Exp  {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| Exp MINUS Exp {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| Exp STAR Exp  {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| Exp DIV Exp   {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| LP Exp RP     {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| MINUS Exp     {$$ = newGrammarTreeNode("Exp", 2, $1, $2); }
| NOT Exp       {$$ = newGrammarTreeNode("Exp", 2, $1, $2); }
| ID LP Args RP {$$ = newGrammarTreeNode("Exp", 4, $1, $2, $3, $4); }
| ID LP RP      {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| Exp LB Exp RB {$$ = newGrammarTreeNode("Exp", 4, $1, $2, $3, $4); }
| Exp DOT ID    {$$ = newGrammarTreeNode("Exp", 3, $1, $2, $3); }
| ID            {$$ = newGrammarTreeNode("Exp", 1, $1); }
| INT           {$$ = newGrammarTreeNode("Exp", 1, $1); }
| FLOAT         {$$ = newGrammarTreeNode("Exp", 1, $1); }
| error RP      {$$ = newGrammarTreeNode("Exp", 1, $2); 
    // fprintf(stderr, "error EXP!!\n");
    error_count++;}
| LP Exp error {
	error_count++;
}
| ID LP Args error {
	error_count++;
}
| ID LP error {
	error_count++;
}
| Exp LB Exp error {
	error_count++;
}
;        
Args : Exp COMMA Args   {$$ = newGrammarTreeNode("Args", 3, $1, $2, $3); }
| Exp   {$$ = newGrammarTreeNode("Args", 1, $1); }
;

%%
#include<stdarg.h>

void yyerror(const char* fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    fprintf(stderr, "Error type B at Line %d Column %d: ", yylineno, yylloc.first_column);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, ".\n");
}
