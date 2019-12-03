
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
	int tac_tab(TYPE tipo, const char* nome);
	int tac(const char* val);
	
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

	typedef struct point{
		float x;
		float y;
	} point;

	typedef struct shape{
		point* p;
		int qtd;
	} shape;

	Contexto ctx_global;
	Contexto* ctx_atual;
	FILE* tac_input;
	FILE* tac_ftab;
	int tac_id = 0;
	int tac_if = 0;
	int tac_else = 0;
	int tac_for = 0;
	int tac_return = 0;
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

%token <ID> LT GT LE GE EQ NE AND OR ATR PLUS_ATR MINUS_ATR TIMES_ATR OVER_ATR PLUS_OP MINUS_OP TIMES_OP OVER_OP

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
%type <node> instruc_iterac instruc_cond instruc_else instruc_expr instrucao lista_instruc
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

				Simbolo* item = NULL;
				Simbolo* novo = buscaAquiNome(strdup($2->valor));
				if(novo != NULL){
					printf("\t\t### ERRO: [%s] declaracao de variavel ja existente. [%d][%d]\n", strdup($2->valor), $2->linha, $2->coluna);
				}
				else{
					item = insere(strdup($2->valor), "", VAR, type, 0, NULL);
				}

				strcat(val, strdup($2->valor));
				strcat(val, ";");
				$$ = novoNo(2, lista, val, NULL);
				$$->tipo = $1->tipo;
				$2->tipo = $1->tipo;


				free(val);
				val = NULL;


				// TAC insere na tabela de simbolos
				if(item != NULL){
					char* tac_nom = (char*) malloc(sizeof(char) * (strlen($2->valor) + contDigf(item->chave)) + 1);
					strcat(tac_nom, strdup($2->valor));
					char* id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
					sprintf(id_tac_nom, "%d", item->chave);
					strcat(tac_nom, id_tac_nom);
					tac_tab(type, tac_nom);
				}

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



				Simbolo* novo = buscaTabNome(strdup($2->valor));
				if(novo != NULL){
					printf("\t\t### ERRO: [%s] multipla declaracao de funcao. [%d][%d]\n", strdup($2->valor), $2->linha, $2->coluna);
				}


				Simbolo* item = insere(strdup($2->valor), "", FUNC, type, aux_qtd, $4 != NULL ? ($4->params != NULL ? $4->params : NULL) : NULL);

				ctx_atual = item->interno;
				if(ctx_atual != NULL){
					tac_id++;
				}
				else{
					ctx_atual = &ctx_global;
				}

				Parametro* temp = item->params;
				while(temp != NULL){
					insere(temp->nome, "", VAR, temp->tipo, 0, NULL);
					temp = temp->prox;
				}


				// Novo label
				char* val_fim = (char*) malloc(sizeof(char) * (strlen(item->nome) + 1) + 1);
				strcat(val_fim, item->nome);
				strcat(val_fim, ":");
				tac(val_fim);



				free(val);
				val = NULL;


			} instruc_composta {
				$$->fi[3] = $<node>6;

				if(ctx_atual->criador != NULL){
					//tac_id--;
					ctx_atual = ctx_atual->criador->meu;
				}
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
						param->tipo = Literal;
						val = (char*) malloc(sizeof(char) * (8 + strlen($2->valor)) + 1);
						strcat(val, "Literal ");
						break;
				}
				param->nome = strdup($2->valor);
				param->isEnd = 1;
				param->prox = NULL;


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
				$$->tipo = $1->tipo;
				$2->tipo = $1->tipo;

				free(val);
				val = NULL;

			}
			;

