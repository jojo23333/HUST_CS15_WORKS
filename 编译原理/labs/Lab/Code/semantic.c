#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "semantic.h"
#define ASSERT(x) assert((x)!=NULL) 

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
    
    assert(ext_def_list!=NULL);

    if (strcmp(ext_def_list->name, "Empty") == 0)
        return;
    if (ext_def_list->lchild != NULL ) {
        parseExtDef(ext_def_list->lchild);
        GrammarTree child = ext_def_list->lchild->rchild;
        parseExtDefList(child);
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
        if ()
        {
            
        }
        else
        {
            
        }
        
    }else {
        debugInfo();
    }
}

void parseExtDecList(GrammarTree ext_dec_list) {
    assert(ext_dec_list != NULL);
    assert(ext_dec_list->lchild != NULL);

    GrammarTree var_dec = ext_dec_list->lchild;
    if (var_dec->rchild == NULL)
        parseVarDec(var_dec);
    else {
        parseVarDec(var_dec);
        
        assert(var_dec->rchild!=NULL && var_dec->rchild->rchild!=NULL);
        parseExtDecList(var_dec->rchild->rchild);
    }
}

TypeP parseSpecifier(GrammarTree specifier) {
    assert(specifier!=NULL && specifier->lchild!=NULL);

    GrammarTree child = specifier->lchild;
    // Specifier --> TYPE
    if (!strcmp(child.name, "TYPE")) {
        TypeP type = (TypeP)malloc(sizeof(Type_));
        type->kind = BASIC;
        if (!strcmp(type.string_value, "int")) {
            type->u.basic = TYPE_INT;
        }
        else if (!strcmp(type.string_value, "float")) {
            type->u.basic = TYPE_FLOAT;
        }
        return type;
    }
    // Specifier --> StructSpecifier
    else {
        char * struct_name = NULL;
        TypeP type = NULL;
        
        child = child->lchild;
        assert(child!=NULL && child->rchild!=NULL);
        child = child->rchild;

        // StructSpecifier --> STRUCT OptTag LC DefList RC
        if (!strcmp(child.name, "OptTag") || !strcmp(child.name, "Empty")) {
            assert(child->rchild!=NULL && child->rchild->rchild!=NULL)
            
            if(strcmp(child->name, "OptTag")==0)
			{
				struct_name = child->lchild->string_value;
                // TODO: search for for predefined case
                // report error of duplicate define
			}
			GrammarTree def_list = child->rchild->rchild;
			
			type = (TypeP)malloc(sizeof(Type_));
			type->u.structure = parseDefList(def_list, true);
            type->kind = STRUCTURE;
			if(struct_name != NULL)
				//TODO: insert struct info 
                ;
			return type;
        }
        // StructSpecifier --> STRUCT Tag
        else if (!strcmp(child.name, "Tag")) {
            child = child->lchild;
            struct_name = child->name;

            // TODO: search for predefined struct
            // report error of undefined and error type
        }
    }
}
//TODO

FieldListP parseDefList(GrammarTree def_list, bool instruct){
    FieldListP head = NULL, nxt_def = NULL, tmp_def;
    GrammarTree def = NULL;
    if(!strcmp(def_list->name, "Empty"))
        return head;
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
    return head;
}


