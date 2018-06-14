#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "semantic.h"
#include "symbolTable.h"
#include "syntax.tab.h"

int tab = 0;
int debug = 0;
#define make_tab {for(int i=0; i<tab; i++) putchar(' '); tab+=2;}

void semanticAnalyse(GrammarTree root) 
{
	if (debug) {
		make_tab;
		printf("semanticAnalyse\n");
	}
    if (root!=NULL) {
        parseProgram(root);
    }
}

void parseProgram(GrammarTree root)
{
	if (debug) { make_tab;
	printf("parseProgram\n");
	}

    if (root->lchild != NULL) {
        parseExtDefList(root->lchild);
    }
	tab-=2; return;
}

void parseExtDefList(GrammarTree ext_def_list) 
{
	if (debug) { make_tab;
    printf("parseExtDefList\n");
	}

    if (!strcmp(ext_def_list->name, "Empty")) {
        tab-=2; return;
	}
    if (!strcmp(ext_def_list->lchild->name, "ExtDef")) {
        parseExtDef(ext_def_list->lchild);
        GrammarTree child = ext_def_list->lchild->rchild;
        parseExtDefList(child);
    }
	tab-=2; return;
}

void parseExtDef(GrammarTree ext_def) 
{
	if (debug) { make_tab;
	printf("parseExtDef\n");
	}

    GrammarTree specifier = ext_def->lchild;
    
    assert(specifier!=NULL);
    assert(specifier->rchild!=NULL);
    assert(specifier->rchild->name!=NULL);
    TypeP spe_type = parseSpecifier(specifier);

    char * name = specifier->rchild->name;
    // ExtDef --> Specifier ExtDecList SEMI
    if (!strcmp(name, "ExtDecList")){
        GrammarTree ext_dec_dist = specifier->rchild;
        parseExtDecList(ext_dec_dist, spe_type);
    }
    // ExtDef --> Specifier SEMI
    else if (!strcmp(name, "SEMI")){
        tab-=2; return;
    }
    // ExtDef --> Specifier FunDec CompSt
    else if (!strcmp(name, "FunDec")){
        GrammarTree fun_dec = specifier->rchild;
        GrammarTree comp_st = fun_dec->rchild;
        TypeP type = parseFunDec(fun_dec, spe_type);

		if(type == NULL){
			tab-=2; return;
		}
		TableNode* temp_node = searchSymbolTable(type->u.structure->name);
		if(temp_node != NULL)
		{
			printf("Error type 4 at Line %d: Redefined function \"%s\".\n", fun_dec->line, temp_node->name);
			tab-=2; return;
		}
		else
		{
			insertSymbolTable(type->u.structure->name, type);
			parseCompSt(comp_st, spe_type);
		}
        
    }else {
        ;//debugInfo();
    }
	tab-=2; return;
}

// void parseExtDecList(GrammarTree ext_dec_list, TypeP type) 
// {
//     assert(ext_dec_list != NULL);
//     assert(ext_dec_list->lchild != NULL);

//     GrammarTree var_dec = ext_dec_list->lchild;
//     if (var_dec->rchild == NULL)
//         parseVarDec(var_dec, type, false);
//     else {
//         parseVarDec(var_dec, type, false);
        
//         assert(var_dec->rchild!=NULL && var_dec->rchild->rchild!=NULL);
//         parseExtDecList(var_dec->rchild->rchild);
//     }
// }

