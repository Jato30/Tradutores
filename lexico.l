
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "TabSimbolo.h"
	//#include "sintatico.tab.h"
	//#include "hash.h"
	//Hash tab;
	int num_char = 0, num_lin = 1;
	int erro = 0;
	TabSimbolos tabela;
	int contLinha(char* text);
%}

PALAVRA-CHAVE	if|else|for|float|int|char|shape|point|return
LITERAL			"\"".*"\""
COMENT-LINHA	"//".*
COMENT-BLOCO	"/*"(.|\n)*"*/"
LETRA			[a-zA-Z]
DIGITO			[0-9]
CHAR			"\'"."\'"

INT				{DIGITO}+
FLOAT			{INT}"."{DIGITO}+([eE][-+])?{DIGITO}*
NUM				{INT}|{FLOAT}
ID				({LETRA})+({LETRA}|{DIGITO}|"_")*

SEPARADORES		{SEPARA-ARG}|{ACESSO-MEMB}
SEPARA-ARG		","
ACESSO-MEMB		"."|"->"
ACESSO-END		"&"
FIM-EXPRESS		";"+

INI-SUBESCRIT	"["
FIM-SUBESCRIT	"]"
INI-PARAM		"("
FIM-PARAM		")"
INI-INSTRUC		"{"
FIM-INSTRUC		"}"

OPERADORES		{RELOP}|{ATROP}|{ADDOP}|{MULOP}
RELOP			"<"|">"|"<="|">="|"=="|"!="|"!"|"&&"|"||"
ATROP			"="|"+="|"-="|"*="|"/="|"%="
ADDOP			"+"|"-"
MULOP			"*"|"/"

ERRO			{INT}{ID}|{RELOP}{RELOP}+|{ATROP}{ATROP}+|{ADDOP}{ADDOP}+|{MULOP}{MULOP}+|{FLOAT}{FLOAT}+|{SEPARADORES}{SEPARADORES}+


%%

{ERRO}				{erro++; num_char += strlen(yytext); printf("\t[ERRO] Entrada invalida: %s linha[%d:%d]\n", yytext, num_lin, num_char);}

{PALAVRA-CHAVE}		{printf("Palavra-chave: %s\n", yytext); num_char += strlen(yytext); checa_warn(yytext, num_lin, num_char); insere(&tabela, yytext, num_lin, num_char);}
{ID}				{printf("Identificador: %s\n", yytext); num_char += strlen(yytext); checa_warn(yytext, num_lin, num_char); insere(&tabela, yytext, num_lin, num_char);}
{INT}				{printf("Inteiro: %s\n", yytext); num_char += strlen(yytext); checa_warn(yytext, num_lin, num_char); insere(&tabela, yytext, num_lin, num_char);}
{FLOAT}				{printf("Float: %s\n", yytext); num_char += strlen(yytext); checa_warn(yytext, num_lin, num_char); insere(&tabela, yytext, num_lin, num_char);}
{CHAR}				{printf("Char: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}

{RELOP}				{printf("Operador Relacional: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{ATROP}				{printf("Operador Atribuicao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{ADDOP}				{printf("Operador Adicao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{MULOP}				{printf("Operador Multiplicacao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}

{INI-PARAM}			{printf("Inicio de parametro: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{FIM-PARAM}			{printf("Fim de parametro: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{INI-INSTRUC}		{printf("Inicio de instrucao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{FIM-INSTRUC}		{printf("Fim de instrucao: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{SEPARA-ARG}		{printf("Separador de argumento: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{ACESSO-MEMB}		{printf("Operador de acesso a membro: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{ACESSO-END}		{printf("Operador de acesso a endereco: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{FIM-EXPRESS}		{printf("Fim de expressao: %s\n", yytext); num_char += strlen(yytext); checa_warn(yytext, num_lin, num_char); insere(&tabela, yytext, num_lin, num_char);}

{INI-SUBESCRIT}		{printf("Abre colchetes: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}
{FIM-SUBESCRIT}		{printf("Fecha colchetes: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}

{LITERAL}			{printf("String constante: %s\n", yytext); num_char += strlen(yytext); insere(&tabela, yytext, num_lin, num_char);}


{COMENT-LINHA}		{printf("Comentario!! Ignorando: %s\n", yytext);}
{COMENT-BLOCO}		{printf("Comentario!! Ignorando: %s\n", yytext); num_lin += contLinha(yytext);}

\n					{num_lin++; num_char = 0;}
[ \t\r]				;
.					{printf("\t[ERRO] Caractere nao reconhecido: %s linha[%d:%d]\n", yytext, num_lin, ++num_char); erro++;}


%%

int yywrap(){
	return 1;
}

int contLinha(char* text){
	int i = 0, count = 0;
	while(text[i] != '\0'){
		if(text[i] == '\n'){
			count++;
		}
		i++;
	}

	return count;
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
	cria(&tabela);

	yylex();

	printf("\nNumero total de linhas: %d\n", num_lin);
	if(erro > 0){
		printf("Total de erros encontrados: %d\n", erro);
	}
	else{
		printTab(&tabela);
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
