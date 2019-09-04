
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "hash.h"
	int num_char = 0;
	Hash tab;
%}

PALAVRA-CHAVE	if|else|for|float|int|char|shape|point|return
CONST-STRING	"\"".*"\""
ID				({LETRA})+({LETRA}|{DIGITO}|"_")*
NUM				"-"?({DIGITO}+|({DIGITO}+"."{DIGITO}+"E"?{DIGITO}*))
LETRA			[a-zA-Z]
DIGITO			[0-9]


SEPARADOR		","|";"
DELIMITADOR		"["|"]"|"("|")"|"{"|"}"

RELOP			"<"|">"|"<="|">="|"=="|"!="|"!"
ATROP			"="|"+="|"-="|"*="|"/="|"%="
ADDOP			"+"|"-"
MULOP			"*"|"/"


%%

{PALAVRA-CHAVE}		{
						printf("Palavra-chave: %s\n", yytext);
						InsereHashChave(tab, yytext);
					}
{ID}				{printf("Identificador: %s\n", yytext);}
{NUM}				{printf("Numero: %s\n", yytext);}

{RELOP}				{printf("Operador Relacional: %s\n", yytext);}
{ATROP}				{printf("Operador Atribuicao: %s\n", yytext);}
{ADDOP}				{printf("Operador Adicao: %s\n", yytext);}
{MULOP}				{printf("Operador Multiplicacao: %s\n", yytext);}


{SEPARADOR}			{printf("Separador: %s\n", yytext);}
{DELIMITADOR}		{printf("Delimitador: %s\n", yytext);}

{CONST-STRING}		{printf("String constante: %s\n", yytext);}

\n					{yylineno++;}

[ \t\r]				;
.					printf("Caractere nao reconhecido: %s linha[%d]\n", yytext, yylineno);


%%

int yywrap(){
	return 1;
}

// PARA COMPILAR SEM MAIN, UTILIZE A FLAG -ll
void main( argc, argv )
int argc;
char **argv;
	{
	InicializaHash(tab);
	++argv, --argc;	/* skip over program name */
	if ( argc > 0 )
		yyin = fopen( argv[0], "r" );
	else
		yyin = stdin;

	yylex();

	printf("\nNumero total de linhas: %d\n", yylineno);
}



/* INI-PARAM		"("
FIM-PARAM		")"
INI-INSTRUC		"{"
FIM-INSTRUC		"}"
FIM-EXPRESS		";"
{INI-PARAM}			{printf("Inicio de parametro: %s\n", yytext);}
{FIM-PARAM}			{printf("Fim de parametro: %s\n", yytext);}
{INI-INSTRUC}		{printf("Inicio de instrucao: %s\n", yytext);}
{FIM-INSTRUC}		{printf("Fim de instrucao: %s\n", yytext);}
{FIM-EXPRESS}		{printf("Fim de expressao: %s\n", yytext);}*/
