SCANNER := lex
SCANNER_PARAMS := lexica.l
PARSER := yacc
PARSER_PARAMS := -d sintatica_semantica.y

all: compile translate

compile:
		$(SCANNER) $(SCANNER_PARAMS)
		$(PARSER) $(PARSER_PARAMS)
		gcc -o glf y.tab.c -ll

run: 	glf
		clear
		compile
		translate

debug:	PARSER_PARAMS += -Wcounterexamples -Wconflicts-sr -Wconflicts-rr -Wcex -Wother
debug: 	all

translate: glf
		./glf  teste.vh main.vh

clear:
	rm y.tab.c
	rm y.tab.h
	rm lex.yy.c
	rm glf