TypeP parseSpecifier(GrammarTree specifier) 
{
	if (debug) { make_tab;
	printf("parseSpecifier\n");
	}
	
    assert(specifier!=NULL && specifier->lchild!=NULL);

    GrammarTree child = specifier->lchild;
    // Specifier --> TYPE
    if (!strcmp(child->name, "TYPE")) {
        TypeP type = (TypeP)malloc(sizeof(Type_));
        type->kind = BASIC;
        if (!strcmp(child->string_value, "int")) {
            type->u.basic = INT;
        }
        else if (!strcmp(child->string_value, "float")) {
            type->u.basic = FLOAT;
        }
        tab-=2; return type;
    }
    // Specifier --> StructSpecifier
    else if(strcmp(child->name, "StructSpecifier")==0){
        char * struct_name = NULL;
        TypeP type = NULL;
        
        child = child->lchild;
        assert(child!=NULL && child->rchild!=NULL);
        child = child->rchild;

        // StructSpecifier --> STRUCT OptTag LC DefList RC
        if (!strcmp(child->name, "OptTag") || !strcmp(child->name, "Empty")) {	
            // assert(child->rchild!=NULL && child->rchild->rchild!=NULL);
            
            if(strcmp(child->name, "OptTag")==0)
			{
				struct_name = child->lchild->string_value;
                // TODO: search for for predefined case
                // report error of duplicate define
				TableNode* temp_node = searchSymbolTable(struct_name);
				if(temp_node != NULL)
				{
					printf("Error type 16 at Line %d: Duplicated name \"%s\".\n", child->line, struct_name);
					tab-=2; return NULL;
				}
			}
			GrammarTree def_list = child->rchild->rchild;
			
			type = (TypeP)malloc(sizeof(Type_));
			type->u.structure = parseDefList(def_list, true);
            type->kind = STRUCTURE;
			if(struct_name != NULL)
				//TODO: insert struct info 
				insertSymbolTable(struct_name, type);
			tab-=2; return type;
        }
        // StructSpecifier --> STRUCT Tag
        else if (!strcmp(child->name, "Tag")) {
            child = child->lchild;
            struct_name = child->string_value;

            // TODO: search for predefined struct
            // report error of undefined and error type
			TableNode* temp_node = searchSymbolTable(struct_name);
			if(temp_node == NULL)
			{
				printf("Error type 17 at Line %d: Undefined structure \"%s\".\n", child->line, child->string_value);
				tab-=2; return NULL;
			}	
			else if(temp_node->type->kind != STRUCTURE)
			{
				printf("Error type X at line %d: \"%s\" is not a struct.\n", child->line, child->string_value);
				tab-=2; return NULL;
			}
			else
			{
				tab-=2; return temp_node->type;
			}
        }
		else {
			printf("Error in StructSpecifier\n");
			exit(-1);
		}
    }
	else {
		printf("Error in visitSpecifier\n");
		exit(-1);
	}
}
//TODO

FieldListP parseDefList(GrammarTree def_list, bool instruct)
{
	if (debug) { make_tab;
	printf("parseDefList\n");
	}
	
    FieldListP head = NULL, nxt_def = NULL, tmp_def;
    GrammarTree def = NULL;
    if(!strcmp(def_list->name, "Empty")){
        tab-=2; return head;
	}
    //DefList --> Def DefList | 
    while (strcmp(def_list->name, "Empty")!=0) {
        assert(def_list->lchild!=NULL && def_list->lchild->rchild!=NULL);
        def = def_list->lchild;
        def_list = def->rchild;
        // return of parsedef can be a linked list
        tmp_def = nxt_def = parseDef(def,instruct);
        while (nxt_def->tail!=NULL) nxt_def = nxt_def->tail;
        nxt_def->tail = head;
        head = tmp_def;
    }
    tab-=2; return head;
}


FieldListP parseDef(GrammarTree def, bool instruct)
{
	if (debug) { make_tab;
	printf("parseDef\n");
	}
	
    GrammarTree specifier, dec_list, dec;
    // Def --> Specifier DecList SEMI
    ASSERT(def);
    specifier = def->lchild;
    ASSERT(specifier);
    dec_list = specifier->rchild;

    TypeP type = parseSpecifier(specifier);
    // ASSERT(type);

    FieldListP field = NULL;
	//DecList --> Dec | Dec COMMA DecList
	dec = dec_list;
    ASSERT(dec);
	while(true)
	{
		//Dec --> VarDec | VarDec ASSIGNOP Exp
		dec = dec->lchild;
		GrammarTree varDec = dec->lchild;
		FieldListP result = parseVarDec(varDec, type, instruct);
		//Dec --> VarDec ASSIGNOP Exp
		if(varDec->rchild != NULL)
		{
			if(instruct == true)
			{
				printf("Error type 15 ar Line %d: Illegal initialization in structure.\n", varDec->line);
			}
			else
			{
				TypeP exptype = parseExp(varDec->rchild->rchild);
				if(sameType(type, exptype) == false)
				{
					printf("Error type 5 at Line %d: Type mismatched for assignment.\n", varDec->line);
				}
			}
		}
		if(result != NULL)
		{
			FieldListP newField = (FieldListP)malloc(sizeof(FieldList_));
			newField->name = result->name;
			newField->type = result->type;
			newField->tail = field;
			field = newField;
		}
		dec = dec->rchild;
		if(dec != NULL)
			dec = dec->rchild;
		else
			break;
	}
	tab-=2; return field;
}


