SCANNER := lex
SCANNER_PARAMS := lexica.l
PARSER := yacc
PARSER_PARAMS := -d sintatica_semantica.y
CFLAGS := -Wall -g -Wno-unused-function $(shell llvm-config --cflags)
LDFLAGS := -lLLVM-18 $(shell llvm-config --ldflags)

all: compile translate

compile:
	$(SCANNER) $(SCANNER_PARAMS)
	$(PARSER) $(PARSER_PARAMS)
	gcc -o glf y.tab.c lex.yy.c $(CFLAGS) $(LDFLAGS)

run: glf
	clear
	./glf teste.vh main.vh

debug: PARSER_PARAMS += -Wcounterexamples -Wconflicts-sr -Wconflicts-rr -Wcex -Wother
debug: all

translate: glf
	@echo "Executando o tradutor LLVM..."
	@if ./glf teste.vh main.vh; then \
	    echo "Tradução concluída com sucesso."; \
	else \
	    echo "Erro na tradução"; \
	    exit 1; \
	fi

clear:
	rm -f y.tab.c y.tab.h lex.yy.c glf output.ll
