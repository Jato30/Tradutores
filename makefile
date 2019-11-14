
#comando para remover arquivos
RM = rm -f
#comando para remover diretorios
RMDIR = rmdir -R
CD = cd
#comando para executar o make
MAKE = make


FLAGS = -lfl
DEBFLAGS = -W -Wall -ansi -pedantic -Wextra -ggdb -O0
PATH= ./
LIBS= $(wildcard $(PATH)lib/*.c)
BIN= $(PATH)bin/
OBJ= ./sintatico.tab.c ./lexico.yy.c
CC = gcc

BISON= bison
FLEX= flex
BFLAGS= -dv
BDEBFLAGS= --report=all


#Arquivos que devem ser compilados:
C_FILES= $(wildcard $(PATH)*.c)
FLEX_FILES= $(PATH)lexico.l
BISON_FILES= $(PATH)sintatico.y


#Nome do executável
EXEC = exec


all: $(EXEC)

$(EXEC): $(OBJ)
	$(CC) $(LIBS) $^ -o $@ $(FLAGS)

./sintatico.tab.c: $(BISON_FILES)
	$(BISON) $(BFLAGS) $^ $(BDEBFLAGS)

./lexico.yy.c: $(FLEX_FILES)
	$(FLEX) $^




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
