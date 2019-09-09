
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	//#include "hash.h"
	//Hash tab;
	int num_char = 0;
%}

PALAVRA-CHAVE	if|else|for|float|int|char|shape|point|return
LITERAL			"\"".*"\""
COMENT-LINHA	"//".*
COMENT-BLOCO	"/*"(.|\n)*"*/"
ID				({LETRA})+({LETRA}|{DIGITO}|"_")*
NUM				"-"?({DIGITO}+|({DIGITO}+"."{DIGITO}+"E"?{DIGITO}*))
LETRA			[a-zA-Z]
DIGITO			[0-9]


SEPARA-ARG		","
ACESSO-MEMB		"."|"->"
FIM-EXPRESS		";"
PRE-PROCESS		"#".*

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

{PALAVRA-CHAVE}		{printf("Palavra-chave: %s\n", yytext); num_char += strlen(yytext);}
{ID}				{printf("Identificador: %s\n", yytext); num_char += strlen(yytext);}
{NUM}				{printf("Numero: %s\n", yytext); num_char += strlen(yytext);}

{RELOP}				{printf("Operador Relacional: %s\n", yytext); num_char += strlen(yytext);}
{ATROP}				{printf("Operador Atribuicao: %s\n", yytext); num_char += strlen(yytext);}
{ADDOP}				{printf("Operador Adicao: %s\n", yytext); num_char += strlen(yytext);}
{MULOP}				{printf("Operador Multiplicacao: %s\n", yytext); num_char += strlen(yytext);}

{INI-PARAM}			{printf("Inicio de parametro: %s\n", yytext); num_char += strlen(yytext);}
{FIM-PARAM}			{printf("Fim de parametro: %s\n", yytext); num_char += strlen(yytext);}
{INI-INSTRUC}		{printf("Inicio de instrucao: %s\n", yytext); num_char += strlen(yytext);}
{FIM-INSTRUC}		{printf("Fim de instrucao: %s\n", yytext); num_char += strlen(yytext);}
{SEPARA-ARG}		{printf("Separador de argumento: %s\n", yytext); num_char += strlen(yytext);}
{ACESSO-MEMB}		{printf("Operador de acesso a membro: %s\n", yytext); num_char += strlen(yytext);}
{FIM-EXPRESS}		{printf("Fim de expressao: %s\n", yytext); num_char += strlen(yytext);}
{PRE-PROCESS}		{printf("Instrucao de pre-processamento: %s\n", yytext); num_char += strlen(yytext);}
{INI-SUBESCRIT}		{printf("Abre de colchetes: %s\n", yytext); num_char += strlen(yytext);}
{FIM-SUBESCRIT}		{printf("Fecha de Colchetes: %s\n", yytext); num_char += strlen(yytext);}

{LITERAL}			{printf("String constante: %s\n", yytext); num_char += strlen(yytext);}

{COMENT-LINHA}		{printf("Comentario!! Ignorando: %s\n", yytext);}
{COMENT-BLOCO}		{printf("Comentario!! Ignorando: %s\n", yytext);}



\n					{yylineno++; num_char = 0;}

[ \t\r]				;
.					printf("\t[ERRO] Caractere nao reconhecido: %s linha[%d:%d]\n", yytext, yylineno, num_char);


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

	return 0;
}



/* 
SEPARADOR		","|";"|"."
DELIMITADOR		"["|"]"|"("|")"|"{"|"}"

{SEPARADOR}			{printf("Separador: %s\n", yytext); num_char += strlen(yytext);}
{DELIMITADOR}		{printf("Delimitador: %s\n", yytext); num_char += strlen(yytext);}
*/
