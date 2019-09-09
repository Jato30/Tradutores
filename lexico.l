
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "TabSimbolo.h"
	//#include "sintatico.tab.h"
	//#include "hash.h"
	//Hash tab;
	int num_char = 0;
	int erro = 0;
	Simbolo tabela;
%}

PALAVRA-CHAVE	if|else|for|float|int|char|shape|point|return
LITERAL			"\"".*"\""
COMENT-LINHA	"//".*
COMENT-BLOCO	"/*"(.|\n)*"*/"
LETRA			[a-zA-Z]
DIGITO			[0-9]
CHAR			"\'"."\'"

INT				{DIGITO}+
FLOAT			{INT}"."{DIGITO}+"E"?{DIGITO}*
NUM				{INT}|{FLOAT}
ID				({LETRA})+({LETRA}|{DIGITO}|"_")*
PARAMOP			{INI-PARAM}{FIM-PARAM}


SEPARA-ARG		","
ACESSO-MEMB		"."|"->"
FIM-EXPRESS		";"

INI-SUBESCRIT	"["
FIM-SUBESCRIT	"]"
INI-PARAM		"("
FIM-PARAM		")"
INI-INSTRUC		"{"
FIM-INSTRUC		"}"


RELOP			"<"|">"|"<="|">="|"=="|"!="|"!"
ATROP			"="|"+="|"-="|"*="|"/="|"%="
ADDOP			"+"|"-"
MULOP			"*"|"/"


%%

{PALAVRA-CHAVE}		{printf("Palavra-chave: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{ID}				{printf("Identificador: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{INT}				{printf("Inteiro: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{FLOAT}				{printf("Float: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{CHAR}				{printf("Char: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}

{RELOP}				{printf("Operador Relacional: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{ATROP}				{printf("Operador Atribuicao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{ADDOP}				{printf("Operador Adicao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{MULOP}				{printf("Operador Multiplicacao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}

{INI-PARAM}			{printf("Inicio de parametro: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{FIM-PARAM}			{printf("Fim de parametro: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{INI-INSTRUC}		{printf("Inicio de instrucao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{FIM-INSTRUC}		{printf("Fim de instrucao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{SEPARA-ARG}		{printf("Separador de argumento: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{ACESSO-MEMB}		{printf("Operador de acesso a membro: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{FIM-EXPRESS}		{printf("Fim de expressao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}

{INI-SUBESCRIT}		{printf("Abre de colchetes: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}
{FIM-SUBESCRIT}		{printf("Fecha de Colchetes: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}

{LITERAL}			{printf("String constante: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext)}


{COMENT-LINHA}		{printf("Comentario!! Ignorando: %s\n", yytext);}
{COMENT-BLOCO}		{printf("Comentario!! Ignorando: %s\n", yytext);}

\n					{yylineno++; num_char = 0;}

[ \t\r]				;
.					{printf("\t[ERRO] Caractere nao reconhecido: %s linha[%d:%d]\n", yytext, yylineno, num_char); erro++;}


%%

int yywrap(){
	return 1;
}

// PARA COMPILAR SEM MAIN, UTILIZE A FLAG -ll (pegar entrada padrao)
int main(int argc, char** argv){

	if(argc > 1){
		yyin = fopen( argv[1], "r");
	}
	else{
		yyin = stdin;
	}

	//InicializaHash(tab);
	yylex();

	printf("\nNumero total de linhas: %d\n", yylineno);
	if(erro > 0){
		printf("Total de erros encontrados: %d\n", erro);
	}

	return 0;
}



/* 
SEPARADOR		","|";"|"."
DELIMITADOR		"["|"]"|"("|")"|"{"|"}"
PRE-PROCESS		"#".*

{SEPARADOR}			{printf("Separador: %s\n", yytext); num_char += strlen(yytext);}
{DELIMITADOR}		{printf("Delimitador: %s\n", yytext); num_char += strlen(yytext);}
{PRE-PROCESS}		{
						printf("Instrucao de pre-processamento: %s\n", yytext);
						num_char += strlen(yytext);
						return PRE-PROCESS;
					}
*/
