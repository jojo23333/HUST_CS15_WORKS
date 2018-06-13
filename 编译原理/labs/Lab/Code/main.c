#include <stdio.h>
#include "grammarTree.h"

int main(int argc, char** argv)
{
	error_count = 0;
	if (argc <= 1) return 1;
    if (argc > 1)
    {
        if (!(yyin = fopen(argv[1], "r")))
        {
            perror(argv[1]);
            return 1;
        }
    }
    // if (!(yyin = fopen("../Test/test2/B_2.c", "r")))
    // {
    //     perror(argv[1]);
    //     return 1;
    // }
	yyparse();
	return 0;
}