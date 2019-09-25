
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "./lib/TabSimbolo.h"
	#include "sintatico.tab.h"
	//#include "hash.h"
	//Hash tab;
	int num_char = 0, num_lin = 1;
	int erro = 0;
	TabSimbolos tabela = NULL;
	int contLinha(char* text);
%}

LETRA			[a-zA-Z]
DIGITO			[0-9]

COMENT_LINHA	"//".*
COMENT_BLOCO	"/*"(.|\n)*"*/"
/*COMENT_ETERNO	"/*"(.|\n)**/
PALAVRA_INSTRUC	if|else|for|return
TIPO_ESPECIF	float|int|shape|point
LITERAL			"\"".*"\""

INT				{DIGITO}+
FLOAT			{INT}"."{DIGITO}+([eE][-+])?{DIGITO}*
ID				({LETRA})+({LETRA}|{DIGITO}|"_")*

RELOP			"<"|">"|"<="|">="|"=="|"!="|"!"|"&&"|"||"
ATROP			"="|"+="|"-="|"*="|"/="|"%="
ADDOP			"+"|"-"
MULOP			"*"|"/"

INI_SUBESCRIT	"["
FIM_SUBESCRIT	"]"
INI_PARAM		"("
FIM_PARAM		")"
INI_INSTRUC		"{"
FIM_INSTRUC		"}"

FIM_EXPRESS		";"+
SEPARA_ARG		","
ACESSO_MEMB		"."|"->"
ACESSO_END		"&"

EOL				\n|\r\n
SEPARADORES		{SEPARA_ARG}|{ACESSO_MEMB}
ERRO			{INT}{ID}|{RELOP}{RELOP}+|{ATROP}{ATROP}+|{ADDOP}{ADDOP}+|{MULOP}{MULOP}+|{FLOAT}{FLOAT}+|{SEPARADORES}{SEPARADORES}+


%%

{ERRO} 			{erro++; num_char += strlen(yytext); printf("\t[ERRO] Entrada invalida: %s linha[%d:%d]\n", yytext, num_lin, num_char);}

{PALAVRA_INSTRUC} {
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (PALAVRA_INSTRUC);
				}

{TIPO_ESPECIF} 	{
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (TIPO_ESPECIF);
				}

{LITERAL} 		{
					printf("String constante: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (LITERAL);
				}

{INT} 			{
					printf("Inteiro: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (INT);
				}

{FLOAT} 		{
					printf("Float: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (FLOAT);
				}

{ID} 			{
					printf("Identificador: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (ID);
				}


{RELOP} 		{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (RELOP);
				}

{ATROP} 		{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (ATROP);
				}

{ADDOP} 		{
					printf("Operador Adicao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (ADDOP);
				}

{MULOP} 		{
					printf("Operador Multiplicacao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (MULOP);
				}


{INI_SUBESCRIT} {
					printf("Abre colchetes: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (INI_SUBESCRIT);
				}

{FIM_SUBESCRIT} {
					printf("Fecha colchetes: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (FIM_SUBESCRIT);
				}

{INI_PARAM} 	{
					printf("Inicio de parametro: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (INI_PARAM);
				}

{FIM_PARAM} 	{
					printf("Fim de parametro: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (FIM_PARAM);
				}

{INI_INSTRUC} 	{
					printf("Inicio de instrucao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext,
					num_lin, num_char);
					return (INI_INSTRUC);
				}

{FIM_INSTRUC} 	{
					printf("Fim de instrucao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (FIM_INSTRUC);
				}


{FIM_EXPRESS} 	{
					printf("Fim de expressao: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char); 
					insere(&tabela, yytext, num_lin, num_char);
					return (FIM_EXPRESS);
				}

{SEPARA_ARG} 	{
					printf("Separador de argumento: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (SEPARA_ARG);
				}

{ACESSO_MEMB} 	{
					printf("Operador de acesso a membro: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (ACESSO_MEMB);
				}

{ACESSO_END} 	{
					printf("Operador de acesso a endereco: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (ACESSO_END);
				}

{COMENT_LINHA} 	{printf("Comentario!! Ignorando: %s\n", yytext);}
{COMENT_BLOCO} 	{printf("Comentario!! Ignorando: %s\n", yytext); num_lin += contLinha(yytext);}

{EOL} 			{num_lin++; num_char = 0;}
[ \t\r] 		;

. 				{printf("\t[ERRO] Caractere nao reconhecido: %s linha[%d:%d]\n", yytext, num_lin, ++num_char); erro++;}


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
// int main(int argc, char** argv){

// 	if(argc > 1){
// 		yyin = fopen( argv[1], "r");
// 	}
// 	else{
// 		yyin = stdin;
// 	}

// 	//InicializaHash(tab);
// 	cria(&tabela);

// 	yylex();

// 	printf("\nNumero total de linhas: %d\n", num_lin);
// 	if(erro > 0){
// 		printf("Total de erros encontrados: %d\n", erro);
// 	}
// 	else{
// 		printTab(&tabela);
// 	}

// 	return 0;
// }

/*
{COMENT_ETERNO} {erro++; printf("\t[ERRO] Comentario nunca finalizado: %s linha[%d:%d]\n", yytext, num_lin, num_char);}
*/
