#include "TabSimbolo.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern Contexto ctx_global;
extern Contexto* ctx_atual;
extern FILE* tac_input;

void criaTab(){
	ctx_global.criador = NULL;
	ctx_global.primeiro = NULL;

	ctx_atual = &ctx_global;

	insere("int", "", KEYWORD, Inteiro, 0, NULL);
	insere("float", "", KEYWORD, Decimal, 0, NULL);
	insere("point", "",  KEYWORD, Ponto, 0, NULL);
	insere("shape", "", KEYWORD, Forma, 0, NULL);

	insere("return", "", OTHER, other, 0, NULL);
	insere("if", "", OTHER, other, 0, NULL);
	insere("else", "", OTHER, other, 0, NULL);
	insere("for", "", OTHER, other, 0, NULL);

	Parametro* printInt = (Parametro*) malloc(sizeof(Parametro));
	printInt->nome = (char*) malloc(sizeof(char) * 6);
	printInt->nome = "texto";
	printInt->qtd = 2;
	printInt->tipo = Literal;
	printInt->isEnd = 0;
	
	printInt->prox = (Parametro*) malloc(sizeof(Parametro));
	printInt->prox->nome = (char*) malloc(sizeof(char) * 6);
	printInt->prox->nome = "valor";
	printInt->prox->qtd = 2;
	printInt->prox->tipo = Inteiro;
	printInt->prox->isEnd = 0;

	insere("printInt", "", FUNC, Inteiro, 2, printInt);


	Parametro* printFloat = (Parametro*) malloc(sizeof(Parametro));
	printFloat->nome = (char*) malloc(sizeof(char) * 6);
	printFloat->nome = "texto";
	printFloat->qtd = 2;
	printFloat->tipo = Literal;
	printFloat->isEnd = 0;
	
	printFloat->prox = (Parametro*) malloc(sizeof(Parametro));
	printFloat->prox->nome = (char*) malloc(sizeof(char) * 6);
	printFloat->prox->nome = "valor";
	printFloat->prox->qtd = 2;
	printFloat->prox->tipo = Decimal;
	printFloat->prox->isEnd = 0;

	insere("printFloat", "", FUNC, Inteiro, 2, printFloat);


	Parametro* printPoint = (Parametro*) malloc(sizeof(Parametro));
	printPoint->nome = (char*) malloc(sizeof(char) * 6);
	printPoint->nome = "texto";
	printPoint->qtd = 2;
	printPoint->tipo = Literal;
	printPoint->isEnd = 0;
	
	printPoint->prox = (Parametro*) malloc(sizeof(Parametro));
	printPoint->prox->nome = (char*) malloc(sizeof(char) * 6);
	printPoint->prox->nome = "valor";
	printPoint->prox->qtd = 2;
	printPoint->prox->tipo = Ponto;
	printPoint->prox->isEnd = 0;

	insere("printPoint", "", FUNC, Inteiro, 2, printPoint);


	Parametro* printShape = (Parametro*) malloc(sizeof(Parametro));
	printShape->nome = (char*) malloc(sizeof(char) * 6);
	printShape->nome = "texto";
	printShape->qtd = 2;
	printShape->tipo = Literal;
	printShape->isEnd = 0;
	
	printShape->prox = (Parametro*) malloc(sizeof(Parametro));
	printShape->prox->nome = (char*) malloc(sizeof(char) * 6);
	printShape->prox->nome = "valor";
	printShape->prox->qtd = 2;
	printShape->prox->tipo = Forma;
	printShape->prox->isEnd = 0;

	insere("printShape", "", FUNC, Inteiro, 2, printShape);


	Parametro* scanInt = (Parametro*) malloc(sizeof(Parametro));
	scanInt->nome = (char*) malloc(sizeof(char) * 4);
	scanInt->nome = "&var";
	scanInt->qtd = 1;
	scanInt->tipo = Inteiro;
	scanInt->isEnd = 1;

	insere("scanInt", "", FUNC, Inteiro, 1, scanInt);


	Parametro* scanFloat = (Parametro*) malloc(sizeof(Parametro));
	scanFloat->nome = (char*) malloc(sizeof(char) * 4);
	scanFloat->nome = "&var";
	scanFloat->qtd = 1;
	scanFloat->tipo = Decimal;
	scanFloat->isEnd = 1;

	insere("scanFloat", "", FUNC, Inteiro, 1, scanFloat);


	Parametro* constroiPoint = (Parametro*) malloc(sizeof(Parametro));
	constroiPoint->nome = (char*) malloc(sizeof(char) * 4);
	constroiPoint->nome = "&var";
	constroiPoint->qtd = 3;
	constroiPoint->tipo = Ponto;
	constroiPoint->isEnd = 1;
	
	constroiPoint->prox = (Parametro*) malloc(sizeof(Parametro));
	constroiPoint->prox->nome = (char*) malloc(sizeof(char) * 6);
	constroiPoint->prox->nome = "val_x";
	constroiPoint->prox->qtd = 3;
	constroiPoint->prox->tipo = Decimal;
	constroiPoint->prox->isEnd = 0;

	constroiPoint->prox->prox = (Parametro*) malloc(sizeof(Parametro));
	constroiPoint->prox->prox->nome = (char*) malloc(sizeof(char) * 6);
	constroiPoint->prox->prox->nome = "val_y";
	constroiPoint->prox->prox->qtd = 3;
	constroiPoint->prox->prox->tipo = Decimal;
	constroiPoint->prox->prox->isEnd = 0;

	insere("constroiPoint", "", FUNC, Inteiro, 3, constroiPoint);


	Parametro* constroiShape = (Parametro*) malloc(sizeof(Parametro));
	constroiShape->nome = (char*) malloc(sizeof(char) * 4);
	constroiShape->nome = "&var";
	constroiShape->qtd = 2;
	constroiShape->tipo = Forma;
	constroiShape->isEnd = 1;
	
	constroiShape->prox = (Parametro*) malloc(sizeof(Parametro));
	constroiShape->prox->nome = (char*) malloc(sizeof(char) * 6);
	constroiShape->prox->nome = "valor";
	constroiShape->prox->qtd = 2;
	constroiShape->prox->tipo = Ponto;
	constroiShape->prox->isEnd = 0;

	insere("constroiShape", "", FUNC, Inteiro, 2, constroiShape);


	Parametro* Perimetro = (Parametro*) malloc(sizeof(Parametro));
	Perimetro->nome = (char*) malloc(sizeof(char) * 4);
	Perimetro->nome = "var";
	Perimetro->qtd = 1;
	Perimetro->tipo = Forma;
	Perimetro->isEnd = 0;

	insere("Perimetro", "", FUNC, Decimal, 0, Perimetro);


	Parametro* IsIn = (Parametro*) malloc(sizeof(Parametro));
	IsIn->nome = (char*) malloc(sizeof(char) * 6);
	IsIn->nome = "forma";
	IsIn->qtd = 2;
	IsIn->tipo = Forma;
	IsIn->isEnd = 0;
	
	IsIn->prox = (Parametro*) malloc(sizeof(Parametro));
	IsIn->prox->nome = (char*) malloc(sizeof(char) * 6);
	IsIn->prox->nome = "ponto";
	IsIn->prox->qtd = 2;
	IsIn->prox->tipo = Ponto;
	IsIn->prox->isEnd = 0;

	insere("IsIn", "", FUNC, Inteiro, 2, IsIn);


	Parametro* IsCollided = (Parametro*) malloc(sizeof(Parametro));
	IsCollided->nome = (char*) malloc(sizeof(char) * 7);
	IsCollided->nome = "forma1";
	IsCollided->qtd = 2;
	IsCollided->tipo = Forma;
	IsCollided->isEnd = 0;
	
	IsCollided->prox = (Parametro*) malloc(sizeof(Parametro));
	IsCollided->prox->nome = (char*) malloc(sizeof(char) * 7);
	IsCollided->prox->nome = "forma2";
	IsCollided->prox->qtd = 2;
	IsCollided->prox->tipo = Forma;
	IsCollided->prox->isEnd = 0;

	insere("IsCollided", "", FUNC, Inteiro, 2, IsCollided);

}

