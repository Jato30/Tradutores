
#comando para remover arquivos
RM = rm -f
#comando para remover diretorios
RMDIR = rmdir -R
CD = cd
#comando para executar o make
MAKE = make


FLAGS = 
DEVFLAGS= -Wall -pedantic -Wextra
DEBFLAGS= -ggdb -O0
PATH= ../Tradutores/
LIBS= $(wildcard $(PATH)lib/*.c)
BIN= $(PATH)bin/


#Arquivos que devem ser compilados:
C_FILES= $(wildcard $(PATH)*.c)
FLEX_FILES= $(wildcard $(PATH)*.l)
BISON_FILES= $(wildcard $(PATH)*.y)


#Nome do executável
EXEC = exec


all:
	bison -dv sintatico.y --report=all
	flex lexico.l
	gcc $(LIBS) sintatico.tab.c lex.yy.c -o exec -lfl

gramatica:
	bison -dv sintatico.y --report=all

lexico:
	flex lexico.l




clean:
	$(RM) $(BIN)$(EXEC)
	$(RM) $(wildcard $(PATH)$(BIN)*.c)


again: clean
again: all

first: chmod 777 -R $(PATH)
first: all


help:
	@echo.
	@echo Available targets:
	@echo - all:      Builds the release version (default target)
	@echo - first:    Gives permission at the first time (or when added new files)
	@echo - debug:    Builds the debug version
	@echo - clean:    Clean compilation files and executable
	@echo - help:     Shows this help
	@echo.
