
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "./lib/TabSimbolo.h"

	int yylex();

	typedef struct Arvore Node;
	typedef Node* Filhos;
	
	int contDigf(double val);
	void printArvore(Node *raiz, int tabs);
	void destroiArvore(Node *raiz);
	Node* novoNo(int quantidade, Filhos* filhos, char* valor);
	Node* novaFolhaFloat(double val);
	Node* novaFolhaInt(int val);
	Node* novaFolhaText(char* val);
	
	void yyerror(char const *s);

	struct Arvore{
		Filhos* fi;
		int qtdFi;
		char* valor;
	};

	TabSimbolos tabela;
	Node* raiz = NULL;
%}

%defines
%pure-parser

%token <ID> IF ELSE FOR RETURN INT FLOAT POINT SHAPE PRINTINT PRINTFLOAT PRINTPOINT PRINTSHAPE SCANINT SCANFLOAT CONSTROIPOINT CONSTROISHAPE PERIMETRO ISIN ISCOLLIDED

%token <LITERAL> LITERAL

%token <INTEIRO> INTEIRO
%token <DECIMAL> DECIMAL
%token <ID> ID

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

%token PLUS_OP
%token MINUS_OP
%token TIMES_OP
%token OVER_OP

%token INI_PARAM
%token FIM_PARAM
%token INI_INSTRUC
%token FIM_INSTRUC

%token FIM_EXPRESS
%token SEPARA_ARG
%token ACESSO_END



%type <node> num addop mulop logop relop atrop
%type <node> rec_args lista_arg arg nome_func chamada endereco factor
%type <node> rec_timesexpress termo
%type <node> rec_plusexpress express_soma fat_express express_simp var expressao instruc_return
%type <node> instruc_iterac fat_if instruc_cond instruc_expr instrucao rec_instrucs lista_instruc
%type <node> rec_declocs decl_local instruc_composta param rec_paramlist lista_param params
%type <node> tipo_especif decl_func decl_var declaracao rec_decls lista_decl programa


%union{
	int INTEIRO;
	double DECIMAL;
	char ID[33];
	char* op;
	char* LITERAL;
	struct Arvore* node;
}




%start programa



%%


programa:
			lista_decl {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "decl_func ");

				Node** lista1 = (Node**) malloc(sizeof(Node*));
				lista1[0] = (Node*) malloc(sizeof(Node));
				lista1[0] = $$;
				raiz = (Node*) malloc(sizeof(Node));
				raiz = novoNo(1, lista, "programa ");
				printf("\nCOMPILACAO CONCLUIDA\n");
			}
			;

lista_decl:
			declaracao rec_decls {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "declaracao rec_decls ");
			}
			;

rec_decls:
			/* %empty */ { $$ = NULL;

			}
			| declaracao rec_decls {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "declaracao rec_decls ");
			}
			;


declaracao:
			decl_var {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "decl_var ");
			}
			| decl_func {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "decl_func ");
			}
			;

decl_var:
			tipo_especif var FIM_EXPRESS {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "tipo_especif var ; ");
			}
			;

decl_func:
			tipo_especif var INI_PARAM params FIM_PARAM instruc_composta {
				Node** lista = (Node**) malloc(sizeof(Node*) * 4);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[2] = (Node*) malloc(sizeof(Node));
				lista[3] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				lista[3] = $4;
				lista[4] = $6;
				$$ = novoNo(4, lista, "tipo_especif var ( params ) instruc_composta ");
			}
			;

tipo_especif:
			INT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("int");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| FLOAT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("float");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| POINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("point");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| SHAPE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("shape");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			;

params:
			/* %empty */ { $$ = NULL;
				
			}
			| lista_param {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "lista_param ");
			}
			;


lista_param:
			param rec_paramlist {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "param rec_paramlist ");
			}
			;

rec_paramlist:
			/* %empty */ { $$ = NULL;

			}
			| SEPARA_ARG param rec_paramlist {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $2;
				lista[1] = $3;
				$$ = novoNo(2, lista, ", param rec_paramlist ");
			}
			;


param:
			tipo_especif var {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "tipo_especif var ");
			}
			;

instruc_composta:
			INI_INSTRUC decl_local lista_instruc FIM_INSTRUC {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $2;
				lista[1] = $3;
				$$ = novoNo(2, lista, "{ decl_local lista_instruc } ");
			}
			;


decl_local:
			rec_declocs {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "rec_declocs ");
			}
			;

rec_declocs:
			/* %empty */ { $$ = NULL;

			}
			| decl_var rec_declocs {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "decl_var rec_declocs ");
			}
			;


lista_instruc:
			rec_instrucs {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "rec_instrucs ");
			}
			;

