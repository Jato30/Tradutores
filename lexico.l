%option noyywrap
%option bison-bridge

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
	int contLinha(char* text);
	TabSimbolos tabela;
%}



LETRA			[a-zA-Z]
DIGITO			[0-9]

COMENT_LINHA	"//".*
COMENT_BLOCO	"/*"(.|\n)*"*/"
LITERAL			"\"".*"\""
/*COMENT_ETERNO	"/*"(.|\n)**/
IF				if
ELSE			else
FOR				for
RETURN			return
INT				int
FLOAT			float
POINT			point
SHAPE			shape

INTEIRO			{DIGITO}+
DECIMAL			{INTEIRO}"."{DIGITO}+([eE][-+])?{DIGITO}*
ID				({LETRA})+({LETRA}|{DIGITO}|"_")*

LT				"<"
GT				">"
LE				"<="
GE				">="
EQ				"=="
NE				"!="
NOT				"!"
AND				"&&"
OR				"||"
RELOP			{LT}|{GT}|{LE}|{GE}|{EQ}|{NE}|{NOT}|{AND}|{OR}

ATR				"="
PLUS_ATR		"+="
MINUS_ATR		"-="
TIMES_ATR		"*="
OVER_ATR		"/="
ATROP			{ATR}|{PLUS_ATR}|{MINUS_ATR}|{TIMES_ATR}|{OVER_ATR}

PLUS_OP			"+"
MINUS_OP		"-"
TIMES_OP		"*"
OVER_OP			"/"
OPERATOR		{PLUS_OP}|{MINUS_OP}|{TIMES_OP}|{OVER_OP}

INI_PARAM		"("
FIM_PARAM		")"
INI_INSTRUC		"{"
FIM_INSTRUC		"}"

FIM_EXPRESS		";"+
SEPARA_ARG		","
ACESSO_END		"&"

EOL				\n|\r\n
ERRO			{INTEIRO}{ID}|{RELOP}{RELOP}+|{OPERATOR}{OPERATOR}+|{DECIMAL}{DECIMAL}+|{SEPARA_ARG}{SEPARA_ARG}+


%%

{ERRO} 			{erro++; num_char += strlen(yytext); printf("\t[ERRO] Entrada invalida: %s linha[%d:%d]\n", yytext, num_lin, num_char);}

{IF} 			{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (IF);
				}

{ELSE} 			{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (ELSE);
				}

{FOR} 			{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (FOR);
				}

{RETURN} 		{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (RETURN);
				}

{INT} 			{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (INT);
				}

{FLOAT} 		{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (FLOAT);
				}

{POINT} 		{
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (POINT);
				}

{SHAPE} 		{
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					insere(&tabela, yytext, num_lin, num_char);
					return (SHAPE);
				}

{LITERAL} 		{
					printf("String constante: %s\n", yytext);
					num_char += strlen(yytext);

					int i, j = 0;
					char* aux = (char*) malloc(sizeof(char) * (strlen(yytext) - 2));
					for(i = 0; i < strlen(yytext); i++){
						if(yytext[i] = '"'){
							i++;
							if(i == strlen(yytext)){
								break;
							}
						}
						aux[j] = yytext[i];
						j++;
					}
					yylval->LITERAL = (char*) malloc(sizeof(char) * strlen(aux));
					strcpy(yylval->LITERAL, aux);
					free(aux);
					aux = NULL;
					insere(&tabela, yytext, num_lin, num_char);
					return (LITERAL);
				}


{INTEIRO} 		{
					printf("Inteiro: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					yylval->INTEIRO = atoi(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (INTEIRO);
				}

{DECIMAL} 		{
					printf("Float: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					yylval->DECIMAL = atof(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (DECIMAL);
				}

{ID} 			{
					printf("Identificador: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char);
					strcpy(yylval->ID, yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (ID);
				}


{LT} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (LT);
				}

{GT} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (GT);
				}

{LE} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (LE);
				}

{GE} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (GE);
				}

{EQ} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (EQ);
				}

{NE} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (NE);
				}

{NOT} 			{
					printf("Operador Logico: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (NOT);
				}

{AND} 			{
					printf("Operador Logico: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (AND);
				}

{OR} 			{
					printf("Operador Logico: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (OR);
				}


{ATR} 			{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (ATR);
				}

{PLUS_ATR} 		{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (PLUS_ATR);
				}

{MINUS_ATR} 	{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (MINUS_ATR);
				}

{TIMES_ATR} 	{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (TIMES_ATR);
				}

{OVER_ATR} 		{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (OVER_ATR);
				}


{PLUS_OP} 		{
					printf("Operador Aditivo: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (PLUS_OP);
				}

{MINUS_OP} 		{
					printf("Operador Aditivo: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (MINUS_OP);
				}

{TIMES_OP} 		{
					printf("Operador Multiplicativo: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (TIMES_OP);
				}

{OVER_OP} 		{
					printf("Operador Multiplicativo: %s\n", yytext);
					num_char += strlen(yytext);
					insere(&tabela, yytext, num_lin, num_char);
					return (OVER_OP);
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
