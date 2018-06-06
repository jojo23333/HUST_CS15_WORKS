#ifndef _GRAMMARTREE_H
#define _GRAMMARTREE_H

#include<stdio.h>
#include<stdlib.h>
#include<stdarg.h>
#include<string.h>

int error_count;

extern char* yytext;
extern FILE* yyin;
extern int yylineno;
extern int yyparse();

typedef struct grammarTreeNode
{
    int line;       // the number of its line
    char* name;     // the name of this grammar unit
    struct grammarTreeNode* lchild;
    struct grammarTreeNode* rchild;
    union           // the value of this grammar unit
    {
        int int_value;
        float float_value;
        char * string_value;
    };
} grammarTreeNode;

typedef struct grammarTreeNode* grammarTree;

/* Create GrammarTree Leaf Nodes during the lexical analyse
 * name: the name of the grammar unit
 * line: the line where the the leaf unit lies
*/
grammarTree newGrammarTreeLeaf(char* name, int line);


/* Create GrammerTree Node during grammer analyse
 * 
*/
grammarTree newGrammarTreeNode(char* name, int num, ...);

/* Traverse GrammarTree Using Pre-Order
 * tree: the grammar tree
 * level: the number of the level
 */
void traverseGrammerTree(grammarTree gmtree, int level);

#endif