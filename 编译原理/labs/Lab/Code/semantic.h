#ifndef SEMANTIC_H_
#define SEMANTIC_H_

#include <assert.h>
#include <stdbool.h>
#include "grammarTree.h"
#include "type.h"

extern void semanticAnalyse(GrammarTree root);
extern void parseProgram(GrammarTree program);
extern void parseExtDefList(GrammarTree ext_def_list);
extern void parseExtDef(GrammarTree ext_def);

extern TypeP parseSpecifier(GrammarTree specifier);

extern FieldListP parseDefList(GrammarTree def_list, bool instruct);

extern FieldListP parseDef(GrammarTree def, bool instruct);

extern FieldListP parseVarDec(GrammarTree var_dec, TypeP type, bool inStruct);

extern TypeP parseExp(GrammarTree root);

extern TypeP parseFunDec(GrammarTree root, TypeP lasttype);

extern void parseCompSt(GrammarTree root, TypeP returntype);

extern void parseStmt(GrammarTree root, TypeP returntype);

extern void parseExtDecList(GrammarTree root, TypeP type);

extern bool sameType(TypeP type1, TypeP type2);

#define ASSERT(x) assert((x)!=NULL) 

#endif