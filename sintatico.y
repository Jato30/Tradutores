
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "./lib/TabSimbolo.h"

	#define NFUNCLING (strcmp(item->nome != NULL ? item->nome : "", "printInt") != 0 && strcmp(item->nome != NULL ? item->nome : "", "printFloat") != 0 && strcmp(item->nome != NULL ? item->nome : "", "printPoint") != 0 && strcmp(item->nome != NULL ? item->nome : "", "printShape") != 0 && strcmp(item->nome != NULL ? item->nome : "", "scanInt") != 0 && strcmp(item->nome != NULL ? item->nome : "", "scanFloat") != 0 && strcmp(item->nome != NULL ? item->nome : "", "constroiPoint") != 0 && strcmp(item->nome != NULL ? item->nome : "", "constroiShape") != 0 && strcmp(item->nome != NULL ? item->nome : "", "Perimetro") != 0 && strcmp(item->nome != NULL ? item->nome : "", "IsCollided") != 0 && strcmp(item->nome != NULL ? item->nome : "", "IsIn") != 0)

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
	int print_tac(char* texto);
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

	Contexto ctx_global;
	Contexto* ctx_atual;
	FILE* tac_input;
	FILE* tac_ftab;
	int tac_id = 0;
	int tac_str = 0;
	int tac_str2 = 0;
	int tac_strlin = 0;
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
				strcpy(val, strdup($1->valor));
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
						strcpy(val, "int ");
						break;

					case 'f':
						type = Decimal;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 1) + 1);
						strcpy(val, "float ");
						break;

					case 'p':
						type = Ponto;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 1) + 1);
						strcpy(val, "point ");
						break;

					case 's':
						type = Forma;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 1) + 1);
						strcpy(val, "shape ");
						break;
				
					default:
						type = Literal;
						val = (char*) malloc(sizeof(char) * (8 + strlen($2->valor) + 1) + 1);
						strcpy(val, "Literal ");
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
					if(item->tipo == Inteiro || item->tipo == Decimal){
						char* tac_nom = (char*) malloc(sizeof(char) * (strlen($2->valor) + contDigf(item->chave)) + 1);
						strcpy(tac_nom, strdup($2->valor));
						char* id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
						sprintf(id_tac_nom, "%d", item->chave);
						strcat(tac_nom, id_tac_nom);
						tac_tab(type, tac_nom);
					}
					else if(item->tipo == Ponto){
						char* tac_nom_x = (char*) malloc(sizeof(char) * (strlen($2->valor) + 1 + contDigf(item->chave)) + 1);
						char* tac_nom_y = (char*) malloc(sizeof(char) * (strlen($2->valor) + 1 + contDigf(item->chave)) + 1);
						strcpy(tac_nom_x, strdup($2->valor));
						strcpy(tac_nom_y, strdup($2->valor));
						strcat(tac_nom_x, "X");
						strcat(tac_nom_y, "Y");
						char* id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
						sprintf(id_tac_nom, "%d", item->chave);
						strcat(tac_nom_x, id_tac_nom);
						strcat(tac_nom_y, id_tac_nom);
						tac_tab(type, tac_nom_x);
						tac_tab(type, tac_nom_y);
					}
					else if(item->tipo == Forma){

					}
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
						strcpy(val, "int ");
						break;

					case 'f':
						type = Decimal;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 8) + 1);
						strcpy(val, "float ");
						break;

					case 'p':
						type = Ponto;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 8) + 1);
						strcpy(val, "point ");
						break;

					case 's':
						type = Forma;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor) + 8) + 1);
						strcpy(val, "shape ");
						break;
				
					default:
						type = Literal;
						val = (char*) malloc(sizeof(char) * (8 + strlen($2->valor) + 8) + 1);
						strcpy(val, "Literal ");
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


				// Novo label
				char* val_fim = (char*) malloc(sizeof(char) * (strlen(item->nome) + 1) + 1);
				strcpy(val_fim, item->nome);
				strcat(val_fim, ":");
				tac(val_fim);


				Parametro* temp = item->params;
				Simbolo* para;
				int i = 0;
				int qtd_params = 0;
				char* novo_nom;
				char* mov;
				char* par;
				char* nom;
				char* key;
				while(temp != NULL){
					qtd_params++;
					para = insere(temp->nome, "", VAR, temp->tipo, 0, NULL);
					key = (char*) malloc(sizeof(char) * contDigf(para->chave) + 1);
					sprintf(key, "%d", para->chave);
					novo_nom = (char*) malloc(sizeof(char) * (strlen(para->nome) + strlen(key)) + 1);
					strcpy(novo_nom, temp->nome);
					strcat(novo_nom, key);
					tac_tab(temp->tipo, novo_nom);
					temp = temp->prox;

					// TAC Atribui os params pras var
					// mov par1, #0
					// mov par2, #1
					nom = (char*) malloc(sizeof(char) * (strlen(para->nome) + strlen(key)) + 1);
					strcpy(nom, para->nome);
					strcat(nom, key);
					par = (char*) malloc(sizeof(char) * contDigf(i) + 1);
					sprintf(par, "%d", i);
					mov = (char*) malloc(sizeof(char) * (4 + strlen(nom) + 3 + strlen(par)) + 1);
					strcpy(mov, "mov ");
					strcat(mov, nom);
					strcat(mov, ", #");
					strcat(mov, par);
					tac(mov);

					i++;
				}
				item->qtdParams = qtd_params;


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
						strcpy(val, "int ");
						break;

					case 'f':
						param->tipo = Decimal;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor)) + 1);
						strcpy(val, "float ");
						break;

					case 'p':
						param->tipo = Ponto;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor)) + 1);
						strcpy(val, "point ");
						break;

					case 's':
						param->tipo = Forma;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor)) + 1);
						strcpy(val, "shape ");
						break;
				
					default:
						param->tipo = Literal;
						val = (char*) malloc(sizeof(char) * (8 + strlen($2->valor)) + 1);
						strcpy(val, "Literal ");
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
						strcpy(val, "int ");
						break;

					case 'f':
						param->tipo = Decimal;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor)) + 1);
						strcpy(val, "float ");
						break;

					case 'p':
						param->tipo = Ponto;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor)) + 1);
						strcpy(val, "point ");
						break;

					case 's':
						param->tipo = Forma;
						val = (char*) malloc(sizeof(char) * (6 + strlen($2->valor)) + 1);
						strcpy(val, "shape ");
						break;
				
					default:
						val = (char*) malloc(sizeof(char) * (8 + strlen($2->valor)) + 1);
						strcpy(val, "Literal ");
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
				strcpy(val, "{");
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
				strcpy(val, strdup($1->valor));
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
				strcpy(val, strdup($1->valor));
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
				strcpy(val, strdup($1->valor));
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
				// brz L1, $0
				char* label = (char*) malloc(sizeof(char) * (10 + contDigf(tac_if)) + 1);
				strcpy(label, "brz IF");
				char* num_if = (char*) malloc(sizeof(char) * contDigf(tac_if) + 1);
				sprintf(num_if, "%d", tac_if);
				strcat(label, num_if);
				strcat(label, ", $0");
				tac(label);


			} instrucao FIM_INSTRUC {
				// FIM DO IF
				// Nova label
				char* go = (char*) malloc(sizeof(char) * (2 + contDigf(tac_if) + 1) + 1);
				char* num_if = (char*) malloc(sizeof(char) * contDigf(tac_if) + 1);
				sprintf(num_if, "%d", tac_if);

				strcpy(go, "IF");
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
				strcpy(val, "if(");
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
				strcpy(tac_label1, "CONDFOR");
				strcat(tac_label1, label_id);
				strcat(tac_label1, ":");
				tac(tac_label1);

			} express_simp FIM_EXPRESS{

				char* label_id = (char*) malloc(sizeof(char) * contDigf(tac_for) + 1);
				sprintf(label_id, "%d", tac_for);

				// TAC se a condicao for falsa, sai do loop
				// brz FIMFOR, $0
				char* tac_label2 = (char*) malloc(sizeof(char) * (4 + 4 + 6 + contDigf(tac_for)) + 1);
				strcpy(tac_label2, "brz FIMFOR");
				strcat(tac_label2, label_id);
				strcat(tac_label2, ", $0");
				tac(tac_label2);

				// TAC se a condicao for verdadeira, vai pro corpo
				// jump CORPOFOR
				char* tac_label3 = (char*) malloc(sizeof(char) * (5 + 8 + contDigf(tac_for)) + 1);
				strcpy(tac_label3, "jump CORPOFOR");
				strcat(tac_label3, label_id);
				tac(tac_label3);

				// TAC cria label para incremento (terceira expressao do for)
				// INCRFOR:
				char* tac_label4 = (char*) malloc(sizeof(char) * (7 + contDigf(tac_for) + 1) + 1);
				strcpy(tac_label4, "INCRFOR");
				strcat(tac_label4, label_id);
				strcat(tac_label4, ":");
				tac(tac_label4);


			} expressao FIM_PARAM {
				// TAC depois de incrementar vai pro corpo
				char* tac_label = (char*) malloc(sizeof(char) * (5 + 7 + contDigf(tac_for)) + 1);
				char* label_id = (char*) malloc(sizeof(char) * contDigf(tac_for) + 1);
				sprintf(label_id, "%d", tac_for);
				strcpy(tac_label, "jump CONDFOR");
				strcat(tac_label, label_id);
				tac(tac_label);

				// TAC cria label para CORPO do for
				// CORPOFOR:
				char* tac_label1 = (char*) malloc(sizeof(char) * (8 + contDigf(tac_for) + 1) + 1);
				strcpy(tac_label1, "CORPOFOR");
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
				strcpy(val, "for");
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
				strcpy(tac_label, "jump INCRFOR");
				strcat(tac_label, label_id);
				tac(tac_label);

				// TAC cria label para FIM do for
				// FIMFOR:
				char* tac_label1 = (char*) malloc(sizeof(char) * (6 + contDigf(tac_for) + 1) + 1);
				strcpy(tac_label1, "FIMFOR");
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
				strcpy(val, "return ");
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
						strcpy(tac_val, "return ");
						strcat(tac_val, strdup($2->valor));
						tac(tac_val);
					}
					else{
						tac_val = (char*) malloc(sizeof(char) * (7 + strlen(item->nome) + contDigf(item->chave)) + 1);
						strcpy(tac_val, "return ");
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
				strcpy(val, strdup($1->valor));
				strcat(val, strdup($2->valor));
				strcat(val, strdup($3->valor));
				$$ = novoNo(3, lista, strdup(val), NULL);

				free(val);
				val = NULL;


				TabSimbolos item = buscaTabNome(strdup($1->valor));
				TabSimbolos item2 = buscaTabNome(strdup($3->valor));
				int soVal2 = 0;
				if(item2 == NULL){
					item2 = buscaTabVal(strdup($3->valor));
					soVal2 = 1;
					if(item2 == NULL){
					}
				}
				if(item == NULL || (item2 == NULL && $3->valor == NULL)){
					if(item == NULL){
						printf("\t### ERRO: [%s] uso de variavel nao declarada. [%d][%d]\n", $1->valor, $1->linha, $1->coluna);
					}
					if(item2 == NULL){
						if(strcmp($3->valor != NULL ? $3->valor : "", "") == 0){
							printf("\t### ERRO: [%s] expressao nao encontrada. [%d][%d]\n", $2->valor, $2->linha, $2->coluna);
						}
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
					char* item1_nome;
					char* item2_nome;
					char* item1_chave;
					char* item2_chave;
					char* tac_converte;
					char* tac_move;
					int isConv = 0; // Se o item1 foi convertido, usar $6
					int isVal = 0; // Se o item2 foi convertido e eh um valor, usar $8

					item1_chave = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
					sprintf(item1_chave, "%d", item->chave);
					if(soVal2 == 0){
						item2_chave = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
						sprintf(item2_chave, "%d", item2->chave);
					}
					item1_nome = (char*) malloc(sizeof(char) * (strlen(item->nome) + contDigf(item->chave)) + 1);
					strcpy(item1_nome, item->nome);
					strcat(item1_nome, item1_chave);
					if(soVal2 == 0){
						if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
							item2_nome = (char*) malloc(sizeof(char) * (strlen(item2->nome) + contDigf(item2->chave)) + 1);
							strcpy(item2_nome, item2->nome);
							strcat(item2_nome, item2_chave);
						}
						else{
							item2_nome = (char*) malloc(sizeof(char) * strlen(item2->valor) + 1);
							strcpy(item2_nome, item2->valor);
						}
					}
					else{
						item2_nome = (char*) malloc(sizeof(char) * strlen($3->valor) + 1);
						strcpy(item2_nome, $3->valor);
					}

					TYPE tipo_express_simp = $3->tipo;
					if(item->tipo == Inteiro && tipo_express_simp == Decimal){
						printf("\t### ADVERTENCIA: [%s] expressao truncada para atribuicao. [%d][%d]\n", item->nome, $1->linha, $1->coluna);

						if(soVal2 == 0 || item2 != NULL ? strcmp(item2->nome != NULL ? item2->nome : "", "") != 0 : 0){
							// TAC Converte float to int (trunca expressao a direita)
							// fltoint $0, item2
							tac_converte = (char*) malloc(sizeof(char) * (8 + strlen(item2_nome) + 4) + 1);
							strcpy(tac_converte, "fltoint $6, ");
							strcat(tac_converte, item2_nome);
							tac(tac_converte);
							isConv = 1;


							tmpf = atof(item2->valor);
						}
						else{
							tac_converte = (char*) malloc(sizeof(char) * (8 + strlen(item2_nome) + 4) + 1);
							strcpy(tac_converte, "fltoint $8, ");
							strcat(tac_converte, item2_nome);
							tac(tac_converte);
							isVal = 1;

							tmpf = atof($3->valor);
						}
						tmpi = (int) tmpf;
						val2 = (char*) malloc(sizeof(char) * contDigf(tmpi) + 1);
						sprintf(val2, "%d", tmpi);

						val1 = (char*) malloc(sizeof(char) * strlen(item->valor != NULL ? item->valor : "") + 1);
						val1 = strdup(item->valor != NULL ? item->valor : "");

					}
					else if(item->tipo == Decimal && tipo_express_simp == Inteiro){
						// Converte tipos
						if(soVal2 == 0 || item2 != NULL ? strcmp(item2->nome != NULL ? item2->nome : "", "") != 0 : 0){
							// TAC Converte int to float (so acrescenta ponto flutuante)
							// inttofl $6, item2
							tac_converte = (char*) malloc(sizeof(char) * (8 + strlen(item2_nome) + 4) + 1);
							strcpy(tac_converte, "inttofl $6, ");
							strcat(tac_converte, item2_nome);
							tac(tac_converte);
							isConv = 1;


							tmpi = atoi(item2->valor);
						}
						else{
							tac_converte = (char*) malloc(sizeof(char) * (8 + strlen(item2_nome) + 4) + 1);
							strcpy(tac_converte, "inttofl $8, ");
							strcat(tac_converte, item2_nome);
							tac(tac_converte);
							isVal = 1;


							tmpi = atoi($3->valor);
						}
						tmpf = (float) tmpi;
						val2 = (char*) malloc(sizeof(char) * contDigf(tmpf) + 1);
						gcvt(tmpf, contDigf(tmpf) + 1, val2);

						val1 = (char*) malloc(sizeof(char) * strlen(item->valor != NULL ? item->valor : "") + 1);
						val1 = strdup(item->valor != NULL ? item->valor : "");
					}
					else{
						val1 = (char*) malloc(sizeof(char) * strlen(item->valor != NULL ? item->valor : "") + 1);
						val1 = strdup(item->valor != NULL ? item->valor : "");

						if(soVal2 == 0){
							val2 = (char*) malloc(sizeof(char) * strlen(item2->valor != NULL ? item2->valor : "") + 1);
							val2 = strdup(item2->valor != NULL ? item2->valor : "");
						}
						else{
							val2 = (char*) malloc(sizeof(char) * strlen($3->valor != NULL ? $3->valor : "") + 1);
							val2 = strdup($3->valor != NULL ? $3->valor : "");
						}
					}


					if((item->tipo != Decimal && item->tipo != Inteiro) || (tipo_express_simp != Inteiro && tipo_express_simp != Decimal)){
						printf("\t### ERRO: [%s] tipo incompativel para atribuicao. [%d][%d]\n", item->nome, $1->linha, $1->coluna);
					}
					else{
						if((soVal2 == 1) || (item2->isVar == FUNC || strcmp(item2->valor != NULL ? item2->valor : "", "") != 0)){

							if(soVal2 == 0 && item2->isVar == FUNC){
								// mov item1, $0
								char* atr_func = (char*) malloc(sizeof(char) * (4 + (strlen(item->nome) + contDigf(item->chave)) + 2 + 2) + 1);
								char* atr_key= (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
								sprintf(atr_key, "%d", item->chave);
								strcpy(atr_func, "mov ");
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

								if(soVal2 == 0){
									if(item2->tipo == Inteiro){
										temp_val_i = atoi(item2->valor);
									}
									if(item2->tipo == Decimal){
										temp_val_f = atof(item2->valor);
									}
								}
								else{
									if($3->tipo == Inteiro){
										temp_val_i = atoi($3->valor);
									}
									if($3->tipo == Decimal){
										temp_val_f = atof($3->valor);
									}
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
										if(soVal2 == 0 && strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
											tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + isConv == 0 ? (strlen(item2->nome) + contDigf(item2->chave)) : 2) + 1);
											strcpy(tmp_nom, "mov ");
											strcat(tmp_nom, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(tmp_nom, id_tac_nom);
											strcat(tmp_nom, ", ");
											if(isConv == 0){
												strcat(tmp_nom, item2->nome);
												id_tac_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
												sprintf(id_tac_nom2, "%d", item2->chave);
												strcat(tmp_nom, id_tac_nom2);
											}
											else{
												strcat(tmp_nom, "$6");
											}
											tac(tmp_nom);
										}
										else{
											tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + isVal == 0 ? strlen(item2_nome) : 2) + 1);
											strcpy(tmp_nom, "mov ");
											strcat(tmp_nom, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(tmp_nom, id_tac_nom);
											strcat(tmp_nom, ", ");
											if(isVal == 0){
												strcat(tmp_nom, item2_nome);
											}
											else{
												strcat(tmp_nom, "$8");
											}
											tac(tmp_nom);
										}
										break;

									case '+':
										if(item->tipo == Decimal || (soVal2 == 0 ? item2->tipo : $3->tipo == Decimal)){
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
										if(soVal2 == 0 && strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + isConv == 0 ? (strlen(item2->nome) + contDigf(item2->chave)) : 2) + 1);
											strcpy(temp_add, "add $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											if(isConv == 0){
												strcat(temp_add, item2->nome);
												id_tac_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
												sprintf(id_tac_nom2, "%d", item2->chave);
												strcat(temp_add, id_tac_nom2);
											}
											else{
												strcat(temp_add, "$6");
											}
											tac(temp_add);
										}
										else{
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + isVal == 0 ? strlen(item2_nome) : 2) + 1);
											strcpy(temp_add, "add $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											if(isVal == 0){
												strcat(temp_add, item2_nome);
											}
											else{
												strcat(temp_add, "$8");
											}
											tac(temp_add);
										}

										// TAC mov item1, $0
										char* chave = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
										sprintf(chave, "%d", item->chave);
										tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + 2) + 1);
										strcpy(tmp_nom, "mov ");
										strcat(tmp_nom, item->nome);
										strcat(tmp_nom, chave);
										strcat(tmp_nom, ", $0");
										tac(tmp_nom);

										break;

									case '-':
										if(item->tipo == Decimal || (soVal2 == 0 ? item2->tipo : $3->tipo == Decimal)){
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
										if(soVal2 == 0 && strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + isConv == 0 ? (strlen(item2->nome) + contDigf(item2->chave)) : 2) + 1);
											strcpy(temp_add, "sub $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											if(isConv == 0){
												strcat(temp_add, item2->nome);
												id_tac_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
												sprintf(id_tac_nom2, "%d", item2->chave);
												strcat(temp_add, id_tac_nom2);
											}
											else{
												strcat(temp_add, "$6");
											}
											tac(temp_add);
										}
										else{
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + isVal == 0 ? strlen(item2_nome) : 2) + 1);
											strcpy(temp_add, "sub $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											if(isVal == 0){
												strcat(temp_add, item2_nome);
											}
											else{
												strcat(temp_add, "$8");
											}
											tac(temp_add);
										}

										// TAC mov item1, $0
										chave = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
										sprintf(chave, "%d", item->chave);
										tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + 2) + 1);
										strcpy(tmp_nom, "mov ");
										strcat(tmp_nom, item->nome);
										strcat(tmp_nom, chave);
										strcat(tmp_nom, ", $0");
										tac(tmp_nom);

										break;

									case '*':
										if(item->tipo == Decimal || (soVal2 == 0 ? item2->tipo : $3->tipo == Decimal)){
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
										if(soVal2 == 0 && strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + isConv == 0 ? (strlen(item2->nome) + contDigf(item2->chave)) : 2) + 1);
											strcpy(temp_add, "mul $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											if(isConv == 0){
												strcat(temp_add, item2->nome);
												id_tac_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
												sprintf(id_tac_nom2, "%d", item2->chave);
												strcat(temp_add, id_tac_nom2);
											}
											else{
												strcat(temp_add, "$6");
											}
											tac(temp_add);
										}
										else{
											temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + isVal == 0 ? strlen(item2_nome) : 2) + 1);
											strcpy(temp_add, "mul $0, ");
											strcat(temp_add, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(temp_add, id_tac_nom);
											strcat(temp_add, ", ");
											if(isVal == 0){
												strcat(temp_add, item2_nome);
											}
											else{
												strcat(temp_add, "$8");
											}
											tac(temp_add);
										}

										// TAC mov item1, $0
										chave = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
										sprintf(chave, "%d", item->chave);
										tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + 2) + 1);
										strcpy(tmp_nom, "mov ");
										strcat(tmp_nom, item->nome);
										strcat(tmp_nom, chave);
										strcat(tmp_nom, ", $0");
										tac(tmp_nom);

										break;

									case '/':
										if(atof(val2) == 0){
											printf("\t\t### ERRO: [%s] divisao por 0. [%d][%d]\n", soVal2 == 0 ? item2->valor : $3->valor, $2->linha, $2->coluna);
											free(item->valor);
											if(item->tipo == Decimal || (soVal2 == 0 ? item2->tipo : $3->tipo == Decimal)){
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
											strcpy(tmp_nom, "mov ");
											strcat(tmp_nom, item->nome);
											id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(id_tac_nom, "%d", item->chave);
											strcat(tmp_nom, id_tac_nom);
											strcat(tmp_nom, ", ");
											strcat(tmp_nom, item->valor);
											tac(tmp_nom);
										}
										else{
											if(item->tipo == Decimal || soVal2 == 0 ? item2->tipo : $3->tipo == Decimal){
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
											if(soVal2 == 0 && strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
												temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + isConv == 0 ? (strlen(item2->nome) + contDigf(item2->chave)) : 2) + 1);
												strcpy(temp_add, "div $0, ");
												strcat(temp_add, item->nome);
												id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
												sprintf(id_tac_nom, "%d", item->chave);
												strcat(temp_add, id_tac_nom);
												strcat(temp_add, ", ");
												if(isConv == 0){
													strcat(temp_add, item2->nome);
													id_tac_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
													sprintf(id_tac_nom2, "%d", item2->chave);
													strcat(temp_add, id_tac_nom2);
												}
												else{
													strcat(temp_add, "$6");
												}
												tac(temp_add);
											}
											else{
												temp_add = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(item->nome) + contDigf(item->chave) + 2 + isVal == 0 ? strlen(item2_nome) : 2) + 1);
												strcpy(temp_add, "div $0, ");
												strcat(temp_add, item->nome);
												id_tac_nom = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
												sprintf(id_tac_nom, "%d", item->chave);
												strcat(temp_add, id_tac_nom);
												strcat(temp_add, ", ");
												if(isVal == 0){
													strcat(temp_add, item2_nome);
												}
												else{
													strcat(temp_add, "$8");
												}
												tac(temp_add);
											}

											// TAC mov item1, $0
											chave = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
											sprintf(chave, "%d", item->chave);
											tmp_nom = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + contDigf(item->chave) + 2 + 2) + 1);
											strcpy(tmp_nom, "mov ");
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
				strcpy(val, strdup($1->valor));
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
					char* tac_converte;
					char* item1_nome;
					char* item1_chave;
					char* item2_nome;
					char* item2_chave;
					char* mov1;
					char* mov2;



					if(($1->tipo == Decimal && ($3->tipo == Inteiro || $3->tipo == Decimal)) || ($3->tipo == Decimal && ($1->tipo == Inteiro || $1->tipo == Decimal))){
						$$->tipo = Decimal;

						item1_nome = (char*) malloc(sizeof(char) * strlen(strcmp(item->nome != NULL ? item->nome : "", "") != 0 ? item->nome : item->valor) + 1);
						item2_nome = (char*) malloc(sizeof(char) * strlen(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0 ? item2->nome : item2->valor) + 1);
						item1_chave = (char*) malloc(sizeof(char) * (strcmp(item->nome != NULL ? item->nome : "", "") != 0 ? contDigf(item->chave) : 0) + 1);
						item2_chave = (char*) malloc(sizeof(char) * (strcmp(item2->nome != NULL ? item2->nome : "", "") != 0 ? contDigf(item2->chave) : 0) + 1);
						strcpy(item1_nome, strcmp(item->nome != NULL ? item->nome : "", "") != 0 ? item->nome : item->valor);
						strcpy(item2_nome, strcmp(item2->nome != NULL ? item2->nome : "", "") != 0 ? item2->nome : item2->valor);
						if(strcmp(item->nome != NULL ? item->nome : "", "") != 0){
							sprintf(item1_chave, "%d", item->chave);
						}
						if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
							sprintf(item2_chave, "%d", item2->chave);
						}

						if($1->tipo != $3->tipo){
							printf("\t### ADVERTENCIA: [%s %s %s] Operacao relacional sobre tipos distintos, inteiro e decimal. [%d][%d]\n", $1->tipo == Inteiro ? "int" : "float", $2->valor, $3->tipo == Inteiro ? "int" : "float", $2->linha, $2->coluna);

							// Converte tipos
							if($1->tipo == Decimal){
								// TAC Converte tipos (item2 int to float)
								// mov $0, item2
								// inttofl item2, $0
								if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
									mov1 = (char*) malloc(sizeof(char) * (4 + 4 + strlen(item2_nome) + strlen(item2_chave)) + 1);
									strcpy(mov1, "mov $0, ");
									strcat(mov1, item2_nome);
									strcat(mov1, item2_chave);
									tac(mov1);

									tac_converte = (char*) malloc(sizeof(char) * (8 + strlen(item2_nome) + strlen(item2_chave) + 4) + 1);
									strcpy(tac_converte, "inttofl ");
									strcat(tac_converte, item2_nome);
									strcat(tac_converte, item2_chave);
									strcat(tac_converte, ", $0");
									tac(tac_converte);
								}
								else{
									mov1 = (char*) malloc(sizeof(char) * (4 + 4 + strlen(item2_nome)) + 1);
									strcpy(mov1, "mov $9, ");
									strcat(mov1, item2_nome);
									tac(mov1);

									tac("inttofl $8, $9");
								}

								
								if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
									aux_nom2 = (char*) malloc(sizeof(char) * contDigf(item2->chave) + 1);
									sprintf(aux_nom2, "%d", item2->chave);
									val2 = (char*) malloc(sizeof(char) * (strlen(item2->nome) + contDigf(item2->chave)) + 1);
									strcpy(val2, item2->nome);
									strcat(val2, aux_nom2);

								}
								else{
									// TAC converte (no caso, convertendo aqui e passando pro tac ja convertido)
									tmpi = atoi(item2->valor);
									tmpf = (float) tmpi;
									val2 = (char*) malloc(sizeof(char) * 2 + 1);
									strcpy(val2, "$8");
								}

								if(strcmp(item->nome != NULL ? item->nome : "", "") != 0){
									aux_nom1 = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
									sprintf(aux_nom1, "%d", item->chave);
									val1 = (char*) malloc(sizeof(char) * (strlen(item->nome) + contDigf(item->chave)) + 1);
									strcpy(val1, item->nome);
									strcat(val1, aux_nom1);
								}
								else{
									val1 = (char*) malloc(sizeof(char) * strlen(item->valor) + 1);
									val1 = strdup(item->valor);
								}
							}
							else{
								// TAC Converte tipos (item2 float to int)
								// mov $0, item2
								// fltoint item2, $0
								if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
									mov1 = (char*) malloc(sizeof(char) * (4 + 4 + strlen(item2_nome) + strlen(item2_chave)) + 1);
									strcpy(mov1, "mov $0, ");
									strcat(mov1, item2_nome);
									strcat(mov1, item2_chave);
									tac(mov1);

									tac_converte = (char*) malloc(sizeof(char) * (8 + strlen(item2_nome) + strlen(item2_chave) + 4) + 1);
									strcpy(tac_converte, "fltoint ");
									strcat(tac_converte, item2_nome);
									strcat(tac_converte, item2_chave);
									strcat(tac_converte, ", $0");
									tac(tac_converte);
								}
								else{
									mov1 = (char*) malloc(sizeof(char) * (4 + 4 + strlen(item2_nome)) + 1);
									strcpy(mov1, "mov $9, ");
									strcat(mov1, item2_nome);
									tac(mov1);

									tac("fltoint $8, $9");
								}


								if(strcmp(item->nome != NULL ? item->nome : "", "") != 0){
									aux_nom1 = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
									sprintf(aux_nom1, "%d", item->chave);
									val1 = (char*) malloc(sizeof(char) * (strlen(item->nome) + contDigf(item->chave)) + 1);
									strcpy(val1, item->nome);
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
									strcpy(val2, item2->nome);
									strcat(val2, aux_nom2);
								}
								else{
									val2 = (char*) malloc(sizeof(char) * 2 + 1);
									strcpy(val2, "$8");
								}
							}
						}
						else{
							if(strcmp(item->nome != NULL ? item->nome : "", "") != 0){
								aux_nom1 = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
								sprintf(aux_nom1, "%d", item->chave);
								val1 = (char*) malloc(sizeof(char) * (strlen(item->nome) + contDigf(item->chave)) + 1);
								strcpy(val1, item->nome);
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
								strcpy(val2, item2->nome);
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
							strcpy(val1, item->nome);
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
							strcpy(val2, item2->nome);
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
						strcpy(tmp_nom, "sleq $0, ");
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
						strcpy(tmp_nom, "slt $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);

						tac("not $0, $1");
					}
					else if(strcmp($2->valor, "==") == 0){
						tac("// Comparacao: Igual a");
						// seq $0, item, item2
						tmp_nom = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcpy(tmp_nom, "seq $0, ");
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
						strcpy(tmp_nom, "seq $1, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);

						tac("not $0, $1");
					}
					else if(strcmp($2->valor, "&&") == 0){
						tac("// Comparacao: And logico");
						// and $0, item, item2
						tmp_nom = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcpy(tmp_nom, "and $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);
					}
					else if(strcmp($2->valor, "||") == 0){
						tac("// Comparacao: Ou logico");
						// or $0, item, item2
						tmp_nom = (char*) malloc(sizeof(char) * (3 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcpy(tmp_nom, "or $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);
					}
					else if(strcmp($2->valor, "<") == 0){
						tac("// Comparacao: Menor que");
						// slt $0, item, item2
						tmp_nom = (char*) malloc(sizeof(char) * (4 + 2 + 2 + strlen(val1) + 2 + strlen(val2)) + 1);
						strcpy(tmp_nom, "slt $0, ");
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
						strcpy(tmp_nom, "sleq $0, ");
						strcat(tmp_nom, val1);
						strcat(tmp_nom, ", ");
						strcat(tmp_nom, val2);
						tac(tmp_nom);

						tac("not $0, $1");
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
				TYPE tipo = $1->tipo;
				$$->tipo = tipo;
			}
			| termo addop express_soma {
				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;

				char* val = (char*) malloc(sizeof(char) * (strlen($1->valor) + strlen($2->valor) + strlen($3->valor)) + 1);
				strcpy(val, strdup($1->valor));
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
				TYPE tipo = $1->tipo;
				$$->tipo = tipo;
			}
			| factor mulop termo {
				TYPE tipo_termo = other;
				int isInt = -1;
				int ifinal = 0;
				float ffinal = 0;
				TabSimbolos item1 = buscaTabNome(strdup($1->valor));
				if(item1 == NULL){
					item1 = buscaTabVal(strdup($1->valor));
				}
				TabSimbolos item2 = buscaTabNome(strdup($3->valor));
				if(item2 == NULL){
					item2 = buscaTabVal(strdup($3->valor));
				}
				if(item1 == NULL || item2 == NULL){
					if(item1 == NULL){
						printf("\t### ERRO: [%s] expressao 1 nao encontrada. [%d][%d]\n", $1->valor, $1->linha, $1->coluna);
					}
					if(item2 == NULL){
						printf("\t### ERRO: [%s] expressao 2 nao encontrada. [%d][%d]\n", $3->valor, $3->linha, $3->coluna);
					}
				}
				else{
					char* converte1;
					char* converte2;
					char* mov1;
					char* mov2;
					char* item1_nome;
					char* item1_chave;
					char* item2_nome;
					char* item2_chave;
					char* temp_add;


					item1_nome = (char*) malloc(sizeof(char) * strlen(strcmp(item1->nome != NULL ? item1->nome : "", "") != 0 ? item1->nome : item1->valor) + 1);
					item2_nome = (char*) malloc(sizeof(char) * strlen(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0 ? item2->nome : item2->valor) + 1);
					item1_chave = (char*) malloc(sizeof(char) * (strcmp(item1->nome != NULL ? item1->nome : "", "") != 0 ? contDigf(item1->chave) : 0) + 1);
					item2_chave = (char*) malloc(sizeof(char) * (strcmp(item2->nome != NULL ? item2->nome : "", "") != 0 ? contDigf(item2->chave) : 0) + 1);
					strcpy(item1_nome, strcmp(item1->nome != NULL ? item1->nome : "", "") != 0 ? item1->nome : item1->valor);
					strcpy(item2_nome, strcmp(item2->nome != NULL ? item2->nome : "", "") != 0 ? item2->nome : item2->valor);
					if(strcmp(item1->nome != NULL ? item1->nome : "", "") != 0){
						sprintf(item1_chave, "%d", item1->chave);
					}
					if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
						sprintf(item2_chave, "%d", item2->chave);
					}


					int isConv1 = 0; // Se o item1 foi convertido, usar $5
					int isConv2 = 0; // Se o item2 foi convertido, usar $6
					int isVal1 = 0; // Se o item1 foi convertido e eh um valor, usar $7
					int isVal2 = 0; // Se o item2 foi convertido e eh um valor, usar $8
					isInt = 0;
					int erro = 0;
					float tmpf1, tmpf2;
					int tmpi1, tmpi2;
					char* val1;
					char* val2;
					if((item1->tipo != Inteiro && item1->tipo != Decimal) || (item2->tipo != Inteiro && item2->tipo != Decimal)){
						printf("\t### ERRO: expressao com tipos incompativeis [%d][%d]\n", $1->linha, $1->coluna);
						erro = 1;
						tipo_termo = other;
					}
					else{
						if(item1->tipo == Decimal || item2->tipo == Decimal){
							isInt = 0;
							tipo_termo = Decimal;

							// TAC Converte tipos (item1 inttofl)
							// inttofl $5, item1
							if(item1->tipo == Inteiro){
								// Converte se for por nome
								// inttofl $5, item1
								if(strcmp(item1->nome != NULL ? item1->nome : "", "") != 0){
									converte1 = (char*) malloc(sizeof(char) * (8 + strlen(item1_nome) + strlen(item1_chave) + 4) + 1);
									strcpy(converte1, "inttofl $5, ");
									strcat(converte1, item1_nome);
									strcat(converte1, item1_chave);
									tac(converte1);
									isConv1 = 1;

								}
								else{
									// Converte se for por valor
									// mov $9, item1_valor
									// inttofl $7, $9
									mov1 = (char*) malloc(sizeof(char) * (4 + 4 + strlen(item1_nome)) + 1);
									strcpy(mov1, "mov $9, ");
									strcat(mov1, item1_nome);
									tac(mov1);
									isVal1 = 1;

									tac("inttofl $7, $9");
								}

								tmpi1 = atoi(item1->valor);
								tmpf1 = (float) tmpi1;
								val1 = (char*) malloc(sizeof(char) * contDigf(tmpf1) + 1);
								gcvt(tmpf1, contDigf(tmpf1) + 1, val1);

								tmpf2 = atof(item2->valor);
								tmpi2 = (int) tmpf2;
								val2 = (char*) malloc(sizeof(char) * contDigf(tmpf2) + 1);
								gcvt(tmpf2, contDigf(tmpf2) + 1, val2);

							}
							else if(item2->tipo == Inteiro){
								// Converte se for por variavel
								// inttofl $6, item2
								if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
									converte2 = (char*) malloc(sizeof(char) * (8 + strlen(item2_nome) + strlen(item2_chave) + 4) + 1);
									strcpy(converte2, "inttofl $6, ");
									strcat(converte2, item2_nome);
									strcat(converte2, item2_chave);
									tac(converte2);
									isConv2 = 1;
								}
								else{
									// Converte se for por valor
									mov2 = (char*) malloc(sizeof(char) * (4 + 4 + strlen(item2_nome)) + 1);
									strcpy(mov2, "mov $9, ");
									strcat(mov2, item2_nome);
									tac(mov2);
									isVal2 = 1;

									tac("inttofl $8, $9");
								}

								tmpi2 = atoi(item2->valor);
								tmpf2 = (float) tmpi2;
								val2 = (char*) malloc(sizeof(char) * contDigf(tmpf2) + 1);
								gcvt(tmpf2, contDigf(tmpf2) + 1, val2);

								tmpf1 = atof(item1->valor);
								tmpi1 = (int) tmpf1;
								val1 = (char*) malloc(sizeof(char) * contDigf(tmpf1) + 1);
								gcvt(tmpf1, contDigf(tmpf2) + 1, val1);

							}
							else{
								tmpf1 = atof(item1->valor);
								tmpi1 = (int) tmpf1;
								val1 = (char*) malloc(sizeof(char) * contDigf(tmpf1) + 1);
								gcvt(tmpf1, contDigf(tmpf1) + 1, val1);

								tmpf2 = atof(item2->valor);
								tmpi2 = (int) tmpf2;
								val2 = (char*) malloc(sizeof(char) * contDigf(tmpf2) + 1);
								gcvt(tmpf2, contDigf(tmpf2) + 1, val2);
							}
						}
						else if(item1->tipo == Inteiro && item2->tipo == Inteiro){
							tmpi1 = atoi(item1->valor);
							tmpf1 = (float) tmpi1;
							val1 = (char*) malloc(sizeof(char) * contDigf(tmpi1) + 1);
							sprintf(val1, "%d", tmpi1);

							tmpi2 = atoi(item2->valor);
							tmpf2 = (float) tmpi1;
							val2 = (char*) malloc(sizeof(char) * contDigf(tmpi2) + 1);
							sprintf(val2, "%d", tmpi2);
							isInt = 1;
							tipo_termo = Inteiro;
						}
					}

					switch($2->valor[0]){
						case '*':
							if(isInt == 1){
								ifinal = tmpi1 * tmpi2;
							}
							else{
								ffinal = tmpf1 * tmpf2;
							}


							// TAC multiplica
							// mul $0, item1, item2
							if(strcmp(item1->nome != NULL ? item1->nome : "", "") != 0){
								if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
									temp_add = (char*) malloc(sizeof(char) * (4 + 4 + isConv1 == 0 ? (strlen(item1->nome) + contDigf(item1->chave)) : 2 + 2 + isConv2 == 0 ? (strlen(item2->nome) + contDigf(item2->chave)) : 2) + 1);
									strcpy(temp_add, "mul $0, ");
									if(isConv1 == 0){
										strcat(temp_add, item1->nome);
										strcat(temp_add, item1_chave);
									}
									else{
										strcat(temp_add, "$5");
									}
									strcat(temp_add, ", ");
									if(isConv2 == 0){
										strcat(temp_add, item2->nome);
										strcat(temp_add, item2_chave);
									}
									else{
										strcat(temp_add, "$6");
									}
									tac(temp_add);
								}
								else{
									temp_add = (char*) malloc(sizeof(char) * (4 + 4 + isConv1 == 0 ? (strlen(item1->nome) + contDigf(item1->chave)) : 2 + 2 + isVal2 == 0 ? strlen(val2) : 2) + 1);
									strcpy(temp_add, "mul $0, ");
									if(isConv1 == 0){
										strcat(temp_add, item1->nome);
										strcat(temp_add, item1_chave);
									}
									else{
										strcat(temp_add, "$5");
									}
									strcat(temp_add, ", ");
									if(isVal2 == 0){
										strcat(temp_add, val2);
									}
									else{
										strcat(temp_add, "$8");
									}
									tac(temp_add);
								}
							}
							else{
								if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
									temp_add = (char*) malloc(sizeof(char) * (4 + 4 + isVal1 == 0 ? strlen(val1) : 2 + 2 + isConv2 == 0 ? (strlen(item2->nome) + contDigf(item2->chave)) : 2) + 1);
									strcpy(temp_add, "mul $0, ");
									if(isVal1 == 0){
										strcat(temp_add, val1);
									}
									else{
										strcat(temp_add, "$7");
									}
									strcat(temp_add, ", ");
									if(isConv2 == 0){
										strcat(temp_add, item2->nome);
										strcat(temp_add, item2_chave);
									}
									else{
										strcat(temp_add, "$6");
									}
									tac(temp_add);
								}
								else{
									temp_add = (char*) malloc(sizeof(char) * (4 + 4 + isVal1 == 0 ? strlen(val1) : 2 + 2 + isVal2 == 0 ? strlen(val2) : 2) + 1);
									strcpy(temp_add, "mul $0, ");
									if(isVal1 == 0){
										strcat(temp_add, val1);
									}
									else{
										strcat(temp_add, "$7");
									}
									strcat(temp_add, ", ");
									if(isVal2 == 0){
										strcat(temp_add, val2);
									}
									else{
										strcat(temp_add, "$8");
									}
									tac(temp_add);
								}
							}

							break;
						case '/':
							if(tmpf2 == 0){
								if(isInt == 1){
									printf("\t### ERRO [%d / %d] divisão por zero. [%d][%d]\n", tmpi1, tmpi2, $1->linha, $1->coluna);
								}
								else{
									printf("\t### ERRO [%f / %f] divisão por zero. [%d][%d]\n", tmpf1, tmpf2, $1->linha, $1->coluna);
								}
							}
							else{
								if(isInt == 1){
									ifinal = tmpi1 / tmpi2;
								}
								else{
									ffinal = tmpf1 / tmpf2;
								}


								// TAC divide
								// div $0, item1, item2
								if(strcmp(item1->nome != NULL ? item1->nome : "", "") != 0){
									if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
										temp_add = (char*) malloc(sizeof(char) * (4 + 4 + isConv1 == 0 ? (strlen(item1->nome) + contDigf(item1->chave)) : 2 + 2 + isConv2 == 0 ?(strlen(item2->nome) + contDigf(item2->chave)) : 2) + 1);
										strcpy(temp_add, "div $0, ");
										if(isConv1 == 0){
											strcat(temp_add, item1->nome);
											strcat(temp_add, item1_chave);
										}
										else{
											strcat(temp_add, "$5");
										}
										strcat(temp_add, ", ");
										if(isConv2 == 0){
											strcat(temp_add, item2->nome);
											strcat(temp_add, item2_chave);
										}
										else{
											strcat(temp_add, "$6");
										}
										tac(temp_add);
									}
									else{
										temp_add = (char*) malloc(sizeof(char) * (4 + 4 + isConv1 == 0 ?(strlen(item1->nome) + contDigf(item1->chave)) : 2 + 2 + isVal2 == 0 ? strlen(val2) : 2) + 1);
										strcpy(temp_add, "div $0, ");
										if(isConv1 == 0){
											strcat(temp_add, item1->nome);
											strcat(temp_add, item1_chave);
										}
										else{
											strcat(temp_add, "$5");
										}
										strcat(temp_add, ", ");
										if(isVal2 == 0){
											strcat(temp_add, val2);
										}
										else{
											strcat(temp_add, "$8");
										}
										tac(temp_add);
									}
								}
								else{
									if(strcmp(item2->nome != NULL ? item2->nome : "", "") != 0){
										temp_add = (char*) malloc(sizeof(char) * (4 + 4 + isVal1 == 0 ? strlen(val1) : 2 + 2 + isConv2 == 0 ? (strlen(item2->nome) + contDigf(item2->chave)) : 2) + 1);
										strcpy(temp_add, "div $0, ");
										if(isVal1 == 0){
											strcat(temp_add, val1);
										}
										else{
											strcat(temp_add, "$7");
										}
										strcat(temp_add, ", ");
										if(isConv2 == 0){
											strcat(temp_add, item2->nome);
											strcat(temp_add, item2_chave);
										}
										else{
											strcat(temp_add, "$6");
										}
										tac(temp_add);
									}
									else{
										temp_add = (char*) malloc(sizeof(char) * (4 + 4 + isVal1 == 0 ? strlen(val1) : 2 + 2 + isVal2 == 0 ? strlen(val2) : 2) + 1);
										strcpy(temp_add, "div $0, ");
										if(isVal1 == 0){
											strcat(temp_add, val1);
										}
										else{
											strcat(temp_add, "$7");
										}
										strcat(temp_add, ", ");
										if(isVal2 == 0){
											strcat(temp_add, val2);
										}
										else{
											strcat(temp_add, "$8");
										}
										tac(temp_add);
									}
								}


							}

							break;
						default:
							printf("\t### ERRO: [%s] operador nao encontrado [%d][%d]\n", $2->valor, $2->linha, $2->coluna);
							erro = 1;
							break;
					}

				}


				// char* val2;
				// if(erro != 1){
				// 	if(isInt == 1){
				// 		val2 = (char*) malloc(sizeof(char) * contDigf(ivalfinal) + 1);
				// 		sprintf(val2, "%d", ivalfinal);
				// 	}
				// 	else{
				// 		val2 = (char*) malloc(sizeof(char) * contDigf(fvalfinal) + 1);
				// 		sprintf(val2, "%lf", fvalfinal);
				// 	}
				// }

				// val2 = NULL;

				Node** lista = (Node**) malloc(sizeof(Node*) * 3);
				lista[0] = $1;
				lista[1] = $2;
				lista[2] = $3;

				char* val = (char*) malloc(sizeof(char) * (isInt == 0 ? contDigf(ifinal) : contDigf(ffinal)) + 1);
				if(isInt == 1){
					sprintf(val, "%d", ifinal);
				}
				else if(isInt == 0){
					gcvt(ffinal, contDigf(ffinal) + 1, val);
				}
				if(isInt < 0){
					$$ = novoNo(3, lista, strdup($2->valor), NULL);
				}
				else{
					$$ = novoNo(3, lista, strdup(val), NULL);
				}
				$$->tipo = tipo_termo;

			}
			;


factor:
			INI_PARAM expressao FIM_PARAM {
				Node** lista = (Node**) malloc(sizeof(Node*));
				lista[0] = $2;
				
				char* val = (char*) malloc(sizeof(char) * (1 + strlen($2->valor) + 1) + 1);
				strcpy(val, "(");
				strcat(val, strdup($2->valor));
				strcat(val, ")");
				
				$$ = novoNo(1, lista, strdup(val), NULL);
				TYPE tipo = $2->tipo;
				$$->tipo = tipo;

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
				strcpy(val, "&");
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
				strcpy(val, strdup($1->valor));
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



					Parametro* argument = $3 != NULL ? ($3->params != NULL ? $3->params : NULL) : NULL;
					if(argument != NULL){
						char* nova_var;
						char* aux_key;
						char* nom_var;
						char* tac_val;
						char* val_chave;
						char* println;
						char* mov;

						if((strcmp(item->nome != NULL ? item->nome : "", "printInt") == 0 || strcmp(item->nome != NULL ? item->nome : "", "printFloat") == 0) && argument->prox != NULL){

							print_tac(argument->nome);


							Simbolo* tac_val_item = buscaTabNome(argument->prox->nome);
							if(tac_val_item != NULL){
								val_chave = (char*) malloc(sizeof(char) * contDigf(tac_val_item->chave) + 1);
								sprintf(val_chave, "%d", tac_val_item->chave);
								tac_val = (char*) malloc(sizeof(char) * (strlen(tac_val_item->nome) + contDigf(tac_val_item->chave)) + 1);
								strcpy(tac_val, tac_val_item->nome);
								strcat(tac_val, val_chave);
								println = (char*) malloc(sizeof(char) * (8 + strlen(tac_val)) + 1);
								strcpy(println, "println ");
								strcat(println, tac_val);
								tac(println);
							}
							else{
								println = (char*) malloc(sizeof(char) * strlen(argument->prox->nome) + 1);
								strcpy(println, "println ");
								strcat(println, argument->prox->nome);
								tac(println);
							}

							
							tac("// Fim print");
						}

						else if(strcmp(item->nome != NULL ? item->nome : "", "printPoint") == 0 && argument->prox != NULL){


							print_tac(argument->nome);


							Simbolo* tac_val_item = buscaTabNome(argument->prox->nome);
							char* key = (char*) malloc(sizeof(char) * contDigf(tac_val_item->chave) + 1);
							sprintf(key, "%d", tac_val_item->chave);

							char* x = (char*) malloc(sizeof(char) * (6 + strlen(tac_val_item->nome) + strlen(key) + 1) + 1);
							strcpy(x, "print ");
							strcat(x, tac_val_item->nome);
							strcat(x, "X");
							strcat(x, key);

							char* y = (char*) malloc(sizeof(char) * (6 + strlen(tac_val_item->nome) + strlen(key) + 1) + 1);
							strcpy(y, "print ");
							strcat(y, tac_val_item->nome);
							strcat(y, "Y");
							strcat(y, key);

							print_tac("\"(x: \"");
							tac(x);
							print_tac("\", y: \"");
							tac(y);
							print_tac("\")\"");
							tac("println");


							tac("// Fim print");
						}

						else if(strcmp(item->nome != NULL ? item->nome : "", "printShape") == 0 && argument->prox != NULL){

							print_tac(argument->nome);

							// TAC imprime valor
						}
						else if(strcmp(item->nome != NULL ? item->nome : "", "scanInt") == 0 && argument != NULL){
							char* scan;
							char* nom1;
							char* key1;
							Simbolo* targ = buscaTabNome(argument->nome);
							if(targ == NULL){
								printf("\t\t###ERRO: [%s] variavel nao encontrada. [%d][%d]\n", argument->nome, $1->linha, $1->coluna);
							}
							else{

								// TAC Scan de inteiro
								// scani targ
								key1 = (char*) malloc(sizeof(char) * contDigf(targ->chave) + 1);
								sprintf(key1, "%d", targ->chave);
								nom1 = (char*) malloc(sizeof(char) * (strlen(targ->nome) + strlen(key1)) + 1);
								strcpy(nom1, targ->nome);
								strcat(nom1, key1);
								scan = (char*) malloc(sizeof(char) * (6 + strlen(nom1)) + 1);
								strcpy(scan, "scani ");
								strcat(scan, nom1);
								tac(scan);

							}

						}
						else if(strcmp(item->nome != NULL ? item->nome : "", "scanFloat") == 0 && argument->prox != NULL){
							char* scan;
							char* nom1;
							char* key1;
							Simbolo* targ = buscaTabNome(argument->nome);
							if(targ == NULL){
								printf("\t\t###ERRO: [%s] variavel nao encontrada. [%d][%d]\n", argument->nome, $1->linha, $1->coluna);
							}
							else{

								// TAC Scan de float
								// scanf targ
								key1 = (char*) malloc(sizeof(char) * contDigf(targ->chave) + 1);
								sprintf(key1, "%d", targ->chave);
								nom1 = (char*) malloc(sizeof(char) * (strlen(targ->nome) + strlen(key1)) + 1);
								strcpy(nom1, targ->nome);
								strcat(nom1, key1);
								scan = (char*) malloc(sizeof(char) * (6 + strlen(nom1)) + 1);
								strcpy(scan, "scanf ");
								strcat(scan, nom1);
								tac(scan);

							}
						}

						else if(strcmp(item->nome != NULL ? item->nome : "", "constroiPoint") == 0 && argument->prox != NULL && argument->prox->prox != NULL){
							tac("// constroiPoint()");

							Simbolo* item = buscaTabNome(argument->nome);
							item->x = atof(argument->prox->nome);
							item->y = atof(argument->prox->prox->nome);

							// TAC atribui valores para X
							aux_key = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
							sprintf(aux_key, "%d", item->chave);
							nova_var = (char*) malloc(sizeof(char) * (strlen(item->nome) + 1 + strlen(aux_key)) + 1);
							strcpy(nova_var, item->nome);
							strcat(nova_var, "X");
							strcat(nova_var, aux_key);
							mov = (char*) malloc(sizeof(char) * (4 + strlen(nova_var) + 2 + strlen(argument->prox->nome)) + 1);
							strcpy(mov, "mov ");
							strcat(mov, nova_var);
							strcat(mov, ", ");

							char* x;
							if(item->x == (int) item->x){
								x = (char*) malloc(sizeof(char) * (contDigf(item->x) + 2) + 1);
								gcvt(item->x, contDigf(item->x) + 1, x);
								strcat(x, ".0");
							}
							else{
								x = (char*) malloc(sizeof(char) * contDigf(item->x) + 1);
								gcvt(item->x, contDigf(item->x) + 1, x);
							}

							strcat(mov, x);
							tac(mov);

							// TAC atribui valores para Y
							val_chave = (char*) malloc(sizeof(char) * contDigf(item->chave) + 1);
							sprintf(val_chave, "%d", item->chave);
							nom_var = (char*) malloc(sizeof(char) * (strlen(item->nome) + 1 + strlen(val_chave)) + 1);
							strcpy(nom_var, item->nome);
							strcat(nom_var, "Y");
							strcat(nom_var, val_chave);
							tac_val = (char*) malloc(sizeof(char) * (4 + strlen(nom_var) + 2 + strlen(argument->prox->prox->nome)) + 1);
							strcpy(tac_val, "mov ");
							strcat(tac_val, nom_var);
							strcat(tac_val, ", ");

							char* y;
							if(item->y == (int) item->y){
								y = (char*) malloc(sizeof(char) * (contDigf(item->y) + 2) + 1);
								gcvt(item->y, contDigf(item->y) + 1, y);
								strcat(y, ".0");
							}
							else{
								y = (char*) malloc(sizeof(char) * contDigf(item->y) + 1);
								gcvt(item->y, contDigf(item->y) + 1, y);
							}

							strcat(tac_val, y);
							tac(tac_val);
						}

						else if(strcmp(item->nome != NULL ? item->nome : "", "constroiShape") == 0 && argument->prox != NULL){}
						else if(strcmp(item->nome != NULL ? item->nome : "", "Perimetro") == 0){}
						else if(strcmp(item->nome != NULL ? item->nome : "", "IsCollided") == 0 && argument->prox != NULL){}
						else if(strcmp(item->nome != NULL ? item->nome : "", "IsIn") == 0 && argument->prox != NULL){}
					}








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


								// SE NAO EH FUNCAO PROPRIA DA LINGUAGEM
								if(NFUNCLING){
									// TAC EMPILHA parametros
									char* tac_val;
									char* se_lit;
									Simbolo* item = buscaTabNome(argumento->nome);
									if(item == NULL){
										// if(argumento->nome[0] == '\"'){
										// 	tac("param texto");

										// }
										tac_val = (char*) malloc(sizeof(char) * (7 + strlen(argumento->nome)) + 1);
										strcpy(tac_val, "param ");
										strcat(tac_val, strdup(argumento->nome));
										tac(tac_val);
									}
									else{
										tac_val = (char*) malloc(sizeof(char) * (7 + strlen(item->nome) + contDigf(item->chave)) + 1);
										strcpy(tac_val, "param ");
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


					// SE NAO EH FUNCAO PROPRIA DA LINGUAGEM
					if(NFUNCLING){
						// TAC CRIA LABEL PRA CHAMADA
						char* oper = (char*) malloc(sizeof(char) * (4 + strlen(item->nome) + 2 + contDigf(item->qtdParams)) + 1);
						strcpy(oper, "call ");
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
				strcpy(val, strdup($1->valor));
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
	// tac_input = fopen("./tac_code.txt", "wr");
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
			fputs(nome, tac_ftab);
			break;

		case Decimal:
			fputs("float ", tac_ftab);
			fputs(nome, tac_ftab);
			break;

		case Ponto:
			fputs("float ", tac_ftab);
			fputs(nome, tac_ftab);
			break;

		case Forma:
			// fputs("float ", tac_ftab);
			// char* x = (char*) malloc(sizeof(char) * (strlen(nome) + 1) + 1);
			// char* y = (char*) malloc(sizeof(char) * (strlen(nome) + 1) + 1);
			// fputs(x, tac_ftab);
			// fputs(y, tac_ftab);
			break;

		case Literal:
			fputs("char ", tac_ftab);
			fputs(nome, tac_ftab);
			break;

	}
	
	fputs("\n", tac_ftab);


	return 0;
}

int tac(const char* val){
	char* valor = (char*) malloc(sizeof(char) * (strlen(val) + 2) + 1);
	strcpy(valor, val);
	strcat(valor, "\n");
	return fputs((valor != NULL ? valor : ""), tac_input);
}

void fim_tac(){
	fclose(tac_input);
	fclose(tac_ftab);

	char ch;
	tac_input = fopen("tac_code.txt", "r");
	tac_ftab = fopen("tac_tab.tac", "a");
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
	printf("%s", texto);
	for(i = 0; i < s.qtd; i++){
		retorno = printf("{p[%d] = (x: %f, y: %f)\n", i, s.p[i].x, s.p[i].y);
	}
	return retorno;
}

int print_tac(char* texto){

	tac("// Ini print");
	// TAC cria nova var na tab de simbolos do tac pra armazenar a string
	// char str K = "texto"
	char* nova_var = (char*) malloc(sizeof(char) * (5 + contDigf(tac_str) + 3 + strlen(texto)) + 1);
	char* aux_key = (char*) malloc(sizeof(char) * contDigf(tac_str) + 1);
	sprintf(aux_key, "%d", tac_str);
	strcpy(nova_var, "str");
	strcat(nova_var, aux_key);
	strcat(nova_var, "[]");
	strcat(nova_var, " = ");
	strcat(nova_var, texto);
	tac_tab(Literal, nova_var);

	// Cria var tamanho da strg
	int tam_aux = strlen(texto) - 2;
	char* tamanho = (char*) malloc(sizeof(char) * contDigf(tam_aux) + 1);
	sprintf(tamanho, "%d", tam_aux);
	char* tac_tam = (char*) malloc(sizeof(char) * (4 + strlen(aux_key) + 3 + strlen(tamanho)) + 1);
	strcpy(tac_tam, "size");
	strcat(tac_tam, aux_key);
	strcat(tac_tam, " = ");
	strcat(tac_tam, tamanho);
	tac_tab(Inteiro, tac_tam);
	char* size_nom = (char*) malloc(sizeof(char) * (4 + strlen(aux_key)) + 1);
	strcpy(size_nom, "size");
	strcat(size_nom, aux_key);


	tac("mov $0, 0");
		char* sub = (char*) malloc(sizeof(char) * (4 + 4 + strlen(size_nom) + 3) + 1);
		strcpy(sub, "sub $1, ");
		strcat(sub, size_nom);
		strcat(sub, ", 1");
	tac(sub);
	// while $0 < size
		// TAC cria label pra impressão
		char* label = (char*) malloc(sizeof(char) * (7 + strlen(aux_key) + 1) + 1);
		strcpy(label, "IMPRIME");
		strcat(label, aux_key);
		strcat(label, ":");
	tac(label);
		char* slt = (char*) malloc(sizeof(char) * (12 + strlen(size_nom)) + 1);
		strcpy(slt, "slt $2, $0, ");
		strcat(slt, size_nom);
	tac(slt);
		char* auxlabel2 = (char*) malloc(sizeof(char) * contDigf(tac_str2) + 1);
		sprintf(auxlabel2, "%d", tac_str2++);
		char* label2p2 = (char*) malloc(sizeof(char) * (7 + strlen(aux_key) + 1 + strlen(auxlabel2)) + 1);
		strcpy(label2p2, "IMPRIME");
		strcat(label2p2, aux_key);
		strcat(label2p2, "p");
		strcat(label2p2, auxlabel2);
		char* brz = (char*) malloc(sizeof(char) * (4 + strlen(label2p2) + 4) + 1);
		strcpy(brz, "brz ");
		strcat(brz, label2p2);
		strcat(brz, ", $2");
	tac(brz);
		char* v = (char*) malloc(sizeof(char) * (3 + strlen(aux_key) + 4) + 1);
		strcpy(v, "str");
		strcat(v, aux_key);
		strcat(v, "[$0]");
	// print v[$0]
		char* strK = (char*) malloc(sizeof(char) * (3 + strlen(aux_key)) + 1);
		strcpy(strK, "str");
		strcat(strK, aux_key);
		char* mov1 = (char*) malloc(sizeof(char) * (4 + 4 + 1 + strlen(strK)) + 1);
		strcpy(mov1, "mov $2, &");
		strcat(mov1, strK);
	tac(mov1);
	tac("mov $2, $2[$0]");
	tac("print $2");
	tac("add $0, $0, 1");
		char* jmp = (char*) malloc(sizeof(char) * (5 + strlen(label)) + 1);
		strcpy(jmp, "jump ");
		char* nom_label = (char*) malloc(sizeof(char) * (7 + strlen(aux_key)) + 1);
		strcpy(nom_label, "IMPRIME");
		strcat(nom_label, aux_key);
		strcat(jmp, nom_label);
	tac(jmp);
		char* label2 = (char*) malloc(sizeof(char) * (7 + strlen(aux_key) + 1 + strlen(auxlabel2) + 1) + 1);
		strcpy(label2, "IMPRIME");
		strcat(label2, aux_key);
		strcat(label2, "p");
		strcat(label2, auxlabel2);
		strcat(label2, ":");
	tac(label2);


	if(strcmp(nova_var != NULL ? nova_var : "", "") != 0){
		free(nova_var);
		nova_var = NULL;
	}
	// if(strcmp(aux_key != NULL ? aux_key : "", "") != 0){
	// 	free(aux_key);
	// 	aux_key = NULL;
	// }
	if(strcmp(tac_tam != NULL ? tac_tam : "", "") != 0){
		free(tac_tam);
		tac_tam = NULL;
	}
	// if(strcmp(tamanho != NULL ? tamanho : "", "") != 0){
	// 	free(tamanho);
	// 	tamanho = NULL;
	// }
	if(strcmp(size_nom != NULL ? size_nom : "", "") != 0){
		free(size_nom);
		size_nom = NULL;
	}
	if(strcmp(sub != NULL ? sub : "", "") != 0){
		free(sub);
		sub = NULL;
	}
	if(strcmp(label != NULL ? label : "", "") != 0){
		free(label);
		label = NULL;
	}
	if(strcmp(slt != NULL ? slt : "", "") != 0){
		free(slt);
		slt = NULL;
	}
	// if(strcmp(auxlabel2 != NULL ? auxlabel2 : "", "") != 0){
	// 	free(auxlabel2);
	// 	auxlabel2 = NULL;
	// }
	if(strcmp(label2p2 != NULL ? label2p2 : "", "") != 0){
		free(label2p2);
		label2p2 = NULL;
	}
	if(strcmp(brz != NULL ? brz : "", "") != 0){
		free(brz);
		brz = NULL;
	}
	if(strcmp(v != NULL ? v : "", "") != 0){
		free(v);
		v = NULL;
	}
	if(strcmp(strK != NULL ? strK : "", "") != 0){
		free(strK);
		strK = NULL;
	}
	if(strcmp(mov1 != NULL ? mov1 : "", "") != 0){
		free(mov1);
		mov1 = NULL;
	}
	if(strcmp(jmp != NULL ? jmp : "", "") != 0){
		free(jmp);
		jmp = NULL;
	}
	if(strcmp(nom_label != NULL ? nom_label : "", "") != 0){
		free(nom_label);
		nom_label = NULL;
	}
	if(strcmp(label2 != NULL ? label2 : "", "") != 0){
		free(label2);
		label2 = NULL;
	}


	tac_str++;
	tac_str2 = 0;
	return 0;
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
	sprintf(novo->valor, "%d", val);
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
	tac_input = fopen("./tac_code.txt", "w");
	tac_ftab = fopen("./tac_tab.tac", "w");
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

