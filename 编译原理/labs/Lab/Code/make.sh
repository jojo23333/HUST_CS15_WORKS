flex -o ./lex.yy.c ./scanner.l
bison -o ./syntax.tab.c -d -v -t  ./syntax.y
gcc -g -ggdb ./symboTable.c ./main.c ./grammarTree.c ./semantic.c ./syntax.tab.c -lfl -ly -o parser
