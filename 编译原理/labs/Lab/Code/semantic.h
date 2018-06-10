#ifndef SEMANTIC_H_
#define SEMANTIC_H_

#include "syntax.tab.h"
#include "grammarTree.h"
#include "type.h"

extern void semanticAnalyse(GrammarTree root);
extern void parseProgram(GrammarTree program);
extern void parseExtDefList(GrammarTree ext_def_list);
extern void parseExtDef(GrammarTree ext_def);
extern void parseExtDecList(GrammarTree ext_dec_list);

extern TypeP parseSpecifier(GrammarTree specifier);

extern TypeP parseVarDec(GrammarTree var_dec); 

extern TypeP parseFunDec(GrammarTree fun_dec, TypeP return_type);

#endif