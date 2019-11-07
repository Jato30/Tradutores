#include "TabSimbolo.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void criaTab(TabSimbolos* raiz){
	(*raiz) = NULL;

	insere(raiz, "int", "", KEYWORD, Inteiro, 0, NULL);
	insere(raiz, "float", "", KEYWORD, Decimal, 0, NULL);
	insere(raiz, "point", "",  KEYWORD, Ponto, 0, NULL);
	insere(raiz, "shape", "", KEYWORD, Forma, 0, NULL);

	insere(raiz, "return", "", OTHER, other, 0, NULL);
	insere(raiz, "if", "", OTHER, other, 0, NULL);
	insere(raiz, "else", "", OTHER, other, 0, NULL);
	insere(raiz, "for", "", OTHER, other, 0, NULL);

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

	insere(raiz, "printInt", "", FUNC, Inteiro, 2, printInt);


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

	insere(raiz, "printFloat", "", FUNC, Inteiro, 2, printFloat);


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

	insere(raiz, "printPoint", "", FUNC, Inteiro, 2, printPoint);


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

	insere(raiz, "printShape", "", FUNC, Inteiro, 2, printShape);


	Parametro* scanInt = (Parametro*) malloc(sizeof(Parametro));
	scanInt->nome = (char*) malloc(sizeof(char) * 4);
	scanInt->nome = "var";
	scanInt->qtd = 2;
	scanInt->tipo = Inteiro;
	scanInt->isEnd = 1;
	
	scanInt->prox = (Parametro*) malloc(sizeof(Parametro));
	scanInt->prox->nome = (char*) malloc(sizeof(char) * 6);
	scanInt->prox->nome = "valor";
	scanInt->prox->qtd = 2;
	scanInt->prox->tipo = Inteiro;
	scanInt->prox->isEnd = 0;

	insere(raiz, "scanInt", "", FUNC, Inteiro, 2, scanInt);


	Parametro* scanFloat = (Parametro*) malloc(sizeof(Parametro));
	scanFloat->nome = (char*) malloc(sizeof(char) * 4);
	scanFloat->nome = "var";
	scanFloat->qtd = 2;
	scanFloat->tipo = Decimal;
	scanFloat->isEnd = 1;
	
	scanFloat->prox = (Parametro*) malloc(sizeof(Parametro));
	scanFloat->prox->nome = (char*) malloc(sizeof(char) * 6);
	scanFloat->prox->nome = "valor";
	scanFloat->prox->qtd = 2;
	scanFloat->prox->tipo = Decimal;
	scanFloat->prox->isEnd = 0;

	insere(raiz, "scanFloat", "", FUNC, Inteiro, 2, scanFloat);


	Parametro* constroiPoint = (Parametro*) malloc(sizeof(Parametro));
	constroiPoint->nome = (char*) malloc(sizeof(char) * 4);
	constroiPoint->nome = "var";
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

	insere(raiz, "constroiPoint", "", FUNC, Inteiro, 3, constroiPoint);


	Parametro* constroiShape = (Parametro*) malloc(sizeof(Parametro));
	constroiShape->nome = (char*) malloc(sizeof(char) * 4);
	constroiShape->nome = "var";
	constroiShape->qtd = 2;
	constroiShape->tipo = Forma;
	constroiShape->isEnd = 1;
	
	constroiShape->prox = (Parametro*) malloc(sizeof(Parametro));
	constroiShape->prox->nome = (char*) malloc(sizeof(char) * 6);
	constroiShape->prox->nome = "valor";
	constroiShape->prox->qtd = 2;
	constroiShape->prox->tipo = Ponto;
	constroiShape->prox->isEnd = 0;

	insere(raiz, "constroiShape", "", FUNC, Inteiro, 2, constroiShape);


	Parametro* Perimetro = (Parametro*) malloc(sizeof(Parametro));
	Perimetro->nome = (char*) malloc(sizeof(char) * 4);
	Perimetro->nome = "var";
	Perimetro->qtd = 1;
	Perimetro->tipo = Forma;
	Perimetro->isEnd = 0;

	insere(raiz, "Perimetro", "", FUNC, Decimal, 0, Perimetro);


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

	insere(raiz, "IsIn", "", FUNC, Inteiro, 2, IsIn);


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

	insere(raiz, "IsCollided", "", FUNC, Inteiro, 2, IsCollided);
}

// RETORNO: retorna a chave do elemento encontrado, -1 se nao existir
int buscaTabNome(TabSimbolos* raiz, char* nome){
	if((*raiz) == NULL){
		// printf("\nTabela vazia\n");
		return -1;
	}
	else if(nome == NULL || strcmp(nome, "") == 0){
		// printf("\nNome vazio\n");
		return -1;
	}
	else{
		TabSimbolos atual;
		atual = (*raiz);
		while(atual != NULL){
			if(strcmp("", atual->nome != NULL ? atual->nome : "") == 0){}
			else if(strcmp(atual->nome, nome) == 0){
				// printf("\tJa existe %s na tabela de simbolos\n", nome);
				return atual->chave;
			}
			atual = atual->prox != NULL ? atual->prox : NULL;
		}

		// printf("Nenhuma ocorrencia repetida.\n");
		return -1;
	}
}

