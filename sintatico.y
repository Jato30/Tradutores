
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "./lib/TabSimbolo.h"

	int yylex();

	typedef struct Arvore Node;
	typedef Node* Filhos;
	
	int contDigf(float val);
	void printArvore(Node *raiz, int tabs);
	void destroiArvore(Node *raiz);
	Node* novoNo(int quantidade, Filhos* filhos, char* valor, Parametro* params);
	Node* novaFolhaFloat(float val);
	Node* novaFolhaInt(int val);
	Node* novaFolhaText(char* val);
	
	void yyerror(char const *s);

	struct Arvore{
		Filhos* fi;
		int qtdFi;
		char* valor;
		int linha;
		int coluna;
		TYPE tipo;
		Parametro* params;
	};

	Contexto ctx_global;
	Contexto* ctx_atual;

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
	float DECIMAL;
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
				$$ = novoNo(1, lista, strdup($1->valor), NULL);

				raiz = $$;
				printf("\nCOMPILACAO CONCLUIDA\n");
			}
			;

lista_decl:
			declaracao {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			| declaracao lista_decl {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $2;

				char* val = (char*) malloc(sizeof(char) * (strlen($1->valor) + strlen($2->valor)) + 1);
				strcat(val, strdup($1->valor));
				strcat(val, strdup($2->valor));
				$$ = novoNo(2, lista, strdup(val), NULL);

				free(val);
				val = NULL;


			}
			;


declaracao:
			decl_var {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			| decl_func {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			;

decl_var:
			tipo_especif var FIM_EXPRESS {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $2;

				TYPE type;
				char* val;
				switch($1->valor[0]){
					case 'i':
						type = Inteiro;
						val = (char*) malloc(sizeof(char) * (4 + strlen($2->valor) + 1) + 1);
						strcat(val, "int ");
						break;

					case 'f':
						type = Decimal;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 1) + 1);
						strcat(val, "float ");
						break;

					case 'p':
						type = Ponto;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 1) + 1);
						strcat(val, "point ");
						break;

					case 's':
						type = Forma;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 1) + 1);
						strcat(val, "shape ");
						break;
				
					default:
						type = Literal;
						val = (char*) malloc(sizeof(char) * (8 + strlen($2->valor) + 1) + 1);
						strcat(val, "Literal ");
						break;
				}

				insere(strdup($2->valor), "", VAR, type, 0, NULL);



				strcat(val, strdup($2->valor));
				strcat(val, ";");
				$$ = novoNo(2, lista, val, NULL);
				TYPE tipo = $1->tipo;
				$$->tipo = tipo;

				free(val);
				val = NULL;
			}
			;

decl_func:
			tipo_especif nome_func INI_PARAM params FIM_PARAM {
				Node** lista = (Node**) malloc(sizeof(Node*) * 4);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $4;
				
				

				TYPE type;
				char* val;
				switch($1->valor[0]){
					case 'i':
						type = Inteiro;
						val = (char*) malloc(sizeof(char) * (4 + strlen($2->valor) + 8) + 1);
						strcat(val, "int ");
						break;

					case 'f':
						type = Decimal;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 8) + 1);
						strcat(val, "float ");
						break;

					case 'p':
						type = Ponto;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 8) + 1);
						strcat(val, "point ");
						break;

					case 's':
						type = Forma;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 8) + 1);
						strcat(val, "shape ");
						break;
				
					default:
						type = Literal;
						val = (char*) malloc(sizeof(char) * (8 + strlen($2->valor) + 8) + 1);
						strcat(val, "Literal ");
						break;
				}
				strcat(val, strdup($2->valor));
				strcat(val, "(params)");
				$<node>$ = novoNo(4, lista, val, $4 != NULL ? ($4->params != NULL ? $4->params : NULL) : NULL);
				TYPE tipo = $1->tipo;
				$<node>$->tipo = tipo;


				int aux_qtd = 0;
				if($4 != NULL){
					if($4->params != NULL){
						aux_qtd = $4->params->qtd;
					}
				}

				Simbolo* item = insere(strdup($2->valor), "", FUNC, type, aux_qtd, $4 != NULL ? ($4->params != NULL ? $4->params : NULL) : NULL);

				
				free(val);
				val = NULL;



				ctx_atual = item->interno;

				Parametro* temp = item->params;
				while(temp != NULL){
					insere(temp->nome, "", VAR, temp->tipo, 0, NULL);
					temp = temp->prox;
				}


			} instruc_composta {
				$$->fi[3] = $<node>6;

				ctx_atual = ctx_atual->criador->meu;
			}
			;

