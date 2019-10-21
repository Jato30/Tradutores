%defines
%pure-parser

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	//#include "./lib/TabSimbolo.h"

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

	// TabSimbolos tabela = NULL;
	Node* raiz = NULL;
	// extern tabela;
%} 

%token <ID> IF ELSE FOR RETURN INT FLOAT POINT SHAPE

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
%type <node> rec_args lista_arg arg chamada endereco factor
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
			/* %empty */ {

			}
			| declaracao rec_decls
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
				$$ = novaFolhaText("int");
			}
			| FLOAT {
				$$ = novaFolhaText("float");
			}
			| POINT {
				$$ = novaFolhaText("point");
			}
			| SHAPE {
				$$ = novaFolhaText("shape");
			}
			;

params:
			/* %empty */ {
				
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
			/* %empty */ {

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
			/* %empty */ {

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
				$$ = novaFolhaText(";");
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
			/* %empty */ {

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
				$$ = novaFolhaText($1);
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
			/* %empty */ {

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
			/* %empty */ {

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
			/* %empty */ {

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
			var INI_PARAM arg FIM_PARAM{
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[1] = (Node*) malloc(sizeof(Node));
				lista[0] = $1;
				lista[1] = $3;
				$$ = novoNo(2, lista, "var ( arg ) ");
			}
			;

arg:
			/* %empty */ {

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
			/* %empty */ {

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
				$$ = novaFolhaText("=");
			}
			| PLUS_ATR {
				$$ = novaFolhaText("+=");
			}
			| MINUS_ATR {
				$$ = novaFolhaText("-=");
			}
			| TIMES_ATR {
				$$ = novaFolhaText("*=");
			}
			| OVER_ATR {
				$$ = novaFolhaText("/=");
			}
			;

relop:
			LT {
				$$ = novaFolhaText("<");
			}
			| GT {
				$$ = novaFolhaText(">");
			}
			| LE {
				$$ = novaFolhaText("<=");
			}
			| GE {
				$$ = novaFolhaText(">=");
			}
			| EQ {
				$$ = novaFolhaText("==");
			}
			| NE {
				$$ = novaFolhaText("!=");
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
				$$ = novaFolhaText("!");
			}
			| AND {
				$$ = novaFolhaText("&&");
			}
			| OR {
				$$ = novaFolhaText("||");
			}
			;

addop:
			PLUS_OP {
				$$ = novaFolhaText("+");
			}
			| MINUS_OP {
				$$ = novaFolhaText("-");
			}
			;

mulop:
			TIMES_OP {
				$$ = novaFolhaText("*");
			}
			| OVER_OP {
				$$ = novaFolhaText("/");
			}
			;

num:
			INTEIRO {
				$$ = novaFolhaInt($1);
			}
			| DECIMAL {
				$$ = novaFolhaFloat($1);
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
	int i;
	for(i = 0; i < tabs; ++i){
		printf("- ");
	}
	printf("%s\n", raiz->valor);
	// if(raiz->op) {
	// 	printf("%c{\n", raiz->op);
	for(i = 0; i < raiz->qtdFi; i++){
		if(raiz->fi[i] != NULL){
			printArvore(raiz->fi[i], tabs + 1);
		}
	}
	// 	printArvore(raiz->direita, tabs + 1);
	// 	for(i = 0; i < tabs; ++i){
			printf("  ");
	// 	}
	// 	printf("}\n");
	// }
	// else{
	// 	printf("%s\n", raiz->valor);
	// }
}

void destroiArvore(Node *raiz){
	if(raiz->fi != NULL){
		int i;
		for(i = 0; i < raiz->qtdFi; i++){
			destroiArvore(raiz->fi[i]);
			free(raiz->fi[i]);
			raiz->fi[i] = NULL;
		}
	}
	free(raiz->valor);
	raiz->valor = NULL;
	free(raiz);
	raiz = NULL;
}



Node* novoNo(int quantidade, Filhos* filhos, char* valor){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->fi = (Filhos*) malloc(sizeof(Node*) * quantidade);
	
	novo->qtdFi = quantidade;
	int i;
	for(i = 0; i < quantidade; i++){
		novo->fi[i] = (Node*) malloc(sizeof(Node));
		novo->fi[i] = filhos[i];
	}

	novo->valor = (char*) malloc(sizeof(char) * strlen(valor));
	novo->valor = strdup(valor);

	printf("\t\t\t\t ################ %s\n", novo->valor);
	return novo;
}

Node* novaFolhaFloat(double val){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->valor = (char*) malloc(sizeof(char) * contDigf(val));
	novo->qtdFi = 0;
	gcvt(val, contDigf(val), novo->valor);
	printf("\t\t\t\t ################ %s\n", novo->valor);
	novo->fi = NULL;
	return novo;
}

Node* novaFolhaInt(int val){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->valor = (char*) malloc(sizeof(char) * contDigf((double)val));
	novo->qtdFi = 0;
	sprintf(novo->valor, "%i", val);
	printf("\t\t\t\t ################ %s\n", novo->valor);
	novo->fi = NULL;
	return novo;
}

Node* novaFolhaText(char* val){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->valor = (char*) malloc(sizeof(char) * strlen(val));
	novo->qtdFi = 0;
	novo->valor = strdup(val);
	printf("\t\t\t\t ################ %s\n", novo->valor);
	novo->fi = NULL;
	return novo;
}

void yyerror(char const *s){
	fprintf(stderr, "%s\n", s);
}

int main(void){
	yyparse();
	while(yylex());
	printf("\nraiz: programa\n");
	printArvore(raiz, 0);
	destroiArvore(raiz);
	// destroiTab(&tabela);
	return 0;
}

