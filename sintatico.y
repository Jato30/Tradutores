
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "./lib/TabSimbolo.h"

	int yylex();
%}

%token COMENT-ETERNO
%token COMENT-LINHA
%token COMENT-BLOCO
%token PALAVRA-CHAVE
%token LITERAL
%token LETRA
%token DIGITO
%token CHAR

%token INT
%token FLOAT
%token NUM
%token ID

%token SEPARADORES
%token SEPARA-ARG
%token ACESSO-MEMB
%token ACESSO-END
%token FIM-EXPRESS

%token INI-SUBESCRIT
%token FIM-SUBESCRIT
%token INI-PARAM
%token FIM-PARAM
%token INI-INSTRUC
%token FIM-INSTRUC

%token RELOP
%token ATROP
%token ADDOP
%token MULOP

%token EOL
%token ERRO


%%


PROGRAMA:
			PROGRAMA EOL;



%%


int main(){
	yyparse();
	return 0;
}