tipo_especif:
			INT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("int");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| FLOAT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("float");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Decimal;
			}
			| POINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("point");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Ponto;
			}
			| SHAPE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("shape");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Forma;
			}
			;

params:
			/* %empty */ {
				$$ = NULL;
			}
			| lista_param {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				Parametro* parametro = $1->params;
				$$ = novoNo(1, lista, strdup($1->valor), parametro);
			}
			;


lista_param:
			param {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				Parametro* parametro = $1->params;
				$$ = novoNo(1, lista, strdup($1->valor), parametro);
			}
			| param SEPARA_ARG lista_param {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $3;

				Parametro* parametro = $1->params;
				Parametro* atual = parametro;
				while(atual->prox != NULL){
					atual = atual->prox;
				}
				atual->prox = $3->params;


				$$ = novoNo(2, lista, "param, lista_param ", parametro);
			}
			;


param:
			tipo_especif endereco {
				$2->tipo = $1->tipo;
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $2;
				Parametro* param = (Parametro*) malloc(sizeof(Parametro));

				
				char* val;

				switch($1->valor[0]){
					case 'i':
						param->tipo = Inteiro;
						val = (char*) malloc(sizeof(char) * (4 + 1 + strlen($2->valor)) + 1);
						strcat(val, "int ");
						break;

					case 'f':
						param->tipo = Decimal;
						val = (char*) malloc(sizeof(char) * (6 + 1 + strlen($2->valor)) + 1);
						strcat(val, "float ");
						break;

					case 'p':
						param->tipo = Ponto;
						val = (char*) malloc(sizeof(char) * (6 + 1 + strlen($2->valor)) + 1);
						strcat(val, "point ");
						break;

					case 's':
						param->tipo = Forma;
						val = (char*) malloc(sizeof(char) * (6 + 1 + strlen($2->valor)) + 1);
						strcat(val, "shape ");
						break;
				
					default:
						val = (char*) malloc(sizeof(char) * (8 + 1 + strlen($2->valor)) + 1);
						strcat(val, "Literal ");
						param->tipo = Literal;
						break;
				}
				param->nome = strdup($2->valor);
				param->isEnd = 1;
				param->prox = NULL;


				strcat(val, "&");
				strcat(val, strdup($2->valor));
				$$ = novoNo(2, lista, strdup(val), param);
				TYPE tipo = $1->tipo;
				$$->tipo = tipo;

				free(val);
				val = NULL;
				

			}
			| tipo_especif var {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $2;


				char* val;

				Parametro* param = (Parametro*) malloc(sizeof(Parametro));
				switch($1->valor[0]){
					case 'i':
						param->tipo = Inteiro;
						val = (char*) malloc(sizeof(char) * (4 + strlen($2->valor)) + 1);
						strcat(val, "int ");
						break;

					case 'f':
						param->tipo = Decimal;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor)) + 1);
						strcat(val, "float ");
						break;

					case 'p':
						param->tipo = Ponto;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor)) + 1);
						strcat(val, "point ");
						break;

					case 's':
						param->tipo = Forma;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor)) + 1);
						strcat(val, "shape ");
						break;
				
					default:
						val = (char*) malloc(sizeof(char) * (8 + strlen($2->valor)) + 1);
						strcat(val, "Literal ");
						param->tipo = Literal;
						break;
				}
				param->nome = strdup($2->valor);
				param->isEnd = 0;
				param->prox = NULL;


				strcat(val, strdup($2->valor));
				$$ = novoNo(2, lista, strdup(val), param);
				TYPE tipo = $1->tipo;
				$$->tipo = tipo;

				free(val);
				val = NULL;

			}
			;