instruc_composta:
			INI_INSTRUC decl_local lista_instruc instruc_return FIM_INSTRUC {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $2;
				lista[1] = $3;
				lista[2] = $4;

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
				$$ = novoNo(3, lista, strdup(val), NULL);

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
			IF INI_PARAM expressao FIM_PARAM INI_INSTRUC {
				// TAC condicional
				tac("// Instrucao if");
				// brz $0 L1
				char* label = (char*) malloc(sizeof(char) * (10 + contDigf(tac_if)) + 1);
				strcat(label, "brz $0, IF");
				char* num_if = (char*) malloc(sizeof(char) * contDigf(tac_if) + 1);
				sprintf(num_if, "%d", tac_if);
				strcat(label, num_if);
				tac(label);


			} instrucao FIM_INSTRUC {
				// FIM DO IF
				// Nova label
				char* go = (char*) malloc(sizeof(char) * (2 + contDigf(tac_if) + 1) + 1);
				char* num_if = (char*) malloc(sizeof(char) * contDigf(tac_if) + 1);
				sprintf(num_if, "%d", tac_if);

				strcat(go, "IF");
				strcat(go, num_if++);
				strcat(go, ":");
				tac(go);

				tac("// Fim if");
			} instruc_else {
				Node** lista = (Node**) malloc(sizeof(Node*) * ($<node>8 != NULL ? 5 : 3));
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("if");
				lista[1] = $<node>3;
				lista[2] = $<node>6;

				size_t tam = 3 + strlen($<node>3->valor) + 1;
				// if($<node>8 == NULL){
				// 	lista[3] = (Node*) malloc(sizeof(Node));
				// 	lista[3] = novaFolhaText("else");
				// 	lista[4] = $<node>8;
				// 	tam += 5;
				// 	if(strcmp($<node>8->valor != NULL ? $<node>8->valor : "", "") != 0){
				// 		tam += strlen($<node>8->valor != NULL ? $<node>8->valor : "");
				// 	}
				// }
				char* val = (char*) malloc(sizeof(char) * (tam) + 1);
				strcat(val, "if(");
				strcat(val, strdup($<node>3->valor));
				strcat(val, ")");
				// if($<node>8 == NULL){
				// 	strcat(val, "else ");
				// 	strcat(val, $<node>8->valor != NULL ? $<node>8->valor : "");
				// }
				$$ = novoNo(3, lista, strdup(val), NULL);

				free(val);
				val = NULL;


				// L1

				$$ = novoNo(3, lista, "IF ( expressao ) { instrucao } ", NULL);
			}
			;

instruc_else:
			/* empty */ {
				$$ = NULL;
			}
			| ELSE INI_INSTRUC instrucao FIM_INSTRUC {
				$$ = $3;
			}
			;


instruc_iterac:
			FOR INI_PARAM {
				// TAC inicia for
				tac("// Laco FOR");
			} expressao FIM_EXPRESS {
				// TAC cria label para loop (checa condicao)
				// CONDFOR:
				char* tac_label1 = (char*) malloc(sizeof(char) * (7 + contDigf(tac_for) + 1) + 1);
				char* label_id = (char*) malloc(sizeof(char) * contDigf(tac_for) + 1);
				sprintf(label_id, "%d", tac_for);
				strcat(tac_label1, "CONDFOR");
				strcat(tac_label1, label_id);
				strcat(tac_label1, ":");
				tac(tac_label1);

			} express_simp FIM_EXPRESS{

				char* label_id = (char*) malloc(sizeof(char) * contDigf(tac_for) + 1);
				sprintf(label_id, "%d", tac_for);

				// TAC se a condicao for falsa, sai do loop
				// brz $0, FIMFOR
				char* tac_label2 = (char*) malloc(sizeof(char) * (4 + 4 + 6 + contDigf(tac_for)) + 1);
				strcat(tac_label2, "brz $0, FIMFOR");
				strcat(tac_label2, label_id);
				tac(tac_label2);

				// TAC se a condicao for verdadeira, vai pro corpo
				// jump CORPOFOR
				char* tac_label3 = (char*) malloc(sizeof(char) * (5 + 8 + contDigf(tac_for)) + 1);
				strcat(tac_label3, "jump CORPOFOR");
				strcat(tac_label3, label_id);
				tac(tac_label3);

				// TAC cria label para incremento (terceira expressao do for)
				// INCRFOR:
				char* tac_label4 = (char*) malloc(sizeof(char) * (7 + contDigf(tac_for) + 1) + 1);
				strcat(tac_label4, "INCRFOR");
				strcat(tac_label4, label_id);
				strcat(tac_label4, ":");
				tac(tac_label4);


			} expressao FIM_PARAM {
				// TAC depois de incrementar vai pro corpo
				char* tac_label = (char*) malloc(sizeof(char) * (5 + 7 + contDigf(tac_for)) + 1);
				char* label_id = (char*) malloc(sizeof(char) * contDigf(tac_for) + 1);
				sprintf(label_id, "%d", tac_for);
				strcat(tac_label, "jump CONDFOR");
				strcat(tac_label, label_id);
				tac(tac_label);

				// TAC cria label para CORPO do for
				// CORPOFOR:
				char* tac_label1 = (char*) malloc(sizeof(char) * (8 + contDigf(tac_for) + 1) + 1);
				strcat(tac_label1, "CORPOFOR");
				strcat(tac_label1, label_id);
				strcat(tac_label1, ":");
				tac(tac_label1);

			} INI_INSTRUC instrucao FIM_INSTRUC {
				Node** lista = (Node**) malloc(sizeof(Node*) * 5);
				lista[0] = (Node*) malloc(sizeof(Node));
				lista[0] = novaFolhaText("for");
				lista[1] = $<node>3;
				lista[2] = $<node>5;
				lista[3] = $<node>7;
				lista[4] = $<node>10;


				char* val = (char*) malloc(sizeof(char) * (3)+1); /*+
												strlen($<node>3 != NULL ? (strcmp($<node>3->valor != NULL ? $<node>3->valor : "", "") != 0 ? $<node>3->valor : "") : "")
												+ strlen($<node>5 != NULL ? (strcmp($<node>5->valor != NULL ? $<node>5->valor : "", "") != 0 ? $<node>5->valor : "") : "")
												+ strlen($<node>7 != NULL ? (strcmp($<node>7->valor != NULL ? $<node>7->valor : "", "") != 0 ? $<node>7->valor : "") : "")
												+ 3) + 1);*/
				strcat(val, "for");
				// strcat(val, "(");
				// strcat(val, strdup($<node>3 != NULL ? (strcmp($<node>3->valor != NULL ? $<node>3->valor : "", "") != 0 ? $<node>3->valor : "") : ""));
				// strcat(val, ";");
				// strcat(val, strdup($<node>5 != NULL ? (strcmp($<node>5->valor != NULL ? $<node>5->valor : "", "") != 0 ? $<node>5->valor : "") : ""));
				// strcat(val, ";");
				// strcat(val, strdup($<node>7 != NULL ? (strcmp($<node>7->valor != NULL ? $<node>7->valor : "", "") != 0 ? $<node>7->valor : "") : ""));
				// strcat(val, ")");
				$$ = novoNo(5, lista, strdup(val), NULL);

				free(val);
				val = NULL;


				// TAC depois de executar o corpo vai pro INCREMENTO
				char* tac_label = (char*) malloc(sizeof(char) * (5 + 7 + contDigf(tac_for)) + 1);
				char* label_id = (char*) malloc(sizeof(char) * contDigf(tac_for) + 1);
				sprintf(label_id, "%d", tac_for);
				strcat(tac_label, "jump INCRFOR");
				strcat(tac_label, label_id);
				tac(tac_label);

				// TAC cria label para FIM do for
				// FIMFOR:
				char* tac_label1 = (char*) malloc(sizeof(char) * (6 + contDigf(tac_for) + 1) + 1);
				strcat(tac_label1, "FIMFOR");
				strcat(tac_label1, label_id);
				strcat(tac_label1, ":");
				tac(tac_label1);
				tac_for++;

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



				Simbolo* item = buscaTabNome(strdup($2->valor));
				if(item != NULL ? (strcmp(item->nome != NULL ? item->nome : "", "main") != 0) : 0){
					char* tac_val;
					if(item == NULL){
						tac_val = (char*) malloc(sizeof(char) * (7 + strlen($2->valor)) + 1);
						strcat(tac_val, "return ");
						strcat(tac_val, strdup($2->valor));
						tac(tac_val);
					}
					else{
						tac_val = (char*) malloc(sizeof(char) * (7 + strlen(item->nome) + contDigf(item->chave)) + 1);
						strcat(tac_val, "return ");
						strcat(tac_val, strdup(item->nome));
						char* id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
						sprintf(id_tac_nom, "%d", item->chave);
						strcat(tac_val, id_tac_nom);
						tac(tac_val);
					}
				}
				else{
					tac("println 0");
				}

				if(ctx_atual != NULL && ctx_atual->criador != NULL){
					if(strcmp(ctx_atual->criador->valor != NULL ? ctx_atual->criador->valor : "", "") != 0){
						free(ctx_atual->criador->valor);
					}
					ctx_atual->criador->valor = (char*) malloc(sizeof(char) * strlen(item != NULL ? (item->valor != NULL ? item->valor : "") : $2->valor) + 1);
					strcpy(ctx_atual->criador->valor, item != NULL ? (strcmp(item->valor != NULL ? item->valor : "", "") != 0 ? item->valor : "") : $2->valor);
				}
			}
			;

expressao:
			var atrop express_simp {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;

				char* op = (char*) malloc(sizeof(char) * strlen($2->valor) + 1);
				op = strdup($2->valor);

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
				if(item == NULL || (item2 == NULL)){
					if(item == NULL){
						printf("\t### ERRO: [%s] uso de variavel nao declarada. [%d][%d]\n", $1->valor, $1->linha, $1->coluna);
					}
					if(item2 == NULL){
						printf("\t### ERRO: [%s] expressao nao encontrada. [%d][%d]\n", $2->valor, $2->linha, $2->coluna);
					}
				}
				else{
					$1->tipo = item->tipo;
					$$->tipo = item->tipo;

					if($1->valor[0] == '\"'){
						$$->tipo = Literal;
					}

					char* val1;
					char* val2;
					int tmpi;
					float tmpf;

					TYPE tipo_express_simp = $3->tipo;
					if(item->tipo == Inteiro && tipo_express_simp == Decimal){
						printf("\t### ADVERTENCIA: [%s] expressao truncada para atribuicao. [%d][%d]\n", item->nome, $1->linha, $1->coluna);


						tmpf = atof(item2->valor);
						tmpi = (int) tmpf;
						val2 = (char*) malloc(sizeof(char) * contDigf(tmpi) + 1);
						sprintf(val2, "%d", tmpi);

						val1 = (char*) malloc(sizeof(char) * strlen(item->valor != NULL ? item->valor : "") + 1);
						val1 = strdup(item->valor != NULL ? item->valor : "");

					}
					else if(item->tipo == Decimal && tipo_express_simp == Inteiro){
						// Converte tipos
						tmpi = atoi(item2->valor);
						tmpf = (float) tmpi;
						val2 = (char*) malloc(sizeof(char) * contDigf(tmpf) + 1);
						gcvt(tmpf, contDigf(tmpf) + 1, val2);

						val1 = (char*) malloc(sizeof(char) * strlen(item->valor != NULL ? item->valor : "") + 1);
						val1 = strdup(item->valor != NULL ? item->valor : "");
					}
					else{
						val1 = (char*) malloc(sizeof(char) * strlen(item->valor != NULL ? item->valor : "") + 1);
						val2 = (char*) malloc(sizeof(char) * strlen(item2->valor != NULL ? item2->valor : "") + 1);
						val1 = strdup(item->valor != NULL ? item->valor : "");
						val2 = strdup(item2->valor != NULL ? item2->valor : "");
					}


					if((item->tipo != Decimal && item->tipo != Inteiro) || (tipo_express_simp != Inteiro && tipo_express_simp != Decimal)){
						printf("\t### ERRO: [%s] tipo incompativel para atribuicao. [%d][%d]\n", item->nome, $1->linha, $1->coluna);
					}
					else{
						if(item2->isVar == FUNC || strcmp(item2->valor != NULL ? item2->valor : "", "") != 0){

							if(item2->isVar == FUNC){
								char* atr_func = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + 2) + 1);
								char* atr_key= (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
								sprintf(atr_key, "%d", item->chave);
								strcat(atr_func, "mov ");
								strcat(atr_func, item->nome);
								strcat(atr_func, atr_key);
								strcat(atr_func, ", ");
								strcat(atr_func, "$0");
								tac(atr_func);
							}
							else{


								float temp_val_f;
								int temp_val_i;
								char* tmp_nom;
								char* temp_add;
								char* id_tac_nom;
								char* id_tac_nom2;
								char* chave;

								if(item2->tipo == Inteiro){
									temp_val_i = atoi(item2->valor);
								}
								if(item2->tipo == Decimal){
									temp_val_f = atof(item2->valor);
								}


								// TAC ATRIBUI
								switch($2->valor[0]){
									case '=':
										if(strcmp(item->valor != NULL ? item->valor : "", "") != 0){
											free(item->valor);
										}
										item->valor = (char*) malloc(sizeof(char) * strlen(val2) + 1);
										item->valor = strdup(val2);

										// mov dest, val
										if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
											tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item2->nome) + contDigf(item2->chave)) + 1);
											strcat(tmp_nom, "mov ");
											strcat(tmp_nom, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(tmp_nom, id_tac_nom);
											strcat(tmp_nom, ", ");
											strcat(tmp_nom, item2->nome);
											id_tac_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
											sprintf(id_tac_nom2, "%d", item2->chave);
											strcat(tmp_nom, id_tac_nom2);
											tac(tmp_nom);
										}
										else{
											tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item->valor)) + 1);
											strcat(tmp_nom, "mov ");
											strcat(tmp_nom, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(tmp_nom, id_tac_nom);
											strcat(tmp_nom, ", ");
											strcat(tmp_nom, item->valor);
											tac(tmp_nom);
										}
										break;

									case '+':
										if(item->tipo == Decimal || item2->tipo == Decimal){
											temp_val_f = atof(val1) + atof(val2);
											item->valor = (char*) malloc(sizeof(char) * contDigf(temp_val_f) + 1);
											gcvt(temp_val_f, contDigf(temp_val_f) + 1, item->valor);
										}
										else{
											temp_val_i = atoi(val1) + atoi(val2);
											if(strcmp(item->valor != NULL ? item->valor : "", "") == 0){
												free(item->valor);
											}
											item->valor = (char*) malloc(sizeof(char) * contDigf(temp_val_i) + 1);
											sprintf(item->valor, "%d", temp_val_i);
										}

										// add $0, item1, item2 (nome ou valor)
										// mov item1, $0
										if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item2->nome) + contDigf(item2->chave)) + 1);
											strcat(temp_add, "add $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											strcat(temp_add, item2->nome);
											id_tac_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
											sprintf(id_tac_nom2, "%d", item2->chave);
											strcat(temp_add, id_tac_nom2);
											tac(temp_add);
										}
										else{
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item->valor)) + 1);
											strcat(temp_add, "add $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											strcat(temp_add, item->valor);
											tac(temp_add);
										}

										// TAC mov item1, $0
										char* chave = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
										sprintf(chave, "%d", item->chave);
										tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + 2) + 1);
										strcat(tmp_nom, "mov ");
										strcat(tmp_nom, item->nome);
										strcat(tmp_nom, chave);
										strcat(tmp_nom, ", $0");
										tac(tmp_nom);

										break;

									case '-':
										if(item->tipo == Decimal || item2->tipo == Decimal){
											temp_val_f = atof(val1) - atof(val2);
											item->valor = (char*) malloc(sizeof(char) * contDigf(temp_val_f) + 1);
											gcvt(temp_val_f, contDigf(temp_val_f) + 1, item->valor);
										}
										else{
											temp_val_i = atoi(val1) - atoi(val2);
											if(strcmp(item->valor != NULL ? item->valor : "", "") == 0){
												free(item->valor);
											}
											item->valor = (char*) malloc(sizeof(char) * contDigf(temp_val_i) + 1);
											sprintf(item->valor, "%d", temp_val_i);
										}

										// sub $0, item1, item2 (nome ou valor)
										// mov item1, $0
										if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item2->nome) + contDigf(item2->chave)) + 1);
											strcat(temp_add, "sub $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											strcat(temp_add, item2->nome);
											id_tac_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
											sprintf(id_tac_nom2, "%d", item2->chave);
											strcat(temp_add, id_tac_nom2);
											tac(temp_add);
										}
										else{
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item->valor)) + 1);
											strcat(temp_add, "sub $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											strcat(temp_add, item->valor);
											tac(temp_add);
										}

										// TAC mov item1, $0
										chave = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
										sprintf(chave, "%d", item->chave);
										tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + 2) + 1);
										strcat(tmp_nom, "mov ");
										strcat(tmp_nom, item->nome);
										strcat(tmp_nom, chave);
										strcat(tmp_nom, ", $0");
										tac(tmp_nom);

										break;

									case '*':
										if(item->tipo == Decimal || item2->tipo == Decimal){
											temp_val_f = atof(val1) * atof(val2);
											item->valor = (char*) malloc(sizeof(char) * contDigf(temp_val_f) + 1);
											gcvt(temp_val_f, contDigf(temp_val_f) + 1, item->valor);
										}
										else{
											temp_val_i = atoi(val1) * atoi(val2);
											if(strcmp(item->valor != NULL ? item->valor : "", "") == 0){
												free(item->valor);
											}
											item->valor = (char*) malloc(sizeof(char) * contDigf(temp_val_i) + 1);
											sprintf(item->valor, "%d", temp_val_i);
										}

										// mul $0, item1, item2 (nome ou valor)
										// mov item1, $0
										if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item2->nome) + contDigf(item2->chave)) + 1);
											strcat(temp_add, "mul $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											strcat(temp_add, item2->nome);
											id_tac_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
											sprintf(id_tac_nom2, "%d", item2->chave);
											strcat(temp_add, id_tac_nom2);
											tac(temp_add);
										}
										else{
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item->valor)) + 1);
											strcat(temp_add, "mul $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											strcat(temp_add, item->valor);
											tac(temp_add);
										}

										// TAC mov item1, $0
										chave = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
										sprintf(chave, "%d", item->chave);
										tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + 2) + 1);
										strcat(tmp_nom, "mov ");
										strcat(tmp_nom, item->nome);
										strcat(tmp_nom, chave);
										strcat(tmp_nom, ", $0");
										tac(tmp_nom);

										break;

									case '/':
										if(atof(val2) == 0){
											printf("\t\t### ERRO: [%s] divisao por 0. [%d][%d]\n", item2->valor, $2->linha, $2->coluna);
											free(item->valor);
											if(item->tipo == Decimal || item2->tipo == Decimal){
												temp_val_f = atof(val2);
												item->valor = (char*) malloc(sizeof(char) * contDigf(temp_val_f) + 1);
												gcvt(temp_val_f, contDigf(temp_val_f) + 1, item->valor);
											}
											else{
												temp_val_i = atoi(val2);
												if(strcmp(item->valor != NULL ? item->valor : "", "") == 0){
													free(item->valor);
												}
												item->valor = (char*) malloc(sizeof(char) * contDigf(temp_val_i) + 1);
												sprintf(item->valor, "%d", temp_val_i);
											}

											// mov dest, val
											char* tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item->valor)) + 1);
											strcat(tmp_nom, "mov ");
											strcat(tmp_nom, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(tmp_nom, id_tac_nom);
											strcat(tmp_nom, ", ");
											strcat(tmp_nom, item->valor);
											tac(tmp_nom);
										}
										else{
											if(item->tipo == Decimal || item2->tipo == Decimal){
												temp_val_f = atof(val1) / atof(val2);
												item->valor = (char*) malloc(sizeof(char) * contDigf(temp_val_f) + 1);
												gcvt(temp_val_f, contDigf(temp_val_f) + 1, item->valor);
											}
											else{
												temp_val_i = atoi(val1) / atoi(val2);
												if(strcmp(item->valor != NULL ? item->valor : "", "") == 0){
													free(item->valor);
												}
												item->valor = (char*) malloc(sizeof(char) * contDigf(temp_val_i) + 1);
												sprintf(item->valor, "%d", temp_val_i);
											}

											// div $0, item1, item2 (nome ou valor)
											// mov item1, $0
											if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
												temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item2->nome) + contDigf(item2->chave)) + 1);
												strcat(temp_add, "div $0, ");
												strcat(temp_add, item->nome);
												id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
												sprintf(id_tac_nom, "%d", item->chave);
												strcat(temp_add, id_tac_nom);
												strcat(temp_add, ", ");
												strcat(temp_add, item2->nome);
												id_tac_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
												sprintf(id_tac_nom2, "%d", item2->chave);
												strcat(temp_add, id_tac_nom2);
												tac(temp_add);
											}
											else{
												temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + strlen(item->valor)) + 1);
												strcat(temp_add, "div $0, ");
												strcat(temp_add, item->nome);
												id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
												sprintf(id_tac_nom, "%d", item->chave);
												strcat(temp_add, id_tac_nom);
												strcat(temp_add, ", ");
												strcat(temp_add, item->valor);
												tac(temp_add);
											}

											// TAC mov item1, $0
											chave = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(chave, "%d", item->chave);
											tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + 2) + 1);
											strcat(tmp_nom, "mov ");
											strcat(tmp_nom, item->nome);
											strcat(tmp_nom, chave);
											strcat(tmp_nom, ", $0");
											tac(tmp_nom);
										}

										break;

									default:
										printf("[[ERRO INTERNO]]: nao encontrei o operador de atribuicao correto...\n");
										break;
								}
							}
						}
						else{
							printf("\t\t### ERRO: [%s] valor inexistente na atribuicao. [%d][%d]\n", $3->valor, $3->linha, $3->coluna);
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
				$$ = novaFolhaText(strdup($1));
				$$->tipo = other;
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

				if(($1->tipo == Inteiro || $1->tipo == Decimal) && ($3->tipo == Inteiro || $3->tipo == Decimal)){
					Simbolo* item = buscaTabNome($1->valor);
					if(item == NULL){
						item = buscaTabVal($1->valor);
					}
					Simbolo* item2 = buscaTabNome($3->valor);
					if(item2 == NULL){
						item2 = buscaTabVal($3->valor);
					}
					char* tmp_nom;
					char* tmp_add;
					char* val1;
					char* val2;
					int tmpi;
					float tmpf;
					char* aux_nom1;
					char* aux_nom2;



					if(($1->tipo == Decimal && ($3->tipo == Inteiro || $3->tipo == Decimal)) || ($3->tipo == Decimal && ($1->tipo == Inteiro || $1->tipo == Decimal))){
						$$->tipo = Decimal;
						if($1->tipo != $3->tipo){
							printf("\t### ADVERTENCIA: [%s %s %s] Operacao relacional sobre tipos distintos, inteiro e decimal. [%d][%d]\n", $1->tipo == Inteiro ? "int" : "float", $2->valor, $3->tipo == Inteiro ? "int" : "float", $2->linha, $2->coluna);

							// Converte tipos
							if($1->tipo == Decimal){
								if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
									aux_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
									sprintf(aux_nom2, "%d", item2->chave);
									val2 = (char*) malloc(sizeof(char) * (strlen(item2->nome) + contDigf(item2->chave)) + 1);
									strcat(val2, item2->nome);
									strcat(val2, aux_nom2);
								}
								else{
									// TAC converte (no caso, convertendo aqui e passando pro tac ja convertido)
									tmpi = atoi(item2->valor);
									tmpf = (float) tmpi;
									val2 = (char*) malloc(sizeof(char) * contDigf(tmpf) + 1);
									gcvt(tmpf, contDigf(tmpf) + 1, val2);
								}

								if(strcmp(item->nome != NULL ? item->nome : "", "") != 0){
									aux_nom1 = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
									sprintf(aux_nom1, "%d", item->chave);
									val1 = (char*) malloc(sizeof(char) * (strlen(item->nome) + contDigf(item->chave)) + 1);
									strcat(val1, item->nome);
									strcat(val1, aux_nom1);
								}
								else{
									val1 = (char*) malloc(sizeof(char) * strlen(item->valor) + 1);
									val1 = strdup(item->valor);
								}
							}
							else{
								if(strcmp(item->nome != NULL ? item->nome : "", "") != 0){
									aux_nom1 = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
									sprintf(aux_nom1, "%d", item->chave);
									val1 = (char*) malloc(sizeof(char) * (strlen(item->nome) + contDigf(item->chave)) + 1);
									strcat(val1, item->nome);
									strcat(val1, aux_nom1);
								}
								else{
									// TAC converte (no caso, convertendo aqui e passando pro tac ja convertido)
									tmpi = atoi(item->valor);
									tmpf = (float) tmpi;
									val1 = (char*) malloc(sizeof(char) * contDigf(tmpf) + 1);
									gcvt(tmpf, contDigf(tmpf) + 1, val1);
								}

								if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
									aux_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
									sprintf(aux_nom2, "%d", item2->chave);
									val2 = (char*) malloc(sizeof(char) * (strlen(item2->nome) + contDigf(item2->chave)) + 1);
									strcat(val2, item2->nome);
									strcat(val2, aux_nom2);
								}
								else{
									val2 = (char*) malloc(sizeof(char) * strlen(item2->valor) + 1);
									val2 = strdup(item2->valor);
								}
							}
						}
						else{
							if(strcmp(item->nome != NULL ? item->nome : "", "") != 0){
								aux_nom1 = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
								sprintf(aux_nom1, "%d", item->chave);
								val1 = (char*) malloc(sizeof(char) * (strlen(item->nome) + contDigf(item->chave)) + 1);
								strcat(val1, item->nome);
								strcat(val1, aux_nom1);
							}
							else{
								val1 = (char*) malloc(sizeof(char) * strlen(item->valor) + 1);
								val1 = strdup(item->valor);
							}

							if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
								aux_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
								sprintf(aux_nom2, "%d", item2->chave);
								val2 = (char*) malloc(sizeof(char) * (strlen(item2->nome) + contDigf(item2->chave)) + 1);
								strcat(val2, item2->nome);
								strcat(val2, aux_nom2);
							}
							else{
								val2 = (char*) malloc(sizeof(char) * strlen(item2->valor) + 1);
								val2 = strdup(item2->valor);
							}
						}



					}
					else if($1->tipo == Inteiro && $3->tipo == Inteiro){
						$$->tipo = Inteiro;

						if(strcmp(item->nome != NULL ? item->nome : "", "") != 0){
							aux_nom1 = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
							sprintf(aux_nom1, "%d", item->chave);
							val1 = (char*) malloc(sizeof(char) * (strlen(item->nome) + contDigf(item->chave)) + 1);
							strcat(val1, item->nome);
							strcat(val1, aux_nom1);
						}
						else{
							val1 = (char*) malloc(sizeof(char) * strlen(item->valor) + 1);
							val1 = strdup(item->valor);
						}
						
						if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
							aux_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
							sprintf(aux_nom2, "%d", item2->chave);
							val2 = (char*) malloc(sizeof(char) * (strlen(item2->nome) + contDigf(item2->chave)) + 1);
							strcat(val2, item2->nome);
							strcat(val2, aux_nom2);
						}
						else{
							val2 = (char*) malloc(sizeof(char) * strlen(item2->valor) + 1);
							val2 = strdup(item2->valor);
						}
					}




					// TAC COMPARA
					if(strcmp($2->valor, "<=") == 0){
						tac("// Comparacao: Menor ou igual a");
						// sleq $0, item, item2
						tmp_nom = (char*) malloc(sizeof(char) * (5 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcat(tmp_nom, "sleq $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);
					}
					else if(strcmp($2->valor, ">=") == 0){
						tac("// Comparacao: Maior ou igual a");
						// slt $1, item, item2
						// not $0, $1
						tmp_nom = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcat(tmp_nom, "slt $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);

						tmp_add = (char*) malloc(sizeof(char) * (10) + 1);
						strcat(tmp_add, "not $0, $1");
						tac(tmp_add);
					}
					else if(strcmp($2->valor, "==") == 0){
						tac("// Comparacao: Igual a");
						// seq $0, item, item2
						tmp_nom = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcat(tmp_nom, "seq $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);
					}
					else if(strcmp($2->valor, "!=") == 0){
						tac("// Comparacao: diferente de");
						// seq $1, item, item2
						// not $0, $1
						tmp_nom = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcat(tmp_nom, "seq $1, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);

						tmp_add = (char*) malloc(sizeof(char) * (10) + 1);
						strcat(tmp_add, "not $0, $1");
						tac(tmp_add);
					}
					else if(strcmp($2->valor, "&&") == 0){
						tac("// Comparacao: And logico");
						// and $0, item, item2
						tmp_nom = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcat(tmp_nom, "and $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);
					}
					else if(strcmp($2->valor, "||") == 0){
						tac("// Comparacao: Ou logico");
						// or $0, item, item2
						tmp_nom = (char*) malloc(sizeof(char) * (3 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcat(tmp_nom, "or $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);
					}
					else if(strcmp($2->valor, "<") == 0){
						tac("// Comparacao: Menor que");
						// slt $0, item, item2
						tmp_nom = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcat(tmp_nom, "slt $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);
					}
					else if(strcmp($2->valor, ">") == 0){
						tac("// Comparacao: Maior que");
						// sleq $1, item, item2
						// not $0, $1
						tmp_nom = (char*) malloc(sizeof(char) * (5 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcat(tmp_nom, "sleq $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);

						tmp_add = (char*) malloc(sizeof(char) * (10) + 1);
						strcat(tmp_add, "not $0, $1");
						tac(tmp_add);
					}



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
						val2 = (char*) malloc(sizeof(char) * contDigf(ivalfinal) + 1);
						sprintf(val2, "%d", ivalfinal);
					}
					else{
						val2 = (char*) malloc(sizeof(char) * contDigf(fvalfinal) + 1);
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
						val2 = (char*) malloc(sizeof(char) * contDigf(ivalfinal) + 1);
						sprintf(val2, "%d", ivalfinal);
					}
					else{
						val2 = (char*) malloc(sizeof(char) * contDigf(fvalfinal) + 1);
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
			ACESSO_END ID {
				char* val = (char*) malloc(sizeof(char) * (1 + strlen($2)) + 1);
				strcat(val, "&");
				strcat(val, strdup($2));
				$$ = novaFolhaText(strdup(val));
				$$->tipo = other;


				TabSimbolos item = buscaTabNome(strdup(val));
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

				int size = strlen($1->valor);
				char* val = (char*) malloc(sizeof(char) * (size) + 1);
				strcat(val, strdup($1->valor));
				// if($3 != NULL){
				// 	strcat(val, "(");
				// 	strcat(val, strdup($3->valor));
				// 	strcat(val, ")");
				// }
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
						Parametro* argumento;
						if(parametro != NULL){
							argumento = $3 != NULL ? $3->params : NULL;
						}

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
									if(parametro->tipo == Inteiro && argumento->tipo == Decimal){
										printf("\t### ADVERTENCIA: [%s] argumento truncado, para a funcao [%s], esperado [%s] [%d][%d]\n", tipo_lido, $1->valor, tipo_esperado, $3->linha, $3->coluna);
									}
									else if(parametro->tipo != Decimal && argumento->tipo != Inteiro){
										printf("\t### ERRO: [%s] tipo do argumento incompativel, para a funcao [%s], esperado [%s] [%d][%d]\n", tipo_lido, $1->valor, tipo_esperado, $3->linha, $3->coluna);
									}
								}
								if(parametro->isEnd != argumento->isEnd){
									if(parametro->isEnd == 0){
										printf("\t### ERRO: [%s] argumento deve ser um endereco [%d][%d]\n", argumento->nome != NULL ? argumento->nome : "", $3->linha, $3->coluna);
									}
									else{
										printf("\t### ERRO: [%s] argumento nao pode ser um endereco [%d][%d]\n", argumento->nome != NULL ? argumento->nome : "", $3->linha, $3->coluna);
									}
								}



								// TAC EMPILHA parametros
								char* tac_val;
								char* se_lit;
								Simbolo* item = buscaTabNome(argumento->nome);
								if(item == NULL){
									// if(argumento->nome[0] == '\"'){
									// 	tac("param texto");

									// }
									tac_val = (char*) malloc(sizeof(char) * (7 + strlen(argumento->nome)) + 1);
									strcat(tac_val, "param ");
									strcat(tac_val, strdup(argumento->nome));
									tac(tac_val);
								}
								else{
									tac_val = (char*) malloc(sizeof(char) * (7 + strlen(item->nome) + contDigf(item->chave)) + 1);
									strcat(tac_val, "param ");
									strcat(tac_val, strdup(item->nome));
									char* id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
									sprintf(id_tac_nom, "%d", item->chave);
									strcat(tac_val, id_tac_nom);
									tac(tac_val);
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
									if(isNome == 1){
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
							printf(") [%d][%d]\n", num_lin, num_char);
						}
					}



					// TAC CRIA LABEL PRA CHAMADA
					char* oper = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + 2 + contDigf(item->qtdParams)) + 1);
					strcat(oper, "call ");
					strcat(oper, item->nome);
					strcat(oper, ", ");

					char* qtdParams = (char*) malloc(sizeof(char) * contDigf(item->qtdParams) + 1);
					sprintf(qtdParams, "%d", item->qtdParams);
					strcat(oper, qtdParams);
					tac(oper);


					// TAC Desempilha retorno
					tac("pop $0");


				}
			}
			;

nome_func:
			PRINTINT {
				$$ = novaFolhaText("printInt");
				$$->tipo = Inteiro;
			}
			| PRINTFLOAT {
				$$ = novaFolhaText("printFloat");
				$$->tipo = Inteiro;
			}
			| PRINTPOINT {
				$$ = novaFolhaText("printPoint");
				$$->tipo = Inteiro;
			}
			| PRINTSHAPE {
				$$ = novaFolhaText("printShape");
				$$->tipo = Inteiro;
			}
			| SCANINT {
				$$ = novaFolhaText("scanInt");
				$$->tipo = Inteiro;
			}
			| SCANFLOAT {
				$$ = novaFolhaText("scanFloat");
				$$->tipo = Inteiro;
			}
			| CONSTROIPOINT {
				$$ = novaFolhaText("constroiPoint");
				$$->tipo = Inteiro;
			}
			| CONSTROISHAPE {
				$$ = novaFolhaText("constroiShape");
				$$->tipo = Inteiro;
			}
			| PERIMETRO {
				$$ = novaFolhaText("Perimetro");
				$$->tipo = Decimal;
			}
			| ISIN {
				$$ = novaFolhaText("IsIn");
				$$->tipo = Inteiro;
			}
			| ISCOLLIDED {
				$$ = novaFolhaText("IsCollided");
				$$->tipo = Inteiro;
			}
			| ID {
				$$ = novaFolhaText(strdup($1));
				$$->tipo = other;
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
					parametro->isEnd = 0;
					if($1->valor[0] == '&'){
						parametro->isEnd = 1;
					}

					parametro->prox = NULL;

					$$ = novoNo(1, lista, strdup($1->valor), parametro);
					$$->tipo = parametro->tipo;
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
				
				
				
				parametro->tipo = $1->tipo;
				parametro->nome = strdup($1->valor);
				parametro->isEnd = 0;
				if($1->valor[0] == '&'){
					parametro->isEnd = 1;
				}


				Parametro* atual = parametro;
				while(atual->prox != NULL){
					atual = atual->prox;
				}
				atual->prox = $3->params;

				$$ = novoNo(2, lista, strdup(val), parametro);
				$$->tipo = parametro->tipo;

				free(val);
				val = NULL;
			}
			;


atrop:
			ATR { 
				$$ = novaFolhaText("=");
				$$->tipo = other;
			}
			| PLUS_ATR {
				$$ = novaFolhaText("+=");
				$$->tipo = other;
			}
			| MINUS_ATR {
				$$ = novaFolhaText("-=");
				$$->tipo = other;
			}
			| TIMES_ATR {
				$$ = novaFolhaText("*=");
				$$->tipo = other;
			}
			| OVER_ATR {
				$$ = novaFolhaText("/=");
				$$->tipo = other;
			}
			;

relop:
			LT {
				$$ = novaFolhaText("<");
				$$->tipo = other;
			}
			| GT {
				$$ = novaFolhaText(">");
				$$->tipo = other;
			}
			| LE {
				$$ = novaFolhaText("<=");
				$$->tipo = other;
			}
			| GE {
				$$ = novaFolhaText(">=");
				$$->tipo = other;
			}
			| EQ {
				$$ = novaFolhaText("==");
				$$->tipo = other;
			}
			| NE {
				$$ = novaFolhaText("!=");
				$$->tipo = other;
			}
			| logop {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $1;
				$$ = novoNo(1, lista, strdup($1->valor), NULL);
			}
			;

logop:
			AND {
				$$ = novaFolhaText("&&");
				$$->tipo = other;
			}
			| OR {
				$$ = novaFolhaText("||");
				$$->tipo = other;
			}
			;

addop:
			PLUS_OP {
				$$ = novaFolhaText("+");
				$$->tipo = other;
			}
			| MINUS_OP {
				$$ = novaFolhaText("-");
				$$->tipo = other;
			}
			;

mulop:
			TIMES_OP {
				$$ = novaFolhaText("*");
				$$->tipo = other;
			}
			| OVER_OP {
				$$ = novaFolhaText("/");
				$$->tipo = other;
			}
			;

num:
			INTEIRO {
				$$ = novaFolhaInt($1);
				$$->tipo = Inteiro;

				int size = sizeof(char) * contDigf($1) + 1;
				char* valor = (char*) malloc(size);
				sprintf(valor, "%d", $1);
				insere("", valor, VAR, Inteiro, 0, NULL);
			}
			| DECIMAL {
				$$ = novaFolhaFloat($1);
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


int tac_tab(TYPE tipo, const char* nome){
	int ret = 0;


	// Simbolo* ctx_temp = ctx_atual->primeiro;
	// while(ctx_temp != NULL){
	// 	if(ctx_temp->isVar == VAR){
	// 		if(strcmp(ctx_temp->nome != NULL ? ctx_temp->nome : "", "") != 0){
	// 			switch(ctx_temp->tipo){
	// 				case Inteiro:
	// 					fputs("int ", tac_input);
	// 					break;

	// 				case Decimal:
	// 					fputs("float ", tac_input);
	// 					break;

	// 				case Ponto:
	// 					fputs("point ", tac_input);
	// 					break;

	// 				case Forma:
	// 					fputs("shape ", tac_input);
	// 					break;

	// 			}

	// 			fputs(ctx_temp->nome, tac_input);
	// 			fputs("\n", tac_input);
	// 		}
	// 	}
	// 	ctx_temp = ctx_temp->prox;
	// }




	// fclose(tac_input);
	// tac_input = fopen("./tac_input.txt", "wr");
	// if(tac_input == NULL){
	// 	printf("\nERRO AO ABRIR O ARQUIVO\n\n");
	// 	return 1;
	// }
	// rewind(tac_input);
	// char* linha = (char*) malloc(sizeof(char) * 100 + 1);
	// fscanf(tac_input, "%[/n]s", linha);
	// while(strcmp(linha, ".code") != 0){
	// 	if(strcmp(linha != NULL ? linha : "", "") == 0){
	// 		printf("\n\n\nACHEI!\n\n\n");
	// 		fputs("ACHEI", tac_input);
	// 		break;
	// 	}
	// 	fscanf(tac_input, "%[/n]s", linha);
	// }



	switch(tipo){
		case Inteiro:
			fputs("int ", tac_ftab);
			break;

		case Decimal:
			fputs("float ", tac_ftab);
			break;

		case Ponto:
			fputs("point ", tac_ftab);
			break;

		case Forma:
			fputs("shape ", tac_ftab);
			break;

	}
	fputs(nome, tac_ftab);
	fputs("\n", tac_ftab);


	return 0;
}

int tac(const char* val){
	char* valor = (char*) malloc(sizeof(char) * (strlen(val) + 2) + 1);
	strcat(valor, val);
	strcat(valor, "\n");
	return fputs((valor != NULL ? valor : ""), tac_input);
}

void fim_tac(){
	fclose(tac_input);
	fclose(tac_ftab);

	char ch;
	tac_input = fopen("tac_input.txt", "r");
	tac_ftab = fopen("tac_tab.txt", "a");
	while((ch = getc (tac_input)) != EOF){
		putc (ch, tac_ftab);
	}
}


int printInt(char* texto, int i){
	return printf("%s%d\n", texto, i);
}

int printFloat(char* texto, float f){
	return printf("%s%f\n", texto, f);
}

int printPoint(char* texto, point p){
	return printf("%s(x: %f, y: %f)\n", texto, p.x, p.y);
}

int printShape(char* texto, shape s){
	int retorno, i;
	for(i = 0; i < s.qtd; i++){
		retorno = printf("%s{p[%d] = (x: %f, y: %f)\n", texto, i, s.p[i].x, s.p[i].y);
	}
	return retorno;
}



Node* novoNo(int quantidade, Filhos* filhos, char* valor, Parametro* params){
	Node* novo = (Node*) malloc(sizeof(Node));
	novo->fi = filhos;
	novo->qtdFi = quantidade;
	novo->valor = strdup(valor);
	novo->linha = num_lin;
	novo->coluna = num_char;

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
	tac_input = fopen("./tac_input.txt", "w");
	tac_ftab = fopen("./tac_tab.txt", "w");
	if(tac_input == NULL || tac_ftab == NULL){
		printf("\nERRO AO ABRIR O ARQUIVO\n\n");
		return 1;
	}
	fputs(".table\n", tac_ftab);
	fputs(".code\n", tac_input);
	criaTab();
	yyparse();
	fim_tac();
	printArvore(raiz, 0);
	printTab();
	destroiArvore(raiz);
	destroiTab();
	fclose(tac_input);
	fclose(tac_ftab);
	return 0;
}

