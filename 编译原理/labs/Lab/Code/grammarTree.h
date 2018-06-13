#ifndef _GRAMMARTREE_H
#define _GRAMMARTREE_H

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

int error_count;

extern char* yytext;
extern FILE* yyin;
extern int yylineno;
extern int yyparse();

typedef struct GrammarTreeNode
{
    int line;       // the number of its line
    char* name;     // the name of this grammar unit
    struct GrammarTreeNode* lchild;
    struct GrammarTreeNode* rchild;
    union           // the value of this grammar unit
    {
        int int_value;
        float float_value;
        char * string_value;
    };
} GrammarTreeNode;

typedef struct GrammarTreeNode* GrammarTree;

/* Create GrammarTree Leaf Nodes during the lexical analyse
 * name: the name of the grammar unit
 * line: the line where the the leaf unit lies
*/
GrammarTree newGrammarTreeLeaf(char* name, int line);


/* Create GrammerTree Node during grammer analyse
 * 
*/
GrammarTree newGrammarTreeNode(char* name, int num, ...);

/* Traverse GrammarTree Using Pre-Order
 * tree: the grammar tree
 * level: the number of the level
 */
void traverseGrammerTree(GrammarTree gmtree, int level);

#endif