instruc_composta:
			INI_INSTRUC decl_local lista_instruc FIM_INSTRUC {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $2;
				lista[1] = $3;

				int size = 1;
				size += ($2 != NULL ? ($2->valor != NULL ? strlen($2->valor) : 0) : 0);
				size += ($3 != NULL ? ($3->valor != NULL ? strlen($3->valor) : 0) : 0);
				size += 1;
				char* val = (char*) malloc(sizeof(char) * size + 1);
				strcat(val, "{");
				if($2 != NULL && $2->valor != NULL){
					strcat(val, strdup($2->valor));
				}
				if($3 != NULL && $3->valor != NULL){
					strcat(val, strdup($3->valor));
				}
				strcat(val, "}");
				$$ = novoNo(2, lista, strdup(val), NULL);

				free(val);
				val = NULL;


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

				char* val = (char*) malloc(sizeof(char) * (strlen($1->valor) + ($2 != NULL ? ($2->valor != NULL ? strlen($2->valor) : 0) : 0)) + 1);
				strcat(val, strdup($1->valor));
				if($2 != NULL && $2->valor != NULL){
					strcat(val, strdup($2->valor));
				}
				$$ = novoNo(2, lista, strdup(val), NULL);

				free(val);
				val = NULL;



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

				char* val = (char*) malloc(sizeof(char) * (strlen($1->valor) + ($2 != NULL ? ($2->valor != NULL ? strlen($2->valor) : 0) : 0)) + 1);
				strcat(val, strdup($1->valor));
				if($2 != NULL && $2->valor != NULL){
					strcat(val, strdup($2->valor));
				}
				$$ = novoNo(2, lista, strdup(val), NULL);

				free(val);
				val = NULL;



			}
			;


