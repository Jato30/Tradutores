# Tradutores
Implementação de uma linguagem a partir de C e um compilador para ela (sem montador e ligador)



## Compilação

- Certifique-se que está no diretório raiz
- Utilize o comando make help para mais comandos

- Comandos:
- - make all
- - make gdb
- - make clean
- - make again (o mesmo de usar make clean seguido de make all)

- Em caso de falha, compile utilizando:
- - bison -dv sintatico.y --report=all
- - flex lexico.l
- - gcc ./lib/TabSimbolo.c sintatico.tab.c lex.yy.c -o exec -lfl

## Execução

- Para executar digite: ./exec <teste/arquivo.c
	Note que "arquivo.c" são os arquivos na pasta ./teste/