//VarDec --> ID | VarDec LB INT RB
FieldListP parseVarDec(GrammarTree var_dec, TypeP type, bool inStruct)
{
	if (debug) { make_tab;
	printf("parseVarDec\n");
	}
	
	TypeP lasttype = type;
	GrammarTree child = var_dec->lchild;
	FieldListP result = (FieldListP)malloc(sizeof(FieldList_));
	GrammarTree next;
	// printf("child: %s\n",child->name);//,child->string_value);
	while(!strcmp(child->name, "VarDec"))
	{
		TypeP newtype = (TypeP)malloc(sizeof(Type_));
		newtype->kind = ARRAY;
		next = child->rchild->rchild;
		newtype->u.array.size = next->int_value;
		newtype->u.array.elem = lasttype;
		lasttype = newtype;
		// next = next->next;
		child = child->lchild;
	}
	// printf("ok");
	result->name = child->string_value;
	result->type = lasttype;
	result->tail = NULL;

	
	TableNode* temp_node = insertSymbolTable(result->name, result->type);
	// printf("Inserting variable %s\n",result->name);
	if(temp_node == NULL)
	{
		if(inStruct)
			printf("Error type 15 at Line %d: Redefined field \"%s\".\n", child->line, result->name);
		else
			printf("Error type 3 at Line %d: Redefined variable \"%s\".\n", child->line, result->name);
	}
	tab-=2; return result;
}