Simbolo* buscaAquiNome(char* nome){
	if(ctx_atual == NULL){
		ctx_atual = &ctx_global;
	}
	if(ctx_atual->primeiro != NULL){
		TabSimbolos atual = ctx_atual->primeiro;

		while(atual != NULL){
			if(strcmp(atual->nome != NULL ? atual->nome : "", "") != 0){
				if(strcmp(atual->nome != NULL ? atual->nome : "", nome) == 0){
					return atual;
				}
			}
			atual = atual->prox;
		}
	}

	char* temp_nome = strdup(nome);
	if(temp_nome != NULL){
		if(temp_nome[0] == '&'){
			int i;
			for(i = 0; temp_nome[i] != '\0'; i++){
				temp_nome[i] = nome[i+1];
			}
			return buscaAquiNome(temp_nome);
		}
	}

	return NULL;
}

Simbolo* buscaAquiVal(char* valor){
	if(ctx_atual == NULL){
		ctx_atual = &ctx_global;
	}
	if(ctx_atual->primeiro != NULL){
		TabSimbolos atual = ctx_atual->primeiro;
		
		while(atual != NULL){
			if(strcmp(atual->valor != NULL ? atual->valor : "", valor) == 0 && (strcmp(atual->nome != NULL ? atual->nome : "", "") == 0 || atual->tipo == Literal)){
				return atual;
			}
			atual = atual->prox;
		}
	}

	return NULL;
}

