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
	int checa_warn(char* valor, int lin, int col);
	extern TabSimbolos tabela;
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
PRINTINT		printInt
PRINTFLOAT		printFloat
PRINTPOINT		printPoint
PRINTSHAPE		printShape
SCANINT			scanInt
SCANFLOAT		scanFloat
CONSTROIPOINT	constroiPoint
CONSTROISHAPE	constroiShape
PERIMETRO		Perimetro
ISIN			IsIn
ISCOLLIDED		IsCollided

INTEIRO			{DIGITO}+
DECIMAL			{INTEIRO}"."{DIGITO}+
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

{LITERAL} 		{
					num_char += strlen(yytext);

					int i, j = 0;
					char* aux = (char*) malloc(sizeof(char) * (strlen(yytext) - 1));
					for(i = 1; i < (strlen(yytext) - 1); i++){
						aux[j] = yytext[i];
						j++;
					}
					aux[j] = '\0';
					yylval->LITERAL = (char*) malloc(sizeof(char) * strlen(aux));
					strcpy(yylval->LITERAL, aux);
					free(aux);
					aux = NULL;

					printf("String constante: \"%s\"\n", yylval->LITERAL);
					// insere(&tabela, yylval->LITERAL, num_lin, num_char);

					return (LITERAL);
				}

{IF} 			{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (IF);
				}

{ELSE} 			{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (ELSE);
				}

{FOR} 			{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (FOR);
				}

{RETURN} 		{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (RETURN);
				}

{INT} 			{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (INT);
				}

{FLOAT} 		{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (FLOAT);
				}

{POINT} 		{
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (POINT);
				}

{SHAPE} 		{
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (SHAPE);
				}

{PRINTINT} 		{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (PRINTINT);
				}

{PRINTFLOAT} 	{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (PRINTFLOAT);
				}

{PRINTPOINT} 		{
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (PRINTPOINT);
				}

{PRINTSHAPE} 	{
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (PRINTSHAPE);
				}

{SCANINT} 		{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (SCANINT);
				}

{SCANFLOAT} 	{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (SCANFLOAT);
				}

{CONSTROIPOINT} {
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (CONSTROIPOINT);
				}

{CONSTROISHAPE} {
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (CONSTROISHAPE);
				}

{PERIMETRO} 	{
					printf("Palavra reservada: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (PERIMETRO);
				}

{ISIN} 			{
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (ISIN);
				}

{ISCOLLIDED} 	{
					printf("Tipo de dados: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (ISCOLLIDED);
				}


{INTEIRO} 		{
					printf("Inteiro: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					yylval->INTEIRO = atoi(yytext);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (INTEIRO);
				}

{DECIMAL} 		{
					printf("Float: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					yylval->DECIMAL = atof(yytext);
					// insere(&tabela, strdup(yytext), num_lin, num_char);
					return (DECIMAL);
				}

{ID} 			{
					printf("Identificador: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(strdup(yytext), num_lin, num_char);
					strcpy(yylval->ID, yytext);
					// insere(&tabela, yylval->ID, num_lin, num_char);
					return (ID);
				}


{LT} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);
					return (LT);
				}

{GT} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);
					return (GT);
				}

{LE} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);

					return (LE);
				}

{GE} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);

					return (GE);
				}

{EQ} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);

					return (EQ);
				}

{NE} 			{
					printf("Operador Relacional: %s\n", yytext);
					num_char += strlen(yytext);

					return (NE);
				}

{NOT} 			{
					printf("Operador Logico: %s\n", yytext);
					num_char += strlen(yytext);

					return (NOT);
				}

{AND} 			{
					printf("Operador Logico: %s\n", yytext);
					num_char += strlen(yytext);

					return (AND);
				}

{OR} 			{
					printf("Operador Logico: %s\n", yytext);
					num_char += strlen(yytext);

					return (OR);
				}