TypeP parseExp(GrammarTree root)
{
	if (debug) { make_tab;
	printf("parseExp\n");
	}

	GrammarTree child = root->lchild;
	if(strcmp(child->name, "Exp") == 0)
	{
		//Exp --> Exp ASSIGNOP Exp
		if(strcmp(child->rchild->name, "ASSIGNOP") == 0)
		{
			GrammarTree node = child->lchild;
			if(!((strcmp(node->name, "ID")==0 && node->rchild == NULL) || (strcmp(node->name, "Exp")==0 && strcmp(node->rchild->name, "DOT")==0) \
				|| (strcmp(node->name, "Exp")==0 && strcmp(node->rchild->name, "LB")==0 && strcmp(node->rchild->rchild->name, "Exp")==0)))
			{
				printf("Error type 6 at Line %d: The left-hand side of an assignment must be a variable.\n", child->line);
				tab-=2; return NULL;
			}
			TypeP type1 = parseExp(child);
			TypeP type2 = parseExp(child->rchild->rchild);
			if(sameType(type1,type2) == false)
			{
				printf("Error type 5 at Line %d: Type mismatched for assignment.\n", child->line);
				tab-=2; return NULL;
			}
			tab-=2; return type1;
		}
		//Exp --> Exp AND Exp | Exp OR Exp
		else if(strcmp(child->rchild->name, "AND") == 0 || strcmp(child->rchild->name, "OR") == 0)
		{
			TypeP type1 = parseExp(child);
			TypeP type2 = parseExp(child->rchild->rchild);
			if(!(sameType(type1, type2) && type1->kind==BASIC && type1->u.basic==INT))
			{
				printf("Error type 7 at Line %d: Type mismatched for operands.\n", child->line);
				tab-=2; return NULL;
			}
			tab-=2; return type1;
		}
		//Exp --> Exp RELOP Exp
		else if(strcmp(child->rchild->name, "RELOP") == 0)
		{
			TypeP type1 = parseExp(child);
			TypeP type2 = parseExp(child->rchild->rchild);
			if(!(sameType(type1, type2) && type1->kind==BASIC && (type1->u.basic==INT || type1->u.basic==FLOAT)))
			{
				printf("Error type 7 at Line %d: Type mismatched for operands.\n", child->line);
				tab-=2; return NULL;
			}
			TypeP newtype = (TypeP)malloc(sizeof(Type_));
			newtype->kind = BASIC;
			newtype->u.basic = INT;
			tab-=2; return newtype;
		}
		//Exp --> Exp PLUS Exp | Exp MINUS Exp | Exp STAR Exp | Exp DIV Exp
		else if(strcmp(child->rchild->name, "PLUS") == 0 || strcmp(child->rchild->name, "MINUS") == 0 \
			|| strcmp(child->rchild->name, "STAR") == 0 || strcmp(child->rchild->name, "DIV") == 0)
		{
			TypeP type1 = parseExp(child);
			TypeP type2 = parseExp(child->rchild->rchild);
			if(!(sameType(type1, type2) && type1->kind==BASIC && (type1->u.basic==INT || type1->u.basic==FLOAT)))
			{
				printf("Error type 7 at Line %d: Type mismatched for operands.\n", child->line);
				tab-=2; return NULL;
			}
			tab-=2; return type1;
		}
		//Exp --> Exp LB Exp RB
		else if(strcmp(child->rchild->name, "LB") == 0)
		{
			TypeP type1 = parseExp(child);
			if(type1 == NULL){
				tab-=2; return NULL;
			}
			else if(type1->kind != ARRAY)
			{
				printf("Error type 10 at Line %d: \"%s\" is not an array.\n", child->line, child->string_value);
				tab-=2; return NULL;
			}
			else
			{
				child = child->rchild->rchild;
				TypeP type2 = parseExp(child);
				if(type2 == NULL){
					tab-=2; return NULL;
				}
				else if(!(type2->kind == BASIC && type2->u.basic == INT))
				{
					printf("Error type 12 at Line %d: \"%s\" is not an integer.\n", child->line, child->string_value);
					tab-=2; return NULL;
				}
				else {
					tab-=2; return type1->u.array.elem;
				}
			}
		}
		//Exp --> Exp DOT ID
		else if(strcmp(child->rchild->name, "DOT") == 0)
		{
			TypeP type1 = parseExp(child);
			if(type1 == NULL) {
				tab-=2; return NULL;
			}
			else if(type1->kind != STRUCTURE)
			{
				printf("Error type 13 at Line %d: Illegal use of \".\".\n", child->line);
				tab-=2; return NULL;
			}
			else
			{
				child = child->rchild->rchild;
				FieldListP field = type1->u.structure;
				for(; field!=NULL; field=field->tail)
					if(strcmp(field->name, child->string_value) == 0)
						break;
				if(field == NULL)
				{
					printf("Error type 14 at Line %d: Non-existent field \"%s\".\n", child->line, child->string_value);
					tab-=2; return NULL;					
				}
				else
				{
					// printf("Field %s of type %d",field->name, field->type->kind);
					tab-=2; return field->type;
				}

			}
		}
		else
		{
			printf("Error in parseExp Exp\n");
			exit(-1);
		}

	}
	else if(strcmp(child->name, "LP") == 0)
	{
		if(strcmp(child->rchild->name, "Exp") == 0)
		{
			tab-=2; return parseExp(child->rchild);
		}
		else
		{
			printf("Error in parseExp LP\n");
			exit(-1);
		}
	}
	else if(strcmp(child->name, "MINUS") == 0)
	{
		if(strcmp(child->rchild->name, "Exp") == 0)
		{
			TypeP temp_type = parseExp(child->rchild);
			if(temp_type==NULL){
				tab-=2; return NULL;
			}
			if(temp_type->kind != BASIC)
			{
				printf("Error type 7 at Line %d: Type mismatched for operands.\n", child->line);
				tab-=2; return NULL;
			}
			tab-=2; return temp_type;
		}
		else
		{
			printf("Error in parseExp MINUS\n");
			exit(-1);
		}
	}
	else if(strcmp(child->name, "NOT") == 0)
	{
		if(strcmp(child->rchild->name, "Exp") == 0)
		{
			TypeP temp_type = parseExp(child->rchild);
			if(temp_type==NULL){
				tab-=2; return NULL;
			}
			if(temp_type->kind != BASIC || temp_type->u.basic != INT)
			{
				printf("Error type 7 at Line %d: Type mismatched for operands.\n", child->line);
				tab-=2; return NULL;
			}
			TypeP newtype = (TypeP)malloc(sizeof(Type_));
			newtype->kind = BASIC;
			newtype->u.basic = INT;
			tab-=2; return newtype;
		}
		else
		{
			printf("Error in parseExp NOT\n");
			exit(-1);
		}
	}
	else if(strcmp(child->name, "ID") == 0)
	{
		//Exp --> ID LP RP | ID LP Args RP
		if(child->rchild != NULL)
		{
			TableNode* temp_node = searchSymbolTable(child->string_value);
			if(temp_node == NULL)
			{
				printf("Error type 2 at Line %d: Undefined function \"%s\".\n", child->line, child->string_value);
				tab-=2; return NULL;
			}
			else if(temp_node->type->kind != FUNCTION)
			{
				printf("Error type 11 at Line %d: \"%s\" is not a function.\n", child->line, child->string_value);
				tab-=2; return NULL;
			}
			else
			{
				TypeP temp_type = temp_node->type;
				//Exp --> ID LP RP
				if(strcmp(child->rchild->rchild->name, "RP")==0)
				{
					if(temp_type->u.structure->tail == NULL)
					{
						tab-=2; return temp_type->u.structure->type;
					}
					else
					{
						printf("Error type 9 at Line %d: Too few arguments for function \"%s\".\n",child->line, child->string_value);
						tab-=2; return NULL;
					}
				}
				else
				{
					FieldListP args = temp_type->u.structure->tail;
					if(args == NULL)
					{
						printf("Error type 9 at Line %d: Too many arguments for function \"%s\".\n", child->line, child->string_value);
						tab-=2; return NULL;
					}
					char* function_name = child->string_value;
					for(child = child->rchild->rchild->lchild; ; )
					{
						TypeP child_type = parseExp(child);
						if(child_type == NULL){
							tab-=2; return NULL;
						}
						if(sameType(child_type, args->type) == false)
						{
							printf("Error type 9 at Line %d: Arguments type mismatch in function \"%s\".\n", child->line, function_name);
							tab-=2; return NULL;
						}
						args = args->tail;
						if(args == NULL && child->rchild != NULL)
						{
							printf("Error type 9 at Line %d: Too many arguments for function \"%s\".\n", child->line, function_name);
							tab-=2; return NULL;
						}
						if(args != NULL && child->rchild == NULL)
						{
							printf("Error type 9 at Line %d: Too feq arguments for function \"%s\".\n", child->line, function_name);
							tab-=2; return NULL;
						}
						if(args == NULL && child->rchild == NULL){
							tab-=2; return temp_node->type->u.structure->type;
						}
						child = child->rchild->rchild->lchild;
					}

				}
			}
		}
		//Exp --> ID
		else
		{
			TableNode* temp_node = searchSymbolTable(child->string_value);
			if(temp_node == NULL)
			{
				printf("Error type 1 at Line %d: Undefined variable \"%s\".\n", child->line, child->string_value);
				tab-=2; return NULL;
			}
			else
			{
				tab-=2; return temp_node->type;
			}
		}
	}
	else if(!strcmp(child->name, "CONSTANT_INT") || 
			!strcmp(child->name, "CONSTANT_OCTINT") ||
			!strcmp(child->name, "CONSTANT_HEXINT"))
	{
		TypeP newtype = (TypeP)malloc(sizeof(Type_));
		newtype->kind = BASIC;
		newtype->u.basic = INT;
		tab-=2; return newtype;
	}
	else if(!strcmp(child->name, "CONSTANT_FLOAT") || 
			!strcmp(child->name, "CONSTANT_FLOATE") )
	{
		TypeP newtype = (TypeP)malloc(sizeof(Type_));
		newtype->kind = BASIC;
		newtype->u.basic = FLOAT;
		tab-=2; return newtype;
	}
	else
	{
		printf("%s: ", child->name);
		printf("Error in parseExp\n");
		exit(-1);
	}
}


