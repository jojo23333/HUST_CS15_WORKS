#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "type.h"

void semanticAnalyse(GrammarTree root) {
    if (root!=NULL) {
        parseProgram(root);
    }
}

void parseProgram(GrammarTree root){
    if (root->lchild != NULL) {
        parseExtDefList(root->lchild);
    }
}

void parseExtDefList(GrammarTree ext_def_list) {
    if (proext_def_listgram->lchild != NULL ) {
        parseExtDef(ext_def_list->lchild);
        GrammarTree child = ext_def_list->lchild->rchild;
        while (child != NULL) {
            parseExtDef(child);
            child = child->rchild;
        }
    }
}

void parseExtDef(GrammarTree ext_def) {
    GrammarTree specifier = ext_def->lchild;
    
    assert(specifier!=NULL);
    assert(specifier->rchild!=NULL);
    assert(specifier->rchild->name!=NULL);
    TypeP spe_type = parseSpecifier(specifier);

    char * name = specifier->rchild->name;
    // ExtDef --> Specifier ExtDecList SEMI
    if (!strcmp(name, "ExtDecList")){
        GrammarTree ext_dec_dist = specifier->rchild;
        parseExtDecList(ext_dec_dist);
    }
    // ExtDef --> Specifier SEMI
    else if (!strcmp(name, "SEMI")){
        return;
    }
    // ExtDef --> Specifier FunDec CompSt
    else if (!strcmp(name, "FunDec")){
        GrammarTree fun_dec = specifier->rchild;
        GrammarTree comp_st = fun_dec->rchild;
        TypeP fun_type = parseFunDec(fun_dec, spe_type);
        //TODO
    }else {
        debugInfo();
    }
}

//TODO


