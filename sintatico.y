
%{
	#include <stdio.h>
	#include <stdlib.h>

	int yylex();
	void yyerror(char const *s);
	char* myvar;
%} 

%token TIPO_ESPECIF
%token PALAVRA_INSTRUC
%token LITERAL
%token LETRA
%token DIGITO

%token INT
%token FLOAT
%token ID

%token SEPARA_ARG
%token ACESSO_MEMB
%token ACESSO_END
%token FIM_EXPRESS

%token INI_SUBESCRIT
%token FIM_SUBESCRIT
%token INI_PARAM
%token FIM_PARAM
%token INI_INSTRUC
%token FIM_INSTRUC

%token RELOP
%token ATROP
%token ADDOP
%token MULOP


%%


programa:
			lista_decl;

lista_decl:
			lista_decl declaracao | declaracao;

declaracao:
			decl_var | decl_func;

decl_var:
			TIPO_ESPECIF ID FIM_EXPRESS | TIPO_ESPECIF ID INI_SUBESCRIT INT FIM_SUBESCRIT FIM_EXPRESS;

decl_func:
			TIPO_ESPECIF ID INI_PARAM params FIM_PARAM instruc_composta;

params:
			/* %empty */ | lista_param;

lista_param:
			lista_param SEPARA_ARG param | param;

param:
			TIPO_ESPECIF ID | TIPO_ESPECIF ID INI_SUBESCRIT FIM_SUBESCRIT;

instruc_composta:
			INI_INSTRUC decl_local lista_instruc FIM_INSTRUC;

decl_local:
			/* %empty */ | decl_local decl_var;

lista_instruc:
			/* %empty */ | lista_instruc instrucao;

instrucao:
			instruc_expr | instruc_composta | instruc_cond | instruc_iterac | instruc_return;

instruc_expr:
			expressao FIM_EXPRESS | FIM_EXPRESS;

instruc_cond:
			"if" INI_PARAM expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC |
			"if" INI_PARAM expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC "else" INI_INSTRUC instrucao FIM_INSTRUC
			;

instruc_iterac:
			"for" INI_PARAM expressao FIM_EXPRESS express_simp FIM_EXPRESS expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC;

instruc_return:
			"return" expressao FIM_EXPRESS;

expressao:
			var ATROP expressao | express_simp;

var:
			ID ACESSO_MEMB ID
			| ID INI_SUBESCRIT expressao FIM_SUBESCRIT
			| ID
			;

express_simp:
			express_soma RELOP express_soma | express_soma;

express_soma:
			express_soma ADDOP termo | termo;

termo:
			termo MULOP factor | factor;

factor:
			INI_PARAM expressao FIM_PARAM | endereco | var | chamada | num | LITERAL;

chamada:
			ID INI_PARAM arg FIM_PARAM;

arg:
			/* %empty */ | lista_arg;

lista_arg:
			lista_arg SEPARA_ARG expressao | expressao;

num:
			INT { printf("\t\t### SINTATICO:\tint = %d\n", $1); }
			| FLOAT;

endereco:
			ACESSO_END var;



%%

void yyerror (char const *s) {
	fprintf (stderr, "%s\n", s);
}

int main(int argc, char** argv){
	yyparse();

	return 0;
} 

// {printf("IDENTIFICADOR: %s", $1);}
// {printf("FLOAT: %d\n", $1);} 
// {printf("INT: %d\n", $1);} 
// {printf("PT-VIRG: %s\n", $1);} 