instrucao:
			instruc_expr {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			| instruc_composta {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			| instruc_cond {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			| instruc_iterac {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			| instruc_return {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			;

instruc_expr:
			expressao FIM_EXPRESS {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;

				char* val = (char*) malloc(sizeof(char) * (strlen($1->valor) + 1) + 1);
				strcat(val, strdup($1->valor));
				strcat(val, ";");
				$$ = novoNo(1, lista, strdup(val), NULL);

				free(val);
				val = NULL;



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

				char* val = (char*) malloc(sizeof(char) * (3 + strlen($3->valor) + 1) + 1);
				strcat(val, "if(");
				strcat(val, strdup($3->valor));
				strcat(val, ")");
				$$ = novoNo(3, lista, strdup(val), NULL);

				free(val);
				val = NULL;


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


				char* val = (char*) malloc(sizeof(char) * (3 + strlen($3->valor) + 8) + 1);
				strcat(val, "if(");
				strcat(val, strdup($3->valor));
				strcat(val, ")...else");
				$$ = novoNo(5, lista, strdup(val), NULL);

				free(val);
				val = NULL;



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


				char* val = (char*) malloc(sizeof(char) * (4 + strlen($3->valor) + strlen($5->valor) + strlen($7->valor) + 3) + 1);
				strcat(val, "for(");
				strcat(val, strdup($3->valor));
				strcat(val, ";");
				strcat(val, strdup($5->valor));
				strcat(val, ";");
				strcat(val, strdup($7->valor));
				strcat(val, ")");
				$$ = novoNo(5, lista, strdup(val), NULL);

				free(val);
				val = NULL;




			}
			;

instruc_return:
			RETURN expressao FIM_EXPRESS {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("return");
				lista[1] = $2;

				char* val = (char*) malloc(sizeof(char) * (7 + strlen($2->valor) + 1) + 1);
				strcat(val, "return ");
				strcat(val, strdup($2->valor));
				strcat(val, ";");
				$$ = novoNo(2, lista, strdup(val), NULL);

				free(val);
				val = NULL;



			}
			;

expressao:
			var atrop express_simp {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;

				char* val = (char*) malloc(sizeof(char) * (strlen($1->valor) + strlen($2->valor) + strlen($3->valor)) + 1);
				strcat(val, strdup($1->valor));
				strcat(val, strdup($2->valor));
				strcat(val, strdup($3->valor));
				$$ = novoNo(3, lista, strdup(val), NULL);

				free(val);
				val = NULL;


				TabSimbolos item = buscaTabNome(strdup($1->valor));
				TabSimbolos item2 = buscaTabNome(strdup($3->valor));
				if(item2 == NULL){
					item2 = buscaTabVal(strdup($3->valor));
				}
				if(item == NULL){
					printf("\t### ERRO: [%s] uso de variavel nao declarada. [%d][%d]\n", $1->valor, $1->linha, $1->coluna);
				}
				else{
					$$->tipo = item->tipo;

					if($1->valor[0] == '\"'){
						$$->tipo = Literal;
					}

					TYPE tipo_express_simp = $3->tipo;
					if(item->tipo == Inteiro && tipo_express_simp == Decimal){
						printf("\t### ADVERTENCIA: [%s] expressao truncada para atribuicao. [%d][%d]\n", item->nome, $1->linha, $1->coluna);
					}
					if((item->tipo != Decimal && item->tipo != Inteiro) || (tipo_express_simp != Inteiro && tipo_express_simp != Decimal)){
						printf("\t### ERRO: [%s] tipo incompativel para atribuicao. [%d][%d]\n", item->nome, $1->linha, $1->coluna);
					}
					else{
						if(item2 != NULL){
							if(strcmp(item->valor != NULL ? item->valor : "", "") == 0){
								if(strcmp(item2->valor != NULL ? item2->valor : "", "") != 0){
									item->valor = (char*) malloc(sizeof(char) * strlen(item2->valor) + 1);
									strcpy(item->valor, item2->valor != NULL ? item2->valor : "");
								}
								else{
									printf("\t\t### ADVERTENCIA: [%s] atribuição de valor vazio. [%d][%d]\n", $3->valor, $3->linha, $3->coluna);
								}
							}
							else{
								free(item->valor);
								if(strcmp(item2->valor != NULL ? item2->valor : "", "") != 0){
									item->valor = (char*) malloc(sizeof(char) * strlen(item2->valor) + 1);
									strcpy(item->valor, item2->valor != NULL ? item2->valor : "");
								}
								else{
									printf("\t\t### ADVERTENCIA: [%s] atribuição de valor vazio. [%d][%d]\n", $3->valor, $3->linha, $3->coluna);
								}
							}
						}
						else{
							printf("\t\t### ERRO: [%s] valor inexistente na atribuição. [%d][%d]\n", $3->valor, $3->linha, $3->coluna);
						}
					}
				}


				// printf("\t\t ########################## nome: %s / TAB[%d].nome = %s / valor = %s ##########\n\n", strdup($1->valor), chave+1, item->nome, item->valor);
			}
			| express_simp {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
				TYPE tipo = $1->tipo;
				$$->tipo = tipo;
				if($1->valor[0] == '\"'){
					$$->tipo = Literal;
				}
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
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
				TYPE tipo = $1->tipo;
				$$->tipo = tipo;
			}
			| express_soma relop express_soma {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;

				char* val = (char*) malloc(sizeof(char) * (strlen($1->valor) + strlen($2->valor) + strlen($3->valor)) + 1);
				strcat(val, strdup($1->valor));
				strcat(val, strdup($2->valor));
				strcat(val, strdup($3->valor));

				$$ = novoNo(3, lista, strdup(val), NULL);

				if(($1->tipo == Decimal && ($3->tipo == Inteiro || $3->tipo == Decimal)) || ($3->tipo == Decimal && ($1->tipo == Inteiro || $1->tipo == Decimal))){
					$$->tipo = Decimal;
					if($1->tipo != $3->tipo){
						printf("\t### ADVERTENCIA: [%s %s %s] Operacao relacional sobre tipos distintos, inteiro e decimal. [%d][%d]\n", $1->tipo == Inteiro ? "int" : "float", $2->valor, $3->tipo == Inteiro ? "int" : "float", $2->linha, $2->coluna);
					}
				}
				else if($1->tipo == Inteiro && $3->tipo == Inteiro){
					$$->tipo = Inteiro;
				}
				else{
					printf("\t### ERRO: operacao relacional [%s] com tipos incorretos. [%d][%d]\n", $2->valor, $2->linha, $2->coluna);
					$$->tipo = other;
				}

				free(val);
				val = NULL;
			}
			;


express_soma:
			termo {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
				$$->tipo = $1->tipo;
			}
			| termo addop express_soma {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;

				char* val = (char*) malloc(sizeof(char) * (strlen($1->valor) + strlen($2->valor) + strlen($3->valor)) + 1);
				strcat(val, strdup($1->valor));
				strcat(val, strdup($2->valor));
				strcat(val, strdup($3->valor));

				$$ = novoNo(3, lista, strdup(val), NULL);

				free(val);
				val = NULL;




				TabSimbolos item1 = buscaTabNome(strdup($1->valor));
				TabSimbolos item2 = buscaTabNome(strdup($3->valor));
				int isInt = 0;
				int erro = 0;
				float fval1, fval2, fvalfinal;
				int ival1, ival2, ivalfinal;
				if(item1->tipo != Inteiro && item1->tipo != Decimal || item2->tipo != Inteiro && item2->tipo != Decimal){
					printf("\t### ERRO: expressao [%s] com tipos incorretos [%d][%d]\n", $2->valor, $1->linha, $1->coluna);
					erro = 1;
					$$->tipo = other;
				}
				else{
					if(item1->tipo == Decimal || item2->tipo == Decimal){
						fval1 = atof(item1->valor);
						fval2 = atof(item2->valor);
						isInt = 0;
						$$->tipo = Decimal;
					}
					else if(item1->tipo == Inteiro && item2->tipo == Inteiro){
						ival1 = atoi(item1->valor);
						ival2 = atoi(item2->valor);
						isInt = 1;
						$$->tipo = Inteiro;
					}
				}




				switch($2->valor[0]){
					case '+':
						if(isInt == 1){
							ivalfinal = ival1 + ival2;
						}
						else{
							fvalfinal = fval1 + fval2;
						}
						break;
					case '-':
						if(isInt == 1){
							ivalfinal = ival1 - ival2;
						}
						else{
							fvalfinal = fval1 - fval2;
						}
						break;
					default:
						printf("\t### ERRO: %s operador nao encontrado [%d][%d]\n", $2->valor, $2->linha, $2->coluna);
						erro = 1;
						break;
				}

				/*char* val2;
				if(erro != 1){
					if(isInt == 1){
						val2 = (char*) malloc(sizeof(char) * contDigtf(ivalfinal) + 1);
						sprintf(val2, "%d", ivalfinal);
					}
					else{
						val2 = (char*) malloc(sizeof(char) * contDigtf(fvalfinal) + 1);
						sprintf(val2, "%lf", fvalfinal);
					}
				}

				val2 = NULL;*/
			}
			;


termo:
			factor {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;

				$$ = novoNo(1, lista, strdup($1->valor), NULL);
				$$->tipo = $1->tipo;
			}
			| factor mulop termo {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;

				char* val = (char*) malloc(sizeof(char) * (strlen($1->valor) + strlen($2->valor) + strlen($3->valor)) + 1);
				strcat(val, strdup($1->valor));
				strcat(val, strdup($2->valor));
				strcat(val, strdup($3->valor));

				$$ = novoNo(3, lista, strdup(val), NULL);

				free(val);
				val = NULL;




				TabSimbolos item1 = buscaTabNome(strdup($1->valor));
				TabSimbolos item2 = buscaTabNome(strdup($3->valor));
				int isInt = 0;
				int erro = 0;
				float fval1, fval2, fvalfinal;
				int ival1, ival2, ivalfinal;
				if(item1->tipo != Inteiro && item1->tipo != Decimal || item2->tipo != Inteiro && item2->tipo != Decimal){
					printf("\t### ERRO: expressao com tipos incompativeis [%d][%d]\n", $1->linha, $1->coluna);
					erro = 1;
					$$->tipo = other;
				}
				else{
					if(item1->tipo == Decimal || item2->tipo == Decimal){
						fval1 = atof(item1->valor);
						fval2 = atof(item2->valor);
						isInt = 0;
						$$->tipo = Decimal;
					}
					else if(item1->tipo == Inteiro && item2->tipo == Inteiro){
						ival1 = atoi(item1->valor);
						ival2 = atoi(item2->valor);
						isInt = 1;
						$$->tipo = Inteiro;
					}
				}

				switch($2->valor[0]){
					case '*':
						if(isInt == 1){
							ivalfinal = ival1 * ival2;
						}
						else{
							fvalfinal = fval1 * fval2;
						}
						break;
					case '/':
						if(isInt == 1){
							if(ival2 == 0){
								printf("\t### ERRO [%d / %d] divisão por zero. [%d][%d]\n", ival1, ival2, $1->linha, $1->coluna);
							}
							else{
								ivalfinal = ival1 / ival2;
							}
						}
						else{
							if(fval2 == 0){
								printf("\t### ERRO [%f / %f] divisão por zero. [%d][%d]\n", fval1, fval2, $1->linha, $1->coluna);
							}
							else{
								fvalfinal = fval1 / fval2;
							}
						}
						break;
					default:
						printf("\t### ERRO: [%s] operador nao encontrado [%d][%d]\n", $2->valor, $2->linha, $2->coluna);
						erro = 1;
						break;
				}

				/*char* val2;
				if(erro != 1){
					if(isInt == 1){
						val2 = (char*) malloc(sizeof(char) * contDigtf(ivalfinal) + 1);
						sprintf(val2, "%d", ivalfinal);
					}
					else{
						val2 = (char*) malloc(sizeof(char) * contDigtf(fvalfinal) + 1);
						sprintf(val2, "%lf", fvalfinal);
					}
				}

				val2 = NULL;*/
			}
			;


factor:
			INI_PARAM expressao FIM_PARAM {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $2;
				
				char* val = (char*) malloc(sizeof(char) * (1 + strlen($2->valor) + 1) + 1);
				strcat(val, "(");
				strcat(val, strdup($2->valor));
				strcat(val, ")");
				
				$$ = novoNo(1, lista, strdup(val), NULL);
				$$->tipo = $2->tipo;

				free(val);
				val = NULL;
			}
			| endereco {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);


				TabSimbolos item = buscaTabNome(strdup($1->valor));
				item->isEnd = 1;
				$$->tipo = item->tipo;
			}
			| var {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);



				TabSimbolos item = buscaTabNome(strdup($1->valor));
				$$->tipo = item->tipo;
			}
			| chamada {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);

				TabSimbolos item = buscaTabNome(strdup($1->valor));
				if(item != NULL){
					$$->tipo = item->tipo;
				}
				else{
					$$->tipo = other;
				}
			}
			| num {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);

				TabSimbolos item = buscaTabVal($1->valor);
				$$->tipo = item->tipo;
			}
			| LITERAL {
				$$ = novaFolhaText(strdup($1));
				$$->tipo = Literal;
				insere("texto", strdup($$->valor), OTHER, Literal, 0, NULL);
			}
			;

endereco:
			ACESSO_END var {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("&");
				lista[1] = $2;

				char* val = (char*) malloc(sizeof(char) * strlen($2->valor) + 1);
				strcat(val, strdup($2->valor));
				$$ = novoNo(2, lista, strdup(val), NULL);


				TabSimbolos item = buscaTabNome(strdup($2->valor));
				if(item != NULL){
					item->isEnd = 1;
					$$->tipo = item->tipo;
				}


				free(val);
				val = NULL;
			}
			;

chamada:
			nome_func INI_PARAM arg FIM_PARAM{
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $3;

				int size = (strlen($1->valor) + 1 + ($3 != NULL ? ($3->valor != NULL ? strlen($3->valor) : 0) : 0) + 1);
				char* val = (char*) malloc(sizeof(char) * (size) + 1);
				strcat(val, strdup($1->valor));
				strcat(val, "(");
				if($3 != NULL){
					strcat(val, strdup($3->valor));
				}
				strcat(val, ")");
				$$ = novoNo(2, lista, strdup(val), NULL);

				free(val);
				val = NULL;




				TabSimbolos item = buscaTabNome(strdup($1->valor));

				if(item == NULL){
					printf("\t### ERRO: [%s] funcao nao declarada [%d][%d]\n", $1->valor, $1->linha, $1->coluna);
				}
				else{
					$$->tipo = item->tipo;


					if(item->params != NULL && ($3 != NULL ? ($3->valor != NULL ? $3->valor : NULL) : NULL) == NULL ){ // se param eh nulo e os agrs nao
						printf("\t### ERRO: [%s] funcao faltando argumentos [%d][%d]\n", $1->valor, $1->linha, $1->coluna);
					}
					else if(item->params == NULL && ($3 != NULL ? ($3->valor != NULL ? $3->valor : NULL) : NULL) != NULL ){ // se param nao eh nulo, mas os args sao
						printf("\t### ERRO: [%s] funcao [%s] nao deveria conter argumentos [%d][%d]\n", $3->valor, item->nome, $3->linha, $3->coluna);
					}
					else{
					
						Parametro* parametro = item->params;
						Parametro* argumento = $3->params;

						char* tipo_lido;
						char* tipo_esperado;
						while(parametro != NULL){
							switch(parametro->tipo){
								case Inteiro:
									tipo_esperado = (char*) malloc(sizeof(char) * 4);
									tipo_esperado = "int";
									break;

								case Decimal:
									tipo_esperado = (char*) malloc(sizeof(char) * 6);
									tipo_esperado = "float";
									break;

								case Ponto:
									tipo_esperado = (char*) malloc(sizeof(char) * 6);
									tipo_esperado = "point";
									break;

								case Forma:
									tipo_esperado = (char*) malloc(sizeof(char) * 6);
									tipo_esperado = "shape";
									break;
							
								case Literal:
									tipo_esperado = (char*) malloc(sizeof(char) * 8);
									tipo_esperado = "Literal";
									break;

								default:
									printf("\n\t### ERRO: tipo nao encontrado\n");
									break;
							}
							if(argumento != NULL){
								switch(argumento->tipo){
									case Inteiro:
										tipo_lido = (char*) malloc(sizeof(char) * 4);
										tipo_lido = "int";
										break;

									case Decimal:
										tipo_lido = (char*) malloc(sizeof(char) * 6);
										tipo_lido = "float";
										break;

									case Ponto:
										tipo_lido = (char*) malloc(sizeof(char) * 6);
										tipo_lido = "point";
										break;

									case Forma:
										tipo_lido = (char*) malloc(sizeof(char) * 6);
										tipo_lido = "shape";
										break;
								
									case Literal:
										tipo_lido = (char*) malloc(sizeof(char) * 8);
										tipo_lido = "Literal";
										break;

									default:
										printf("\n\t### ERRO: tipo nao encontrado\n");
										break;
								}
								if(parametro->tipo != argumento->tipo){
									printf("\t### ERRO: [%s] tipo do argumento incompativel, para a funcao [%s], esperado [%s] [%d][%d]\n", tipo_lido, $1->valor, tipo_esperado, $3->linha, $3->coluna);
								}
								if(parametro->isEnd != argumento->isEnd){
									if(parametro->isEnd == 0){
										printf("\t### ERRO: [%s] argumento deve ser um endereco [%d][%d]\n", argumento->nome != NULL ? argumento->nome : "", $3->linha, $3->coluna);
									}
									else{
										printf("\t### ERRO: [%s] argumento nao pode ser um endereco [%d][%d]\n", argumento->nome != NULL ? argumento->nome : "", $3->linha, $3->coluna);
									}
								}

								Contexto* ctx_temp = ctx_atual;
								int isNome = 1; // Sim, por nome
								Simbolo* arg_passado = buscaAquiNome(argumento->nome);
								if(arg_passado == NULL){
									isNome = 0; // Nao, por valor
									arg_passado = buscaAquiVal(argumento->nome);
								}
								if(arg_passado != NULL){
									if(strcmp(arg_passado->nome != NULL ? arg_passado->nome : "" , "") == 0 ){
										isNome = 0; // Nao, por valor
									}
									if(isNome == 0 && strcmp(arg_passado->valor != NULL ? arg_passado->valor : "" , "") == 0 ){
										isNome = -1; // Nao, nenhum
									}
									if(item->interno != NULL){
										ctx_atual = item->interno;

										Simbolo* arg_recebido;
										arg_recebido = buscaAquiNome(parametro->nome);

										if(arg_recebido != NULL){
											if(arg_recebido->isEnd == 1){
												arg_recebido = arg_passado;
											}

											if(strcmp(arg_passado->valor != NULL ? arg_passado->valor : "", "") != 0){
												arg_recebido->valor = (char*) malloc(sizeof(char) * strlen(arg_passado->valor) + 1);
												strcpy(arg_recebido->valor, arg_passado->valor != NULL ? arg_passado->valor : "");
											}

										}

										ctx_atual = ctx_temp;
									}


								}


							}
							else{
								printf("\t### ERRO: [%s] argumentos a menos. Esperado [%s]. A funcao [%s] exige os seguintes argumentos: (", tipo_lido != NULL ? tipo_lido : "", tipo_esperado, item->nome);
								parametro = item->params;
								while(parametro != NULL){
									switch(parametro->tipo){
										case Inteiro:
											printf("int");
											break;

										case Decimal:
											printf("float");
											break;

										case Ponto:
											printf("point");
											break;

										case Forma:
											printf("shape");
											break;
									
										case Literal:
											printf("Literal");
											break;

										default:
											printf("\n\t### ERRO: tipo nao encontrado\n");
											break;
									}
									parametro = parametro->prox;
									if(parametro != NULL){
										printf(", ");
									}
								}
								printf(") [%d][%d]\n", $3->linha, $3->coluna);
								break;
							}


							parametro = parametro->prox;
							argumento = argumento->prox;
						}
						if(parametro == NULL && argumento != NULL){
							printf("\t### ERRO: mais argumentos que o exigido. A funcao [%s] exige os parametros: (", item->nome);
							parametro = item->params;
							while(parametro != NULL){
								switch(parametro->tipo){
									case Inteiro:
										printf("int");
										break;

									case Decimal:
										printf("float");
										break;

									case Ponto:
										printf("point");
										break;

									case Forma:
										printf("shape");
										break;
								
									case Literal:
										printf("Literal");
										break;

									default:
										printf("\n\t### ERRO: tipo nao encontrado\n");
										break;
								}

								parametro = parametro->prox;
								if(parametro != NULL){
									printf(", ");
								}
							}
							printf(") [%d][%d]\n", $3->linha, $3->coluna);
						}
					}
				}
			}
			;

nome_func:
			PRINTINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printInt");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| PRINTFLOAT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printFloat");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| PRINTPOINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printPoint");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| PRINTSHAPE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("printShape");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| SCANINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("scanInt");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| SCANFLOAT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("scanFloat");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| CONSTROIPOINT {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("constroiPoint");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| CONSTROISHAPE {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("constroiShape");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| PERIMETRO {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("Perimetro");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Decimal;
			}
			| ISIN {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("IsIn");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| ISCOLLIDED {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("IsCollided");
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Inteiro;
			}
			| ID {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText(strdup($1));
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
				Parametro* parametro = $1->params;
				TYPE tipo = $1->tipo;
				$$ = novoNo(1, lista, strdup($1->valor), parametro);
				$$->tipo = tipo;
			}
			;


lista_arg:
			expressao {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;

				if($1 != NULL){
					Parametro* parametro = (Parametro*) malloc(sizeof(Parametro));
					parametro->tipo = $1->tipo;
					parametro->nome = strdup($1->valor);

					if($1->valor[0] == '&'){
						parametro->isEnd = 1;
					}

					parametro->prox = NULL;

					TYPE tipo = $1->tipo;
					$$ = novoNo(1, lista, strdup($1->valor), parametro);
					$$->tipo = tipo;
				}
				else{
					$$ = NULL;
				}
			}
			| expressao SEPARA_ARG lista_arg {
				Node** lista = (Node**) malloc(sizeof(Node*) * 2);
				lista[0] = $1;
				lista[1] = $3;
				char* val = (char*) malloc(sizeof(char) * (strlen($1->valor) + 1 + strlen($3->valor)) + 1);
				strcat(val, strdup($1->valor));
				strcat(val, ",");
				strcat(val, strdup($3->valor));


				Parametro* parametro = (Parametro*) malloc(sizeof(Parametro));
				
				
				int i = 0, chave = 0;
				TabSimbolos item = buscaTabVal($1->valor);
				if(item == NULL){
					item = buscaTabNome(strdup($1->valor));
				}



				parametro->tipo = item->tipo;
				parametro->nome = strdup($1->valor);

				if($1->valor[0] == '&'){
					parametro->isEnd = 1;
				}


				Parametro* atual = parametro;
				while(atual->prox != NULL){
					atual = atual->prox;
				}
				atual->prox = $3->params;

				TYPE tipo = $1->tipo;
				$$ = novoNo(2, lista, strdup(val), parametro);
				$$->tipo = tipo;

				free(val);
				val = NULL;
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
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
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
				$$->tipo = Inteiro;

				int size = sizeof(char) * contDigf($1) + 1;
				char* valor = (char*) malloc(size);
				sprintf(valor, "%d", $1);
				insere("", valor, VAR, Inteiro, 0, NULL);
			}
			| DECIMAL {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaFloat($1);
				$$ = novoNo(1, lista, lista[0]->valor, NULL);
				$$->tipo = Decimal;

				char* valor = (char*) malloc(sizeof(char) * contDigf($1) + 1);
				gcvt($1, contDigf($1) + 1, valor);
				insere("", valor, VAR, Decimal, 0, NULL);
			}
			;




%%


// Conta digitos em um float
int contDigf(float val){
	int i = ((int) val);
	char aux;
	int count = 0;
	
	if(i == 0){ // primeiro digito da parte inteira
		count++;
	}

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
			destroiParams(raiz->params);
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

Node* novaFolhaFloat(float val){
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
	novo->valor = (char*) malloc(sizeof(char) * (contDigf((float)val) + 1));
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
	criaTab();
	yyparse();
	printArvore(raiz, 0);
	printTab();
	destroiArvore(raiz);
	destroiTab();
	return 0;
}

