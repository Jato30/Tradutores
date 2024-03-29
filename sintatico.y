
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
	Node* novoNo(int quantidade, Filhos* filhos, char* valor, Parametro* params);
	Node* novaFolhaFloat(double val);
	Node* novaFolhaInt(int val);
	Node* novaFolhaText(char* val);
	
	void yyerror(char const *s);

	struct Arvore{
		Filhos* fi;
		int qtdFi;
		char* valor;
		int linha;
		int coluna;
		Parametro* params;
	};

	TabSimbolos tabela;
	Node* raiz = NULL;
	extern int num_lin;
	extern int num_char;
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
%type <node> lista_arg arg nome_func chamada endereco factor termo
%type <node> express_soma express_simp var expressao instruc_return
%type <node> instruc_iterac instruc_cond instruc_expr instrucao lista_instruc
%type <node> decl_local instruc_composta param lista_param params
%type <node> tipo_especif decl_func decl_var declaracao lista_decl programa


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
				lista[0] = $1;
				$$ = novoNo(1, lista, "decl_func ", NULL);

				Node** lista1 = (Node**) malloc(sizeof(Node*));
				lista1[0] = $$;
				raiz = (Node*) malloc(sizeof(Node));
				raiz = novoNo(1, lista, "programa ", NULL);
				printf("\nCOMPILACAO CONCLUIDA\n");
			}
			;

lista_decl:
			declaracao {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "declaracao ", NULL);
			}
			| declaracao lista_decl {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "declaracao lista_decl ", NULL);
			}
			;


declaracao:
			decl_var {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "decl_var ", NULL);
			}
			| decl_func {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "decl_func ", NULL);
			}
			;

decl_var:
			tipo_especif var FIM_EXPRESS {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "tipo_especif var ; ", NULL);

				TYPE type;
				switch($1->valor[0]){
					case 'i':
						type = Inteiro;
					break;

					case 'f':
						type = Decimal;
					break;

					case 'p':
						type = Ponto;
					break;

					case 's':
						type = Forma;
					break;
				
					default:
						type = Literal;
						break;
				}

				insere(&tabela, strdup($2->valor), "", VAR, type, 0, NULL);
			}
			;

decl_func:
			tipo_especif var INI_PARAM params FIM_PARAM instruc_composta {
				Node** lista = (Node**) malloc(sizeof(Node*) * 4);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $4;
				lista[3] = $6;
				$$ = novoNo(4, lista, "tipo_especif var ( params ) instruc_composta ", $4 != NULL ? ($4->params != NULL ? $4->params : NULL) : NULL);

				TYPE type;
				switch($1->valor[0]){
					case 'i':
						type = Inteiro;
					break;

					case 'f':
						type = Decimal;
					break;

					case 'p':
						type = Ponto;
					break;

					case 's':
						type = Forma;
					break;
				
					default:
						type = Literal;
						break;
				}


				int aux_qtd = 0;
				if($4 != NULL){
					if($4->params != NULL){
						aux_qtd = $4->params->qtd;
					}
				}
				insere(&tabela, strdup($2->valor), "", FUNC, type, aux_qtd, $4 != NULL ? ($4->params != NULL ? $4->params : NULL) : NULL);
			}
			;

tipo_especif:
			INT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("int");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| FLOAT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("float");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| POINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("point");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| SHAPE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("shape");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			;

params:
			/* %empty */ {
				$$ = NULL;
			}
			| lista_param {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "lista_param ", NULL);
			}
			;


lista_param:
			param {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "param ", NULL);
			}
			| param SEPARA_ARG lista_param {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $3;
				$$ = novoNo(2, lista, "param, lista_param ", NULL);
			}
			;


param:
			tipo_especif endereco {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $2;
				Parametro* param = (Parametro*) malloc(sizeof(Parametro));
				switch($1->valor[0]){
					case 'i':
						param->tipo = Inteiro;
					break;

					case 'f':
						param->tipo = Decimal;
					break;

					case 'p':
						param->tipo = Ponto;
					break;

					case 's':
						param->tipo = Forma;
					break;
				
					default:
						param->tipo = Literal;
						break;
				}
				param->nome = strdup($2->valor);
				param->isEnd = 1;
				param->prox = NULL;
				$$ = novoNo(2, lista, "tipo_especif endereco ", param);
			}
			| tipo_especif var {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $2;
				Parametro* param = (Parametro*) malloc(sizeof(Parametro));
				switch($1->valor[0]){
					case 'i':
						param->tipo = Inteiro;
					break;

					case 'f':
						param->tipo = Decimal;
					break;

					case 'p':
						param->tipo = Ponto;
					break;

					case 's':
						param->tipo = Forma;
					break;
				
					default:
						param->tipo = Literal;
						break;
				}
				param->nome = strdup($2->valor);
				param->isEnd = 0;
				param->prox = NULL;
				$$ = novoNo(2, lista, "tipo_especif var ", param);
			}
			;