rec_instrucs:
			/* %empty */ {

			}
			| instrucao rec_instrucs {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "instrucao rec_instrucs ");
			}
			;


instrucao:
			instruc_expr {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "instruc_expr ");
			}
			| instruc_composta {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "instruc_composta ");
			}
			| instruc_cond {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "instruc_cond ");
			}
			| instruc_iterac {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "instruc_iterac ");
			}
			| instruc_return {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "instruc_return ");
			}
			;

instruc_expr:
			expressao FIM_EXPRESS {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "expressao ; ");
			}
			| FIM_EXPRESS {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText(";");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			;


instruc_cond:
			IF INI_PARAM expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC fat_if {
				Node** lista = (Node**) malloc(sizeof(Node*) * 4);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[2] = (Node*) malloc(sizeof(Node));
				lista[3] = (Node*) malloc(sizeof(Node));
				
				lista[0] = novaFolhaText("if");
				lista[1] = $3;
				lista[2] = $6;
				lista[3] = $8;

				$$ = novoNo(4, lista, "IF ( expressao ) { instrucao } fat_if ");
			}
			;

fat_if:
			/* %empty */ {$$ = NULL;

			}
			| ELSE INI_INSTRUC instrucao FIM_INSTRUC {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("else");
				lista[1] = $3;
				$$ = novoNo(2, lista, "ELSE { instrucao } ");
			}
			;


instruc_iterac:
			FOR INI_PARAM expressao FIM_EXPRESS express_simp FIM_EXPRESS expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC {
				Node** lista = (Node**) malloc(sizeof(Node*) * 5);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[2] = (Node*) malloc(sizeof(Node));
				lista[3] = (Node*) malloc(sizeof(Node));
				lista[4] = (Node*) malloc(sizeof(Node));
				
				lista[0] = novaFolhaText("for");
				lista[1] = $3;
				lista[2] = $5;
				lista[3] = $7;
				lista[4] = $10;

				$$ = novoNo(5, lista, "FOR ( expressao ; express_simp ; expressao ) { instrucao }");
			}
			;

instruc_return:
			RETURN expressao FIM_EXPRESS {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("return");
				lista[1] = $2;
				$$ = novoNo(2, lista, "RETURN expressao ; ");
			}
			;

expressao:
			var atrop expressao {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[2] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				lista[1] = $3;
				$$ = novoNo(3, lista, "var atrop expressao ");
			}
			| express_simp {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "express_simp ");
			}
			;


var:
			ID {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText($1);
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			;

express_simp:
			express_soma fat_express {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(1, lista, "express_soma fat_express ");
			}
			;

fat_express:
			/* %empty */ { $$ = NULL;

			}
			| relop express_soma {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "relop express_soma ");
			}
			;


express_soma:
			termo rec_plusexpress {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(1, lista, "termo rec_plusexpress ");
			}
			;

rec_plusexpress:
			/* %empty */ { $$ = NULL;

			}
			| addop termo rec_plusexpress {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[2] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;
				$$ = novoNo(3, lista, "addop termo rec_plusexpress ");
			}
			;


termo:
			factor rec_timesexpress {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(1, lista, "factor rec_timesexpress ");
			}
			;

rec_timesexpress:
			/* %empty */ { $$ = NULL;

			}
			| mulop factor rec_timesexpress {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[2] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;
				$$ = novoNo(3, lista, "mulop factor rec_timesexpress ");
			}
			;


factor:
			INI_PARAM expressao FIM_PARAM {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $2;
				$$ = novoNo(1, lista, "( expressao ) ");
			}
			| endereco {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "endereco ");
			}
			| var {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "var ");
			}
			| chamada {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "chamada ");
			}
			| num {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "num ");
			}
			| LITERAL {
				$$ = novaFolhaText($1);
			}
			;

endereco:
			ACESSO_END var {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("&");
				lista[1] = $2;
				$$ = novoNo(2, lista, "ACESSO_END var ");
			}
			;

chamada:
			nome_func INI_PARAM arg FIM_PARAM{
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $3;
				$$ = novoNo(2, lista, "var ( arg ) ");
			}
			;