TypeP parseFunDec(GrammarTree root, TypeP lasttype)
{
	if (debug) { make_tab;
	printf("parseFunDec\n");
	}
	
	TypeP type = (TypeP)malloc(sizeof(Type_));
	GrammarTree child = root->lchild;
	type->kind = FUNCTION;
	type->u.structure = (FieldListP)malloc(sizeof(FieldList_));
	type->u.structure->name = child->string_value;
	type->u.structure->type = lasttype;
	FieldListP field = type->u.structure;
	child = child->rchild->rchild;
	//FunDec --> ID LP RP
	if(strcmp(child->name, "RP") == 0)
	{
		field->tail = NULL;
	}
	//FunDec --> ID LP VarList RP
	else
	{
		for(child = child->lchild; ; )
		{
			TypeP point = parseSpecifier(child->lchild);
			if(point != NULL)
			{
				FieldListP tempfield = parseVarDec(child->lchild->rchild, point, false);
				field->tail = tempfield;
				field = tempfield;
			}
			child = child->rchild;
			if(child == NULL)
				break;
			else
				child = child->rchild->lchild;
		}
	}
	tab-=2; return type;
}

//CompSt --> LC DefList StmtList RC
void parseCompSt(GrammarTree root, TypeP returntype)
{
	if (debug) { make_tab;
	printf("parseCompSt\n");
	}

	GrammarTree child = root->lchild->rchild;
	FieldListP head = parseDefList(child, false);
	child = child->rchild;
	while(true)
	{
		if(strcmp(child->name, "Empty") == 0)
			break;
		else
		{
			child = child->lchild;
			parseStmt(child, returntype);
			child = child->rchild;
		}
	}
}