instruc_composta:
			INI_INSTRUC decl_local lista_instruc FIM_INSTRUC {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $2;
				lista[1] = $3;
				$$ = novoNo(2, lista, "{ decl_local lista_instruc } ", NULL);
			}
			;


decl_local:
			/* %empty */ {
				$$ = NULL;
			}
			| decl_var decl_local {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "decl_var decl_local ", NULL);
			}
			;


lista_instruc:
			/* %empty */ {
				$$ = NULL;
			}
			| instrucao lista_instruc {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $2;
				$$ = novoNo(2, lista, "instrucao lista_instruc ", NULL);
			}
			;


instrucao:
			instruc_expr {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "instruc_expr ", NULL);
			}
			| instruc_composta {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "instruc_composta ", NULL);
			}
			| instruc_cond {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "instruc_cond ", NULL);
			}
			| instruc_iterac {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "instruc_iterac ", NULL);
			}
			| instruc_return {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "instruc_return ", NULL);
			}
			;

instruc_expr:
			expressao FIM_EXPRESS {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "expressao ; ", NULL);
			}
			| FIM_EXPRESS {
				$$ = NULL;
			}
			;


instruc_cond:
			IF INI_PARAM expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("if");
				lista[1] = $3;
				lista[2] = $6;

				$$ = novoNo(3, lista, "IF ( expressao ) { instrucao } ", NULL);
			}
			| IF INI_PARAM expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC ELSE INI_INSTRUC instrucao FIM_INSTRUC {
				Node** lista = (Node**) malloc(sizeof(Node*) * 5);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("if");
				lista[1] = $3;
				lista[2] = $6;
				lista[3] = (Node*) malloc(sizeof(Node));
				lista[3] = novaFolhaText("else");
				lista[4] = $10;

				$$ = novoNo(5, lista, "IF ( expressao ) { instrucao } else { instrucao } ", NULL);
			}
			;


instruc_iterac:
			FOR INI_PARAM expressao FIM_EXPRESS express_simp FIM_EXPRESS expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC {
				Node** lista = (Node**) malloc(sizeof(Node*) * 5);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("for");
				lista[1] = $3;
				lista[2] = $5;
				lista[3] = $7;
				lista[4] = $10;

				$$ = novoNo(5, lista, "FOR ( expressao ; express_simp ; expressao ) { instrucao }", NULL);
			}
			;

instruc_return:
			RETURN expressao FIM_EXPRESS {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("return");
				lista[1] = $2;
				$$ = novoNo(2, lista, "RETURN expressao ; ", NULL);
			}
			;

expressao:
			var atrop express_simp {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;
				$$ = novoNo(3, lista, "var atrop express_simp ", NULL);

				int i = 0, chave = buscaTabNome(&tabela, $1->valor);
				chave--;
				TabSimbolos item = tabela;
				for(i = 0; i < chave; i++){
					item = item->prox;
				}
				item->valor = strdup($3->valor);
				// printf("\t\t ########################## nome: %s / TAB[%d].nome = %s / valor = %s ##########\n\n, strdup($1->valor), chave+1, item->nome, item->valor);
			}
			| express_simp {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			;


var:
			ID {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText(strdup($1));
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			;

express_simp:
			express_soma {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "express_soma ", NULL);
			}
			| express_soma relop express_soma {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;
				$$ = novoNo(3, lista, "express_soma relop express_soma ", NULL);
			}
			;


express_soma:
			termo {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "termo ", NULL);
			}
			| termo addop express_soma {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;
				$$ = novoNo(3, lista, "termo addop express_soma ", NULL);
			}
			;


termo:
			factor {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "factor ", NULL);
			}
			| factor mulop termo {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;
				$$ = novoNo(3, lista, "factor mulop termo ", NULL);
			}
			;


