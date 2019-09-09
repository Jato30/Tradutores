
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "sintatico.tab.h"
	//#include "hash.h"
	//Hash tab;
	int num_char = 0;
	int erro = 0;
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

{PALAVRA-CHAVE}		{
						printf("Palavra-chave: %s\n", yytext);
						num_char += strlen(yytext);
						return PALAVRA-CHAVE;
					}
{ID}				{
						printf("Identificador: %s\n", yytext);
						num_char += strlen(yytext);
						return ID;
					}
{NUM}				{
						printf("Numero: %s\n", yytext);
						num_char += strlen(yytext);
						return NUM;
					}

{RELOP}				{
						printf("Operador Relacional: %s\n", yytext);
						num_char += strlen(yytext);
						return RELOP;
					}
{ATROP}				{
						printf("Operador Atribuicao: %s\n", yytext);
						num_char += strlen(yytext)
						return ATROP;
					}
{ADDOP}				{
						printf("Operador Adicao: %s\n", yytext);
						num_char += strlen(yytext);
						return ADDOP;
					}
{MULOP}				{
						printf("Operador Multiplicacao: %s\n", yytext);
						num_char += strlen(yytext);
						return MULOP;
					}

{INI-PARAM}			{
						printf("Inicio de parametro: %s\n", yytext);
						num_char += strlen(yytext);
						return INI-PARAM;
					}
{FIM-PARAM}			{
						printf("Fim de parametro: %s\n", yytext);
						num_char += strlen(yytext);
						return FIM-PARAM;
					}
{INI-INSTRUC}		{
						printf("Inicio de instrucao: %s\n", yytext);
						num_char += strlen(yytext);
						return INI-INSTRUC;
					}
{FIM-INSTRUC}		{
						printf("Fim de instrucao: %s\n", yytext);
						num_char += strlen(yytext);
						return FIM-INSTRUC;
					}
{SEPARA-ARG}		{
						printf("Separador de argumento: %s\n", yytext)
						num_char += strlen(yytext);
						return SEPARA-ARG;
					}
{ACESSO-MEMB}		{
						printf("Operador de acesso a membro: %s\n", yytext);
						num_char += strlen(yytext);
						return ACESSO-MEMB;
					}
{FIM-EXPRESS}		{
						printf("Fim de expressao: %s\n", yytext);
						num_char += strlen(yytext);
						return FIM-EXPRESS;
					}

{INI-SUBESCRIT}		{
						printf("Abre de colchetes: %s\n", yytext);
						num_char += strlen(yytext);
						return INI-SUBESCRIT;
					}
{FIM-SUBESCRIT}		{
						printf("Fecha de Colchetes: %s\n", yytext);
						num_char += strlen(yytext);
						return FIM-SUBESCRIT;
					}

{LITERAL}			{
						printf("String constante: %s\n", yytext);
						num_char += strlen(yytext);
						return LITERAL;
					}


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