FieldListP parseDef(GrammarTree def, bool instruct){
    GrammarTree specifier, dec_list, dec;
    // Def --> Specifier DecList SEMI
    ASSERT(def);
    specifier = def->lchild;
    ASSERT(specifier);
    dec_list = specifier->rchild;

    TypeP type = parseSpecifier(specifier);
    ASSERT(type);

    FieldListP field = NULL;
	//DecList --> Dec | Dec COMMA DecList
	dec = dec_list->lchild;
    ASSERT(dec);
	while(true)
	{
		//Dec --> VarDec | VarDec ASSIGNOP Exp
		GrammarTree varDec = dec->lchild;
		FieldListP result = visitVarDec(varDec, type, inStruct);
		//Dec --> VarDec ASSIGNOP Exp
		if(varDec->rchild != NULL)
		{
			if(inStruct == true)
			{
				printf("Error type 15 ar Line %d: Illegal initialization in structure.\n", varDec->line);
			}
			else
			{
				TypeP exptype = visitExp(varDec->rchild->rchild);
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
		if(child != NULL)
			child = child->rchild->lchild;
		else
			break;
	}
	return field;
}




// TODO:
//VarDec --> ID | VarDec LB INT RB
FieldListP visitVarDec(TreeNode* root, TypeP type, bool inStruct)
{
	TypeP lasttype = type;
	TreeNode* child = root->firstChild;
	FieldListP result = (FieldListP)malloc(sizeof(FieldList_));
	TreeNode* next;
	while(strcmp(child->name, "ID") != 0)
	{
		TypeP newtype = (TypeP)malloc(sizeof(Type_));
		newtype->kind = ARRAY;
		next = child->next->next;
		newtype->u.array.size = atoi(next->data);
		newtype->u.array.elem = lasttype;
		lasttype = newtype;
		next = next->next;
		child = child->firstChild;
	}

	result->name = child->data;
	result->type = lasttype;
	result->tail = NULL;

	TableNode* temp_node = insertSymbolTable(result->name, result->type);
	if(temp_node == NULL)
	{
		if(inStruct)
			printf("Error type 15 at Line %d: Redefined field \"%s\".\n", child->lineno, result->name);
		else
			printf("Error type 3 at Line %d: Redefined variable \"%s\".\n", child->lineno, result->name);
	}
	return result;
}


// TODO: 
TypeP visitExp(TreeNode* root)
{
	TreeNode* child = root->firstChild;
	if(strcmp(child->name, "Exp") == 0)
	{
		//Exp --> Exp ASSIGNOP Exp
		if(strcmp(child->next->name, "ASSIGNOP") == 0)
		{
			TreeNode* node = child->firstChild;
			if(!((strcmp(node->name, "ID")==0 && node->next == NULL) || (strcmp(node->name, "Exp")==0 && strcmp(node->next->name, "DOT")==0) \
				|| (strcmp(node->name, "Exp")==0 && strcmp(node->next->name, "LB")==0 && strcmp(node->next->next->name, "Exp")==0)))
			{
				printf("Error type 6 at Line %d: The left-hand side of an assignment must be a variable.\n", child->lineno);
				return NULL;
			}
			TypeP type1 = visitExp(child);
			TypeP type2 = visitExp(child->next->next);
			if(sameType(type1,type2) == false)
			{
				printf("Error type 5 at Line %d: Type mismatched for assignment.\n", child->lineno);
				return NULL;
			}
			return type1;
		}
		//Exp --> Exp AND Exp | Exp OR Exp
		else if(strcmp(child->next->name, "AND") == 0 || strcmp(child->next->name, "OR") == 0)
		{
			TypeP type1 = visitExp(child);
			TypeP type2 = visitExp(child->next->next);
			if(!(sameType(type1, type2) && type1->kind==BASIC && type1->u.basic==INT))
			{
				printf("Error type 7 at Line %d: Type mismatched for operands.\n", child->lineno);
				return NULL;
			}
			return type1;
		}
		//Exp --> Exp RELOP Exp
		else if(strcmp(child->next->name, "RELOP") == 0)
		{
			TypeP type1 = visitExp(child);
			TypeP type2 = visitExp(child->next->next);
			if(!(sameType(type1, type2) && type1->kind==BASIC && (type1->u.basic==INT || type1->u.basic==FLOAT)))
			{
				printf("Error type 7 at Line %d: Type mismatched for operands.\n", child->lineno);
				return NULL;
			}
			TypeP newtype = (TypeP)malloc(sizeof(Type_));
			newtype->kind = BASIC;
			newtype->u.basic = INT;
			return newtype;
		}
		//Exp --> Exp PLUS Exp | Exp MINUS Exp | Exp STAR Exp | Exp DIV Exp
		else if(strcmp(child->next->name, "PLUS") == 0 || strcmp(child->next->name, "MINUS") == 0 \
			|| strcmp(child->next->name, "STAR") == 0 || strcmp(child->next->name, "DIV") == 0)
		{
			TypeP type1 = visitExp(child);
			TypeP type2 = visitExp(child->next->next);
			if(!(sameType(type1, type2) && type1->kind==BASIC && (type1->u.basic==INT || type1->u.basic==FLOAT)))
			{
				printf("Error type 7 at Line %d: Type mismatched for operands.\n", child->lineno);
				return NULL;
			}
			return type1;
		}
		//Exp --> Exp LB Exp RB
		else if(strcmp(child->next->name, "LB") == 0)
		{
			TypeP type1 = visitExp(child);
			if(type1 == NULL)
				return NULL;
			else if(type1->kind != ARRAY)
			{
				printf("Error type 10 at Line %d: \"%s\" is not an array.\n", child->lineno, child->data);
				return NULL;
			}
			else
			{
				child = child->next->next;
				TypeP type2 = visitExp(child);
				if(type2 == NULL)
					return NULL;
				else if(!(type2->kind == BASIC && type2->u.basic == INT))
				{
					printf("Error type 12 at Line %d: \"%s\" is not an integer.\n", child->lineno, child->data);
					return NULL;
				}
				else
					return type1->u.array.elem;
			}
		}
		//Exp --> Exp DOT ID
		else if(strcmp(child->next->name, "DOT") == 0)
		{
			TypeP type1 = visitExp(child);
			if(type1 == NULL)
				return NULL;
			else if(type1->kind != STRUCTURE)
			{
				printf("Error type 13 at Line %d: Illegal use of \".\".\n", child->lineno);
				return NULL;
			}
			else
			{
				child = child->next->next;
				FieldListP field = type1->u.structure;
				for(; field!=NULL; field=field->tail)
					if(strcmp(field->name, child->data) == 0)
						break;
				if(field == NULL)
				{
					printf("Error type 14 at Line %d: Non-existent field \"%s\".\n", child->lineno, child->data);
					return NULL;					
				}
				else
				{
					return field->type;
				}

			}
		}
		else
		{
			printf("Error in visitExp Exp\n");
			exit(-1);
		}

	}
	else if(strcmp(child->name, "LP") == 0)
	{
		if(strcmp(child->next->name, "Exp") == 0)
		{
			return visitExp(child->next);
		}
		else
		{
			printf("Error in visitExp LP\n");
			exit(-1);
		}
	}
	else if(strcmp(child->name, "MINUS") == 0)
	{
		if(strcmp(child->next->name, "Exp") == 0)
		{
			TypeP temp_type = visitExp(child->next);
			if(temp_type==NULL)
				return NULL;
			if(temp_type->kind != BASIC)
			{
				printf("Error type 7 at Line %d: Type mismatched for operands.\n", child->lineno);
				return NULL;
			}
			return temp_type;
		}
		else
		{
			printf("Error in visitExp MINUS\n");
			exit(-1);
		}
	}
	else if(strcmp(child->name, "NOT") == 0)
	{
		if(strcmp(child->next->name, "Exp") == 0)
		{
			TypeP temp_type = visitExp(child->next);
			if(temp_type==NULL)
				return NULL;
			if(temp_type->kind != BASIC || temp_type->u.basic != INT)
			{
				printf("Error type 7 at Line %d: Type mismatched for operands.\n", child->lineno);
				return NULL;
			}
			TypeP newtype = (TypeP)malloc(sizeof(Type_));
			newtype->kind = BASIC;
			newtype->u.basic = INT;
			return newtype;
		}
		else
		{
			printf("Error in visitExp NOT\n");
			exit(-1);
		}
	}
	else if(strcmp(child->name, "ID") == 0)
	{
		//Exp --> ID LP RP | ID LP Args RP
		if(child->next != NULL)
		{
			TableNode* temp_node = searchSymbolTable(child->data);
			if(temp_node == NULL)
			{
				printf("Error type 2 at Line %d: Undefined function \"%s\".\n", child->lineno, child->data);
				return NULL;
			}
			else if(temp_node->type->kind != FUNCTION)
			{
				printf("Error type 11 at Line %d: \"%s\" is not a function.\n", child->lineno, child->data);
				return NULL;
			}
			else
			{
				TypeP temp_type = temp_node->type;
				//Exp --> ID LP RP
				if(strcmp(child->next->next->name, "RP")==0)
				{
					if(temp_type->u.structure->tail == NULL)
					{
						return temp_type->u.structure->type;
					}
					else
					{
						printf("Error type 9 at Line %d: Too few arguments for function \"%s\".\n",child->lineno, child->data);
						return NULL;
					}
				}
				else
				{
					FieldListP args = temp_type->u.structure->tail;
					if(args == NULL)
					{
						printf("Error type 9 at Line %d: Too many arguments for function \"%s\".\n", child->lineno, child->data);
						return NULL;
					}
					char* function_name = child->data;
					for(child = child->next->next->firstChild; ; )
					{
						TypeP child_type = visitExp(child);
						if(child_type == NULL)
							return NULL;
						if(sameType(child_type, args->type) == false)
						{
							printf("Error type 9 at Line %d: Arguments type mismatch in function \"%s\".\n", child->lineno, function_name);
							return NULL;
						}
						args = args->tail;
						if(args == NULL && child->next != NULL)
						{
							printf("Error type 9 at Line %d: Too many arguments for function \"%s\".\n", child->lineno, function_name);
							return NULL;
						}
						if(args != NULL && child->next == NULL)
						{
							printf("Error type 9 at Line %d: Too feq arguments for function \"%s\".\n", child->lineno, function_name);
							return NULL;
						}
						if(args == NULL && child->next == NULL)
							return temp_node->type->u.structure->type;
						child = child->next->next->firstChild;
					}

				}
			}
		}
		//Exp --> ID
		else
		{
			TableNode* temp_node = searchSymbolTable(child->data);
			if(temp_node == NULL)
			{
				printf("Error type 1 at Line %d: Undefined variable \"%s\".\n", child->lineno, child->data);
				return NULL;
			}
			else
			{
				return temp_node->type;
			}
		}
	}
	else if(strcmp(child->name, "INT") == 0)
	{
		TypeP newtype = (TypeP)malloc(sizeof(Type_));
		newtype->kind = BASIC;
		newtype->u.basic = INT;
		return newtype;
	}
	else if(strcmp(child->name, "FLOAT") == 0)
	{
		TypeP newtype = (TypeP)malloc(sizeof(Type_));
		newtype->kind = BASIC;
		newtype->u.basic = FLOAT;
		return newtype;
	}
	else
	{
		printf("Error in visitExp\n");
		exit(-1);
	}
}
