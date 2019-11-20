

#comando para remover arquivos
RM = rm -f
#comando para remover diretorios
RMDIR = rmdir -R
CD = cd
#comando para executar o make
MAKE = make


BISON= bison
FLEX= flex


#Arquivos que devem ser compilados:
BIN= ./bin/
LIBS= $(wildcard ./lib/*.c)
C_FILES= $(wildcard ./*.c)
FLEX_FILES= ./lexico.l
BISON_FILES= ./sintatico.y
OBJ= ./sintatico.tab.c ./lex.yy.c

FLAGS= -lfl

#Debug flags
BDEBFLAGS= --report=all
DEBFLAGS= -ggdb -O0 -W -Wall -pedantic -Wextra #-ainsi

#Compilador
CC = gcc

#Nome do executável
EXEC = exec

all: $(BISON) $(FLEX) $(EXEC)

$(BISON): $(BISON_FILES)
	$@ -dv $^ $(BDEBFLAGS)

$(FLEX): $(FLEX_FILES)
	$@ $^

$(EXEC): $(OBJ)
	$(CC) $(LIBS) $^ -o $@ $(FLAGS)


debug: FLAGS += $(DEBFLAGS)
debug: all

gdb: debug
gdb:
	gdb $(EXEC)

grind: 
	valgrind --track-origins=yes --leak-check=full --show-leak-kinds=all ./exec <teste/SemanticoCorreto1.c -g

clean:
	$(RM) $(EXEC)
	$(RM) $(OBJ)
	$(RM) sintatico.tab.h
	$(RM) sintatico.output
	$(RM) params

again: clean all