// RETORNO: retorna a chave do elemento encontrado, -1 se nao existir
int buscaTabVal(TabSimbolos* raiz, char* valor){
	if((*raiz) == NULL){
		// printf("\nTabela vazia\n");
		return -1;
	}
	else if(valor == NULL || strcmp(valor, "") == 0){
		// printf("\nValor vazio\n");
		return -1;
	}
	else{
		TabSimbolos atual;
		atual = (*raiz);
		while(atual != NULL){
			if(strcmp("", atual->valor != NULL ? atual->valor : "") == 0){}
			else if(strcmp(atual->valor != NULL ? atual->valor : "", valor) == 0){
				// printf("\tJa existe %s na tabela de simbolos\n", nome);
				return atual->chave;
			}
			atual = atual->prox;
		}

		// printf("Nenhuma ocorrencia repetida.\n");
		return -1;
	}
}

void insere(TabSimbolos* raiz, char* nome, char* valor, int isVar, TYPE tipo, int qtdParams, Parametro* params){

	int busca = buscaTabNome(raiz, nome);
	// if(busca == -1){
	// 	busca = buscaTabVal(raiz, valor);
	// }
	if(busca == -1){
		if(*raiz == NULL){  //Lista vazia
			*raiz = (TabSimbolos) malloc(sizeof(Simbolo));
			if(strcmp("", nome) == 0){
				(*raiz)->nome = NULL;
			}
			else{
				(*raiz)->nome = strdup(nome);
			}
			if(strcmp("", valor) == 0){
				(*raiz)->valor = NULL;
			}
			else{
				(*raiz)->valor = strdup(valor);
			}
			(*raiz)->chave = 1;
			(*raiz)->qtd = 1;
			(*raiz)->isVar = isVar;
			(*raiz)->tipo = tipo;
			(*raiz)->prox = NULL;
			if(isVar == FUNC){
				(*raiz)->qtdParams = qtdParams;
				(*raiz)->params = params;
				(*raiz)->tabContexto = NULL;
			}
		}
		else{
			TabSimbolos ultimoLista;
			int aux_chave = 1;

			ultimoLista = *raiz;
			while(ultimoLista->prox != NULL){
				aux_chave++;
				ultimoLista = ultimoLista->prox;
			}
			aux_chave++;

			ultimoLista->prox = (TabSimbolos) malloc(sizeof(Simbolo));
			if(strcmp("", nome) == 0){
				ultimoLista->prox->nome = NULL;
			}
			else{
				ultimoLista->prox->nome = strdup(nome);
			}
			if(strcmp("", valor) == 0){
				ultimoLista->prox->valor = NULL;
			}
			else{
				ultimoLista->prox->valor = strdup(valor);
			}
			ultimoLista->prox->chave = aux_chave;
			ultimoLista->prox->qtd = 1;
			ultimoLista->prox->isVar = isVar;
			ultimoLista->prox->tipo = tipo;
			if(isVar == FUNC){
				ultimoLista->prox->qtdParams = qtdParams;
				ultimoLista->prox->params = params;
			}
			ultimoLista->prox->prox = NULL;
		}

	}
	else{
		TabSimbolos atual;
		atual = (*raiz);   /*@ Primeiro elemento*/

		while(atual != NULL){
			if(atual->chave == busca){
				atual->qtd++;
				break;
			}
			atual = atual->prox;
		}
	}

}

void printTab(TabSimbolos* raiz){
	printf("\n\nTABELA DE SIMBOLOS ########\n\n");

	if(*raiz == NULL){
		printf("\nTabela de Simbolos vazia\n");
	}
	else{
		TabSimbolos atual;
		atual = *raiz;
		printf("CHAVE\tQUANTIDADE\tVAR/FUNC\tTIPO\t\tNOME\t   CONTEUDO\tPARAMETROS\n");

		while(atual != NULL){
			printf("%d\t%6d\t%14s\t\t", atual->chave, atual->qtd, atual->isVar == VAR ? "VAR" : (atual->isVar == FUNC ? "FUNC" : (atual->isVar == KEYWORD ? "Keyword" : "Outro")));
			switch(atual->tipo){
				case Inteiro:
					printf("int\t");
				break;

				case Decimal:
					printf("float\t");
				break;

				case Ponto:
					printf("point\t");
				break;

				case Forma:
					printf("shape\t");
				break;

				case Literal:
					printf("Literal\t");
				break;
			
				default:
					printf("Outro\t");
					break;
			}
			printf("%14s%14s\t", atual->nome != NULL ? atual->nome : "(nulo)", atual->valor != NULL ? atual->valor : "(nulo)");

			if(atual->isVar == FUNC){
				printf("(");
				int i;
				Parametro* atual2;
				atual2 = atual->params;
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

					printf("%s%s%s", atual2->isEnd == 0 ? "" : "&", atual2->nome, atual2->prox != NULL ? ", " : "");
				}
				printf(")");
			}

			printf("\n");
			atual = atual->prox;
		}
	}

}

void destroiParams(Parametro* parametro){
	if(parametro != NULL){
		if(parametro->prox != NULL){
			destroiParams(parametro->prox);
		}
		// if(parametro->nome != NULL){
		// 	free(parametro->nome);
			parametro->nome = NULL;
		// }
		free(parametro);
		parametro = NULL;
	}
}

void destroiTab(TabSimbolos* raiz){
	int i = 0;
	if((*raiz) != NULL){
		if((*raiz)->prox != NULL){
			destroiTab(&((*raiz)->prox));
		}

		if((*raiz)->isVar == FUNC){
			destroiParams((*raiz)->params);
			if((*raiz)->tabContexto != NULL){
				destroiTab((*raiz)->tabContexto);
			}
		}
		free((*raiz)->nome);
		(*raiz)->nome = NULL;
		free((*raiz)->valor);
		(*raiz)->valor = NULL;
		free(*raiz);
		(*raiz) = NULL;
	}
}