factor:
			INI_PARAM expressao FIM_PARAM {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $2;
				$$ = novoNo(1, lista, "( strdup($2->valor) ) ", NULL);
			}
			| endereco {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			| var {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			| chamada {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "chamada ", NULL);
			}
			| num {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			| LITERAL {
				$$ = novaFolhaText(strdup($1));

				insere(&tabela, "texto", strdup($$->valor), OTHER, Literal, 0, NULL);
			}
			;

endereco:
			ACESSO_END var {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("&");
				lista[1] = $2;
				$$ = novoNo(2, lista, "ACESSO_END var ", NULL);
			}
			;

chamada:
			nome_func INI_PARAM arg FIM_PARAM{
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $3;
				$$ = novoNo(2, lista, "var ( arg ) ", NULL);
			}
			;

nome_func:
			PRINTINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printInt");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| PRINTFLOAT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printFloat");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| PRINTPOINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printPoint");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| PRINTSHAPE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printShape");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| SCANINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("scanInt");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| SCANFLOAT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("scanFloat");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| CONSTROIPOINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("constroiPoint");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| CONSTROISHAPE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("constroiShape");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| PERIMETRO {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("Perimetro");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| ISIN {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("IsIn");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| ISCOLLIDED {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("IsCollided");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			;

arg:
			/* %empty */ {
				$$ = NULL;
			}
			| lista_arg {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "lista_arg ", NULL);
			}
			;


lista_arg:
			expressao {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "expressao ", NULL);
			}
			| expressao SEPARA_ARG lista_arg {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $3;
				$$ = novoNo(2, lista, "expressao, lista_arg ", NULL);
			}
			;


atrop:
			ATR { 
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("=");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| PLUS_ATR {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("+=");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| MINUS_ATR {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("-=");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| TIMES_ATR {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("*=");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| OVER_ATR {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("/=");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			;

relop:
			LT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("<");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| GT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText(">");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| LE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("<=");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| GE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("=>");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| EQ {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("==");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| NE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("!=");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| logop {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, "logop ", NULL);
			}
			;

logop:
			NOT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("!");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| AND {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("&&");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| OR {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("||");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			;

addop:
			PLUS_OP {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("+");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| MINUS_OP {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("-");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			;

mulop:
			TIMES_OP {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("*");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			| OVER_OP {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("/");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
			}
			;

num:
			INTEIRO {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaInt($1);
				$$ = novoNo(1, lista, lista[0]->valor, NULL);

				insere(&tabela, "", strdup($$->valor), VAR, Inteiro, 0, NULL);
			}
			| DECIMAL {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaFloat($1);
				$$ = novoNo(1, lista, lista[0]->valor, NULL);

				insere(&tabela, "", strdup($$->valor), VAR, Decimal, 0, NULL);
			}
			;




%%


// Conta digitos em um float
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

void printArvore(Node *raiz, int tabs) {
	int i;
	if (raiz != NULL) {
		for(i = 0; i < tabs; ++i){
			printf("   ");
		}
		if (raiz->valor != NULL) {
			printf("%s\n", raiz->valor);
		}
		for(i = 0; i < raiz->qtdFi; i++){
			printArvore(raiz->fi[i], tabs + 1);
		}
	}
}

void destroiArvore(Node *raiz){
	if(raiz != NULL){
		int i;
		if(raiz->fi != NULL){
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
		if(raiz->params != NULL){
			Parametro* atual = raiz->params;
			Parametro* proximo = raiz->params->prox;
			do{
				atual = atual->prox;
				free(raiz->params->prox);
				raiz->params->prox = NULL;
				free(raiz->params->nome);
				raiz->params->nome = NULL;
			} while(atual != NULL);

			free(raiz->params->nome);
			raiz->params->nome = NULL;
			free(raiz->params);
			raiz->params = NULL;
		}

		free(raiz);
		raiz = NULL;
	}
}



Node* novoNo(int quantidade, Filhos* filhos, char* valor, Parametro* params){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->fi = filhos;
	novo->qtdFi = quantidade;
	novo->valor = strdup(valor);
	novo->linha = -1;
	novo->coluna = -1;

	novo->params = params != NULL ? params : NULL;

	// printf("\t\t\t\t ################ %s\n", novo->valor);
	return novo;
}

Node* novaFolhaFloat(double val){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->valor = (char*) malloc(sizeof(char) * (contDigf(val) + 1));
	novo->qtdFi = 0;
	novo->linha = num_lin;
	novo->coluna = num_char;
	gcvt(val, contDigf(val) + 1, novo->valor);
	// printf("\t\t\t\t ################ %s\n", novo->valor);
	novo->fi = NULL;
	novo->params = NULL;
	return novo;
}

Node* novaFolhaInt(int val){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->valor = (char*) malloc(sizeof(char) * (contDigf((double)val) + 1));
	novo->qtdFi = 0;
	novo->linha = num_lin;
	novo->coluna = num_char;
	sprintf(novo->valor, "%i", val);
	// printf("\t\t\t\t ################ %s\n", novo->valor);
	novo->fi = NULL;
	novo->params = NULL;
	return novo;
}

Node* novaFolhaText(char* val){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->qtdFi = 0;
	novo->linha = num_lin;
	novo->coluna = num_char;
	novo->valor = strdup(val);
	// printf("\t\t\t\t ################ %s\n", novo->valor);
	novo->fi = NULL;
	novo->params = NULL;
	return novo;
}

void yyerror(char const *s){
	fprintf(stderr, "%s\n", s);
}

int main(void){
	criaTab(&tabela);
	yyparse();
	printArvore(raiz, 0);
	printTab(&tabela);
	destroiArvore(raiz);
	destroiTab(&tabela);
	return 0;
}