// RETORNO: retorna a chave do elemento encontrado, -1 se nao existir
Simbolo* buscaTabNome(char* nome){
	if(ctx_atual == NULL){
		ctx_atual = &ctx_global;
	}
	TabSimbolos atual = ctx_atual->primeiro;
	Contexto* contexto = ctx_atual;
	
	while(contexto->criador != NULL){
		while(atual != NULL){
			if(strcmp(atual->nome != NULL ? atual->nome : "", nome) == 0){
				return atual;
			}
			if(strcmp(atual->nome != NULL ? atual->nome : "", "") != 0){
				char* temp_atual = strdup(atual->nome);
				if(temp_atual != NULL){
					if(temp_atual[0] == '&'){
						int i;
						for(i = 0; temp_atual[i] != '\0'; i++){
							temp_atual[i] = atual->nome[i+1];
						}
						if(strcmp(temp_atual != NULL ? temp_atual : "", nome) == 0){
							return atual;
						}
					}
				}
			}

			atual = atual->prox;
		}
		contexto = contexto->criador->meu;
	}
	atual = contexto->primeiro;
	while(atual != NULL){
		if(strcmp(atual->nome != NULL ? atual->nome : "", nome) == 0){
			return atual;
		}
		atual = atual->prox;
	}

	char* temp_nome = strdup(nome);
	if(temp_nome != NULL){
		if(temp_nome[0] == '&'){
			int i;
			for(i = 0; temp_nome[i] != '\0'; i++){
				temp_nome[i] = nome[i+1];
			}
			return buscaTabNome(temp_nome);
		}
	}

	return NULL;
}

// RETORNO: retorna a chave do elemento encontrado, -1 se nao existir
Simbolo* buscaTabVal(char* valor){
	if(ctx_atual == NULL){
		ctx_atual = &ctx_global;
	}
	TabSimbolos atual = ctx_atual->primeiro;
	Contexto* contexto = ctx_atual;
	
	while(contexto->criador != NULL){
		while(atual != NULL){
			if(strcmp(atual->valor != NULL ? atual->valor : "", valor) == 0 && (strcmp(atual->nome != NULL ? atual->nome : "", "") == 0 || atual->tipo == Literal)){
				return atual;
			}
			atual = atual->prox;
		}
		contexto = contexto->criador->meu;
	}
	atual = contexto->primeiro;
	while(atual != NULL){
		if(strcmp(atual->valor != NULL ? atual->valor : "", valor) == 0){
			return atual;
		}
		atual = atual->prox;
	}

	return NULL;
}

Simbolo* insere(char* nome, char* valor, int isVar, TYPE tipo, int qtdParams, Parametro* params){
	static unsigned int prox_chave = -19;
	Simbolo* busca = NULL;
	if(tipo != Literal){
		if(strcmp(nome != NULL ? nome : "", "") == 0){
			busca = buscaAquiVal(valor);
		}
		else{
			busca = buscaAquiNome(nome);
		}
	}
	// if(busca == -1){
	// 	busca = buscaAquiVal(raiz, valor);
	// }
	if(busca == NULL){
		TabSimbolos novo = (TabSimbolos) malloc(sizeof(Simbolo));
		if(strcmp("", nome) == 0){
			novo->nome = NULL;
		}
		else{
			novo->nome = strdup(nome);
		}
		if(strcmp("", valor) == 0){
			novo->valor = NULL;
		}
		else{
			novo->valor = strdup(valor);
		}
		novo->chave = prox_chave++;
		novo->qtd = 1;
		novo->isVar = isVar;
		novo->isEnd = 0;
		if(novo->nome != NULL){
			if(novo->nome[0] == '&'){
				novo->isEnd = 1;
			}
		}
		novo->tipo = tipo;
		novo->meu = ctx_atual;
		novo->prox = NULL;
		if(isVar == FUNC){
			novo->qtdParams = qtdParams;
			novo->params = params;
			novo->interno = (Contexto*) malloc(sizeof(Contexto));
			novo->interno->criador = novo;
			novo->interno->primeiro = NULL;
		}


		TabSimbolos atual;
		if(ctx_atual->primeiro != NULL){
			atual = ctx_atual->primeiro;
			while(atual->prox != NULL){
				atual = atual->prox;
			}
			atual->prox = novo;
			return atual->prox;
		}
		else{
			ctx_atual->primeiro = novo;
			return ctx_atual->primeiro;
		}
	}
	else{
		busca->qtd++;
		return busca;
	}

}

