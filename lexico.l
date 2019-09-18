
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "./lib/TabSimbolo.h"
	// #include "sintatico.tab.h"
	//#include "hash.h"
	//Hash tab;
	int num_char = 0, num_lin = 1;
	int erro = 0;
	TabSimbolos tabela;
	int contLinha(char* text);
%}

LETRA			[a-zA-Z]
DIGITO			[0-9]
NUM				{INT}|{FLOAT}


COMENT-ETERNO	"/*"(.|{EOL})*
COMENT-LINHA	"//".*
COMENT-BLOCO	"/*"(.|\n)*"*/"
PALAVRA-CHAVE	if|else|for|float|int|char|shape|point|return
LITERAL			"\"".*"\""
CHAR			"\'"."\'"

INT				{DIGITO}+
FLOAT			{INT}"."{DIGITO}+([eE][-+])?{DIGITO}*
ID				({LETRA})+({LETRA}|{DIGITO}|"_")*

RELOP			"<"|">"|"<="|">="|"=="|"!="|"!"|"&&"|"||"
ATROP			"="|"+="|"-="|"*="|"/="|"%="
ADDOP			"+"|"-"
MULOP			"*"|"/"

INI-SUBESCRIT	"["
FIM-SUBESCRIT	"]"
INI-PARAM		"("
FIM-PARAM		")"
INI-INSTRUC		"{"
FIM-INSTRUC		"}"

FIM-EXPRESS		";"+
SEPARA-ARG		","
ACESSO-MEMB		"."|"->"
ACESSO-END		"&"

EOL				\n|\r\n
SEPARADORES		{SEPARA-ARG}|{ACESSO-MEMB}
ERRO			{INT}{ID}|{RELOP}{RELOP}+|{ATROP}{ATROP}+|{ADDOP}{ADDOP}+|{MULOP}{MULOP}+|{FLOAT}{FLOAT}+|{SEPARADORES}{SEPARADORES}+


%%

{ERRO}			{erro++; num_char += strlen(yytext); printf("\t[ERRO] Entrada invalida: %s linha[%d:%d]\n", yytext, num_lin, num_char);}

{PALAVRA-CHAVE}	{
					printf("Palavra-chave: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return PALAVRA-CHAVE;
				}

{LITERAL}		{
					printf("String constante: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return LITERAL;
				}

{CHAR}			{
					printf("Char: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return CHAR;
				}


{INT}			{
					printf("Inteiro: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return INT;
				}

{FLOAT}			{
					printf("Float: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return FLOAT;
				}

{ID}			{
					printf("Identificador: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return ID;
				}


{RELOP}			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char)
					return RELOP;
				}

{ATROP}			{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return ATROP;
				}

{ADDOP}			{
					printf("Operador Adicao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return ADDOP;
				}

{MULOP}			{
					printf("Operador Multiplicacao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return MULOP;
				}


{INI-SUBESCRIT}	{
					printf("Abre colchetes: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return INI-SUBESCRIT;
				}

{FIM-SUBESCRIT}	{
					printf("Fecha colchetes: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return FIM-SUBESCRIT;
				}

{INI-PARAM}		{
					printf("Inicio de parametro: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return INI-PARAM;
				}

{FIM-PARAM}		{
					printf("Fim de parametro: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return FIM-PARAM;
				}

{INI-INSTRUC}	{
					printf("Inicio de instrucao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext,
					num_lin, num_char);
					return INI-INSTRUC;
				}

{FIM-INSTRUC}	{
					printf("Fim de instrucao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return FIM-INSTRUC;
				}


{FIM-EXPRESS}	{
					printf("Fim de expressao: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char); 
					insere(&tabela, yytext, num_lin, num_char);
					return FIM-EXPRESS;
				}

{SEPARA-ARG}	{
					printf("Separador de argumento: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return SEPARA-ARG;
				}

{ACESSO-MEMB}	{
					printf("Operador de acesso a membro: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return ACESSO-MEMB;
				}

{ACESSO-END}	{
					printf("Operador de acesso a endereco: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return ACESSO-END;
				}

{COMENT-LINHA}	{printf("Comentario!! Ignorando: %s\n", yytext);}
{COMENT-BLOCO}	{printf("Comentario!! Ignorando: %s\n", yytext); num_lin += contLinha(yytext);}

{EOL}			{num_lin++; num_char = 0;}
[ \t\r]			;
{COMENT-ETERNO}	{erro++; printf("\t[ERRO] Comentario nunca finalizado: %s linha[%d:%d]\n", yytext, num_lin, num_char);}
.				{printf("\t[ERRO] Caractere nao reconhecido: %s linha[%d:%d]\n", yytext, num_lin, ++num_char); erro++;}


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

