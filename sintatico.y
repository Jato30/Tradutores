
%{
	#include <stdio.h>
	#include <stdlib.h>

	int yylex();
	void yyerror(char const *s);
%} 

%token IF
%token ELSE
%token FOR
%token RETURN
%token INT
%token FLOAT
%token POINT
%token SHAPE
%token LITERAL

%token INTEIRO
%token DECIMAL
%token ID

%token LT
%token GT
%token LE
%token GE
%token EQ
%token NE
%token NOT
%token AND
%token OR

%token ATR
%token PLUS_ATR
%token MINUS_ATR
%token TIMES_ATR
%token OVER_ATR
%token MOD_ATR

%token PLUS_OP
%token MINUS_OP
%token TIMES_OP
%token OVER_OP
%token MOD_OP

%token INI_SUBESCRIT
%token FIM_SUBESCRIT
%token INI_PARAM
%token FIM_PARAM
%token INI_INSTRUC
%token FIM_INSTRUC

%token FIM_EXPRESS
%token SEPARA_ARG
%token ACESSO_MEMB
%token ACESSO_END




%%


programa:
			lista_decl
			;

lista_decl:
			declaracao recursao1
			;

recursao1:
			/* %empty */
			| declaracao recursao1
			;

declaracao:
			decl_var
			| decl_func
			;

decl_var:
			tipo_especif ID fatora1
			;

fatora1:
			FIM_EXPRESS
			| INI_SUBESCRIT INTEIRO FIM_SUBESCRIT FIM_EXPRESS
			;

decl_func:
			tipo_especif ID INI_PARAM params FIM_PARAM instruc_composta
			;

tipo_especif:
			INT
			| FLOAT
			| POINT
			| SHAPE
			;

params:
			/* %empty */
			| lista_param
			;

lista_param:
			lista_param SEPARA_ARG param
			| param
			;

param:
			tipo_especif ID fatora2
			;

fatora2:
			/* %empty */
			| INI_SUBESCRIT INTEIRO FIM_SUBESCRIT
			;

instruc_composta:
			INI_INSTRUC decl_local lista_instruc FIM_INSTRUC
			;

decl_local:
			recursao2
			;

recursao2:
			/* %empty */
			| decl_var recursao2
			;

lista_instruc:
			recursao3
			;

recursao3:
			/* %empty */
			| instrucao recursao3
			;


instrucao:
			instruc_expr
			| instruc_composta
			| instruc_cond
			| instruc_iterac
			| instruc_return
			;

instruc_expr:
			expressao FIM_EXPRESS
			| FIM_EXPRESS
			;

instruc_cond:
			IF INI_PARAM expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC fatora3
			;

fatora3:
			/* %empty */
			| ELSE INI_INSTRUC instrucao FIM_INSTRUC
			;

instruc_iterac:
			FOR INI_PARAM expressao FIM_EXPRESS express_simp FIM_EXPRESS expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC
			;

instruc_return:
			RETURN expressao FIM_EXPRESS
			;

expressao:
			var atrop expressao
			| express_simp
			;

var:
			ID ACESSO_MEMB ID
			| ID INI_SUBESCRIT expressao FIM_SUBESCRIT
			| ID
			;

express_simp:
			express_soma fatora4
			;

fatora4:
			/* %empty */
			| relop express_soma
			;

express_soma:
			termo recursao4
			;

recursao4:
			/* %empty */
			| addop termo recursao4
			;

termo:
			factor recursao5
			;

recursao5:
			/* %empty */
			| mulop factor recursao5
			;

factor:
			INI_PARAM expressao FIM_PARAM
			| endereco
			| var
			| chamada
			| num
			| LITERAL
			;

chamada:
			ID INI_PARAM arg FIM_PARAM
			;

arg:
			/* %empty */
			| lista_arg
			;

lista_arg:
			expressao recursao6
			;

recursao6:
			/* %empty */
			| SEPARA_ARG expressao recursao6
			;

atrop:
			ATR
			| PLUS_ATR
			| MINUS_ATR
			| TIMES_ATR
			| OVER_ATR
			| MOD_ATR
			;

relop:
			LT
			| GT
			| LE
			| GE
			| EQ
			| NE
			| logop
			;

logop:
			NOT
			| AND
			| OR
			;

addop:
			PLUS_OP
			| MINUS_OP
			;

mulop:
			TIMES_OP
			| OVER_OP
			| MOD_OP
			;

num:
			INTEIRO { printf("\t\t### SINTATICO:\tint = %d\n", $1); }
			| DECIMAL
			;

endereco:
			ACESSO_END var
			;



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