void parseStmt(GrammarTree root, TypeP returntype)
{
	if (debug) { make_tab;
	printf("parseStmt\n");
	}

	GrammarTree child = root->lchild;
	//Stmt --> Exp SEMI
	if(strcmp(child->name, "Exp") == 0)
		parseExp(child);
	//Stmt --> CompSt
	else if(strcmp(child->name, "CompSt") == 0)
	{
		parseCompSt(child, returntype);
	}
	//Stmt --> RETURN Exp SEMI
	else if(strcmp(child->name, "RETURN") == 0)
	{
		TypeP exptype = parseExp(child->rchild);
		if(sameType(returntype, exptype) == false)
		{
			printf("Error type 8 at Line %d: Type mismatched for return.\n", child->line);
			printf("Expected type: %d Given type: %d\n",returntype->kind, exptype->kind);
			tab-=2; return;
		}
	}
	//Stmt --> IF LP Exp RP Stmt | IF LP Exp RP Stmt ELSE Stmt
	else if(strcmp(child->name, "IF") == 0)
	{
		child = child->rchild->rchild;
		TypeP point = parseExp(child);
		if(point==NULL){
			tab-=2; return;
		}
		if(!(point->kind==BASIC && point->u.basic==INT))
		{
			printf("Error type 7 at Line %d: Type mismatched for if.\n", child->line);
			tab-=2; return;
		}
		child = child->rchild->rchild;
		parseStmt(child, returntype);
		child = child->rchild;
		if(child != NULL)
			parseStmt(child, returntype);
	}
	//Stmt --> WHILE LP Exp RP Stmt
	else if(strcmp(child->name, "WHILE") == 0)
	{
		child = child->rchild->rchild;
		TypeP point = parseExp(child);
		if(point==NULL){
			return;
		}
		if(!(point->kind==BASIC && point->u.basic==INT))
		{
			printf("Error type 7 at Line %d: Type mismatched for while.\n",child->line);
			tab-=2; return;
		}
		child = child->rchild->rchild;
		parseStmt(child, returntype);
	}
	else
	{
		printf("Error in parseStmt\n");
		exit(-1);
	}
}

void parseExtDecList(GrammarTree root, TypeP type)
{
	if (debug) { make_tab;
	printf("parseExtDecList\n");
	}

	GrammarTree child = root->lchild;
	while(true)
	{
		parseVarDec(child, type, false);
		child = child->rchild;
		if(child == NULL)
			break;
		else
		{
			child = child->rchild->lchild;
		}
	}
}

bool sameType(TypeP type1, TypeP type2)
{
	if(type1 == NULL || type2 == NULL){
		return false;
	}	
	if(type1->kind == type2->kind)
	{
		if(type1->kind == BASIC)
		{
			if(type1->u.basic == type2->u.basic)
				return true;
			else
				return false;
		}
		else if(type1->kind == ARRAY)
			return sameType(type1->u.array.elem, type2->u.array.elem);
		else if(type1->kind == STRUCTURE)
		{
			FieldListP p1 = type1->u.structure;
			FieldListP p2 = type2->u.structure;
			while(p1 != NULL && p2 != NULL)
			{
				if(!sameType(p1->type, p1->type))
					return false;
				p1 = p1->tail;
				p2 = p2->tail;
			}
			if(p1 != NULL || p2 != NULL)
				return false;
			return true;
		}
		else if(type1->kind == FUNCTION)
		{
			FieldListP p1 = type1->u.structure;
			FieldListP p2 = type2->u.structure;
			while(p1 != NULL && p2 != NULL)
			{
				if(!sameType(p1->type, p2->type))
					return false;
				p1 = p1->tail;
				p2 = p2->tail;
			}
			if(p1 != NULL || p2 != NULL)
				return false;
			return true;
		}

	}
	else
		return false;
}