{ATR} 			{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);

					return (ATR);
				}

{PLUS_ATR} 		{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);

					return (PLUS_ATR);
				}

{MINUS_ATR} 	{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);

					return (MINUS_ATR);
				}

{TIMES_ATR} 	{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);

					return (TIMES_ATR);
				}

{OVER_ATR} 		{
					printf("Operador Atribuicao: %s\n", yytext);
					num_char += strlen(yytext);

					return (OVER_ATR);
				}


{PLUS_OP} 		{
					printf("Operador Aditivo: %s\n", yytext);
					num_char += strlen(yytext);

					return (PLUS_OP);
				}

{MINUS_OP} 		{
					printf("Operador Aditivo: %s\n", yytext);
					num_char += strlen(yytext);

					return (MINUS_OP);
				}

{TIMES_OP} 		{
					printf("Operador Multiplicativo: %s\n", yytext);
					num_char += strlen(yytext);

					return (TIMES_OP);
				}

{OVER_OP} 		{
					printf("Operador Multiplicativo: %s\n", yytext);
					num_char += strlen(yytext);

					return (OVER_OP);
				}


{INI_PARAM} 	{
					printf("Inicio de parametro: %s\n", yytext);
					num_char += strlen(yytext);

					return (INI_PARAM);
				}

{FIM_PARAM} 	{
					printf("Fim de parametro: %s\n", yytext);
					num_char += strlen(yytext);

					return (FIM_PARAM);
				}

{INI_INSTRUC} 	{
					printf("Inicio de instrucao: %s\n", yytext);
					num_char += strlen(yytext);
					// insere(&tabela, yytext, num_lin, num_char);
					return (INI_INSTRUC);
				}

{FIM_INSTRUC} 	{
					printf("Fim de instrucao: %s\n", yytext);
					num_char += strlen(yytext);

					return (FIM_INSTRUC);
				}


{FIM_EXPRESS} 	{
					printf("Fim de expressao: %s\n", yytext);
					num_char += strlen(yytext);
					checa_warn(yytext, num_lin, num_char); 

					return (FIM_EXPRESS);
				}

{SEPARA_ARG} 	{
					printf("Separador de argumento: %s\n", yytext);
					num_char += strlen(yytext);

					return (SEPARA_ARG);
				}

{ACESSO_END} 	{
					printf("Operador de acesso a endereco: %s\n", yytext);
					num_char += strlen(yytext);

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

// RETORNO: 0 nenhnum erro, 1 erro corrigido, 2 erro nao corrigido
int checa_warn(char* valor, int lin, int col){
	int erro = 0;

	// ERRO DE TAMANHO
	{
		int tam = (int) strlen(valor);
		if(tam > 33){
			if(erro < 1){
				erro = 1;
			}
			printf("\t[WARNING]: Tamanho excede o maximo %d>33. valor sera truncado. Linha[%d:%d]\n", tam, lin, col);
			char aux_valor[33];
			int i = 0;
			for(i = 0; i < 33; i++){
				aux_valor[i] = valor[i];
			}
			valor[33] = '\0';
			strcpy(valor, aux_valor);
			printf("\t\tNovo valor truncado: %s\n", valor);
		}
	}

	// ERRO DE IF
	{
		if(strcmp("fi", valor) == 0){
			if(erro < 2){
				erro = 2;
			}
			printf("\t[WARNING]: em vez de %s, nao quis dizer if? Linha[%d:%d]\n", valor, lin+1, col);
		}
	}

	// ERRO DE FIM DE EXPRESSAO ;;
	{
		if(';' == valor[0] && strcmp(";", valor) != 0){
			printf("\t[WARNING]: Fim de expressao com %s valor sera substituido por ; Linha[%d:%d]\n", valor, lin+1, col);
			if(erro < 1){
				erro = 1;
			}

			valor[1] = '\0';
			valor[0] = ';';
		}
	}

	return 0;
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