nome_func:
			PRINTINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printInt");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| PRINTFLOAT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printFloat");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| PRINTPOINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printPoint");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| PRINTSHAPE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printShape");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| SCANINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("scanInt");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| SCANFLOAT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("scanFloat");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| CONSTROIPOINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("constroiPoint");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| CONSTROISHAPE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("constroiShape");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| PERIMETRO {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("Perimetro");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| ISIN {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("IsIn");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| ISCOLLIDED {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("IsCollided");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			;

arg:
/* %empty */ { $$ = NULL;

			}
			| lista_arg {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "lista_arg ");
			}
			;


lista_arg:
			expressao rec_args {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "expressao rec_args ");
			}
			;

rec_args:
			/* %empty */ { $$ = NULL;

			}
			| SEPARA_ARG expressao rec_args {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $2;
				lista[1] = $3;
				$$ = novoNo(2, lista, ", expressao rec_args ");
			}
			;


atrop:
			ATR { 
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("=");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| PLUS_ATR {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("+=");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| MINUS_ATR {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("-=");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| TIMES_ATR {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("*=");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| OVER_ATR {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("/=");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			;

relop:
			LT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("<");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| GT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText(">");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| LE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("<=");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| GE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("=>");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| EQ {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("==");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| NE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("!=");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| logop {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				$$ = novoNo(1, lista, "logop ");
			}
			;

logop:
			NOT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("!");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| AND {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("&&");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| OR {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("||");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			;

addop:
			PLUS_OP {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("+");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| MINUS_OP {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("-");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			;

mulop:
			TIMES_OP {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("*");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| OVER_OP {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("/");
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			;

num:
			INTEIRO {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaInt($1);
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			| DECIMAL {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaFloat($1);
				$$ = novoNo(1, lista, lista[0]->valor);
			}
			;




%%



int contDigf(double val){
	int i = ((int) val);
	char aux;
	int count = 1; // primeiro digito da parte inteira

	while(i >= 1){
		count++;
		i /= 10;
	}

	if(val != ((int)val)){
		count++; // por causa do "."
	}

	while(val != ((int)val)){
		count++;
		val *= 10;
	}

	return count;

}

void printArvore(Node *raiz, int tabs){
  if (raiz != NULL) {
	int i;
	if(tabs == 0){
		printf("-----------------------------------------------\nArvore\n\n");
	}
	printf("line:%2d", raiz->qtdFi );

	for(i = 0; i < tabs; ++i){
		printf("  ");
	}
	printf("%s%s", raiz->valor , raiz->fi ? "{\n" : "\n");


	if(raiz->fi != NULL){
		i = 0;
		while(raiz->fi[i] != NULL){
			printArvore(raiz->fi[i], tabs + 1);
			i++;
		}
		i = 0;
	}
	printf("line:%2d", raiz->qtdFi );
	for(i = 0; i < tabs; ++i){
		printf("  ");
	}
	if(raiz->fi != NULL){
		printf("}");
	}
	printf("\n");
	if(tabs == 0){
		printf("-----------------------------------------------\n");
	}
  }
}

void destroiArvore(Node *raiz){
	if(raiz != NULL){
		if(raiz->fi != NULL){
			int i;
			for(i = 0; i < raiz->qtdFi; i++){
				if(raiz->fi[i] != NULL){
					destroiArvore(raiz->fi[i]);
				}
			}
		}
		if(raiz->valor != NULL){
			free(raiz->valor);
			raiz->valor = NULL;
		}

		free(raiz);
		raiz = NULL;
	}
}



Node* novoNo(int quantidade, Filhos* filhos, char* valor){
  	Node* novo = (Node*) malloc(sizeof(Node));
	novo->fi = filhos;
	novo->qtdFi = quantidade;
	novo->valor = (char*) malloc(sizeof(char) * strlen(valor) +1);
	novo->valor = strdup(valor);

	// printf("\t\t\t\t ################ %s\n", novo->valor);
	return novo;
}

Node* novaFolhaFloat(double val){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->valor = (char*) malloc(sizeof(char) * (contDigf(val) + 1));
	novo->qtdFi = 0;
	gcvt(val, contDigf(val) + 1, novo->valor);
	// printf("\t\t\t\t ################ %s\n", novo->valor);
	novo->fi = NULL;
	return novo;
}

Node* novaFolhaInt(int val){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->valor = (char*) malloc(sizeof(char) * (contDigf((double)val) + 1));
	novo->qtdFi = 0;
	sprintf(novo->valor, "%i", val);
	// printf("\t\t\t\t ################ %s\n", novo->valor);
	novo->fi = NULL;
	return novo;
}

Node* novaFolhaText(char* val){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->valor = (char*) malloc(sizeof(char) * strlen(val));
	novo->qtdFi = 0;
	novo->valor = strdup(val);
	// printf("\t\t\t\t ################ %s\n", novo->valor);
	novo->fi = NULL;
	return novo;
}

void yyerror(char const *s){
	fprintf(stderr, "%s\n", s);
}

int main(void){
	criaTab(&tabela);
	yyparse();
	printArvore(raiz, 0);
	//printTab(&tabela);
	destroiArvore(raiz);
	// destroiTab(&tabela);
	return 0;
}

