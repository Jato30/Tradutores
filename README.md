# Tradutores
Implementação de uma linguagem a partir de C e um compilador para ela (sem montador e ligador)



## Compilação

- Certifique-se que está no diretório raiz e que este se chama ./170052427/
- Utilize o comando make help para mais comandos
- Em caso de falha na permissão, digite chmod 777 -R ../170052427/
- Em caso de falha, compile utilizando:
- - bison -dv sintatico.y --report=all
	flex lexico.l
	gcc sintatico.tab.c lex.yy.c -o exec -lfl

## Execução

- Para executar digite: ./exec <teste/arquivo.c
	Note que "arquivo.c" são os arquivos na pasta ./teste/