void printAqui(Contexto* contexto){
	if(contexto != NULL){
		TabSimbolos inicial = contexto->primeiro;
		if(inicial != NULL){
			printf("\n\n\n######## TABELA DE SIMBOLOS, CONTEXTO: %s ########\n\n", contexto->criador == NULL ? "global" : contexto->criador->nome);

			printf("CHAVE QTD VAR/FUNC     TIPO\t    NOME\tCONTEUDO\tPARAMETROS\n");

			while(inicial != NULL){
				printf(" %3d %3d  %7s", inicial->chave, inicial->qtd, inicial->isVar == VAR ? "VAR" : (inicial->isVar == FUNC ? "FUNC" : (inicial->isVar == KEYWORD ? "Keyword" : "Outro")));
				switch(inicial->tipo){
					case Inteiro:
						printf("%10s", "int");
					break;

					case Decimal:
						printf("%10s", "float");
					break;

					case Ponto:
						printf("%10s", "point");
					break;

					case Forma:
						printf("%10s", "shape");
					break;

					case Literal:
						printf("%10s", "Literal");
					break;
				
					default:
						printf("%10s", "Outro");
						break;
				}

				printf("%13s%14s", inicial->nome != NULL ? (strcmp(inicial->nome, "") != 0 ? inicial->nome : "(nulo)") : "(nulo)", inicial->valor != NULL ? inicial->valor : "(nulo)");


				if(inicial->isVar == FUNC){
					printf("%5s", "(");
					int i;
					Parametro* atual2;
					atual2 = inicial->params;
					for(i = 0; atual2 != NULL; atual2 = atual2->prox){
						switch(atual2->tipo){
							case Inteiro:
								printf("int ");
							break;

							case Decimal:
								printf("float ");
							break;

							case Ponto:
								printf("point ");
							break;

							case Forma:
								printf("shape ");
							break;
						
							default:
								printf("Literal ");
								break;
						}

						printf("%s%s", atual2->nome, atual2->prox != NULL ? ", " : "");
					}
					printf(")");

				}

				printf("\n");
				inicial = inicial->prox;
			}

		}


		TabSimbolos atual = contexto->primeiro;
		while(atual != NULL){
			if(atual->isVar == FUNC){
				if(atual->interno != NULL){
					if(atual->interno->primeiro != NULL){
						printAqui(atual->interno);
					}
				}
			}
			atual = atual->prox;
		}



	}
}

void printTab(){
	Contexto* contexto = &ctx_global;

	printAqui(contexto);


	
}

void destroiParams(Parametro* parametro){
	if(parametro != NULL){
		if(parametro->prox != NULL){
			destroiParams(parametro->prox);
		}
		parametro->nome = NULL;
		free(parametro);
		parametro = NULL;
	}
}

void destroiAqui(Contexto* contexto){
	if(contexto != NULL){
		TabSimbolos atual;
		atual = contexto->primeiro;
		while(atual != NULL){
			if(atual->isEnd != 1){
				if(atual->nome != NULL && strcmp(atual->nome, "") != 0){
					free(atual->nome);
				}
				atual->nome = NULL;
				if(atual->valor != NULL && strcmp(atual->valor, "") != 0){
					free(atual->valor);
				}
				atual->valor = NULL;
				if(atual->params != NULL){
					destroiParams(atual->params);
					atual->params = NULL;
				}


				if(atual->interno != NULL){
					if(atual->interno->primeiro != NULL){
						destroiAqui(atual->interno);
					}
				}

			}
			TabSimbolos temp = atual->prox;
			if(atual->prox != NULL){
				free(atual->prox);
				atual->prox = NULL;
			}
			atual = temp;
		}
		
	}
}

void destroiTab(){
	Contexto* contexto = &ctx_global;

	destroiAqui(contexto);
}
