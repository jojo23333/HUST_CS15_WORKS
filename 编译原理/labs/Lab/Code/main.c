#include <stdio.h>
#include "grammarTree.h"
extern int debug;
extern int show_info;
extern int print_grammar_tree;
extern int print_symbol;

int main(int argc, char** argv)
{
    show_info = 0;
	error_count = 0;
    print_grammar_tree = 0;
    print_symbol = 0;
    debug = 0;
	if (argc <= 1) return 1;
    if (argc > 1)
    {
        if (!(yyin = fopen(argv[1], "r")))
        {
            perror(argv[1]);
            return 1;
        }
    }
    int pnt = 2;
    while ( pnt < argc ) {
        if (!strcmp(argv[pnt], "--debug") || !strcmp(argv[pnt], "-d")) {
            debug = 1;
        }
        else if (!strcmp(argv[pnt], "--tree") || !strcmp(argv[pnt], "-t")) {
            print_grammar_tree = 1;
        }
        else if (!strcmp(argv[pnt], "--symbol") || !strcmp(argv[pnt], "-s") ){
            print_symbol = 1;
        }
        else if (!strcmp(argv[pnt], "--lexcial") || !strcmp(argv[pnt], "-l")) {
            show_info = 1;
        }
        pnt++;
    }
    // if (!(yyin = fopen("../Test/test2/B_2.c", "r")))
    // {
    //     perror(argv[1]);
    //     return 1;
    // }
	yyparse();
	return 0;
}