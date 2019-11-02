#include "TabSimbolo.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void criaTab(TabSimbolos* raiz){
	(*raiz) = NULL;

	insere(raiz, "int", KEYWORD, Inteiro, 0, NULL);
	insere(raiz, "float", KEYWORD, Decimal, 0, NULL);
	insere(raiz, "point", KEYWORD, Ponto, 0, NULL);
	insere(raiz, "shape", KEYWORD, Forma, 0, NULL);

	insere(raiz, "return", OTHER, other, 0, NULL);
	insere(raiz, "if", OTHER, other, 0, NULL);
	insere(raiz, "else", OTHER, other, 0, NULL);
	insere(raiz, "for", OTHER, other, 0, NULL);

	Parametro printInt;
	printInt.nome = (char*) malloc(sizeof(char) * 6);
	printInt.nome = "texto";
	printInt.qtd = 2;
	printInt.tipo = Literal;
	printInt.isEnd = 0;
	
	printInt.prox = (Parametro*) malloc(sizeof(Parametro));
	printInt.prox[0].nome = (char*) malloc(sizeof(char) * 6);
	printInt.prox[0].nome = "valor";
	printInt.prox[0].qtd = 2;
	printInt.prox[0].tipo = Inteiro;
	printInt.prox[0].isEnd = 0;

	insere(raiz, "printInt", FUNC, Inteiro, 2, &printInt);


	Parametro printFloat;
	printFloat.nome = (char*) malloc(sizeof(char) * 6);
	printFloat.nome = "texto";
	printFloat.qtd = 2;
	printFloat.tipo = Literal;
	printFloat.isEnd = 0;
	
	printFloat.prox = (Parametro*) malloc(sizeof(Parametro));
	printFloat.prox[0].nome = (char*) malloc(sizeof(char) * 6);
	printFloat.prox[0].nome = "valor";
	printFloat.prox[0].qtd = 2;
	printFloat.prox[0].tipo = Decimal;
	printFloat.prox[0].isEnd = 0;

	insere(raiz, "printFloat", FUNC, Inteiro, 2, &printFloat);


	Parametro printPoint;
	printPoint.nome = (char*) malloc(sizeof(char) * 6);
	printPoint.nome = "texto";
	printPoint.qtd = 2;
	printPoint.tipo = Literal;
	printPoint.isEnd = 0;
	
	printPoint.prox = (Parametro*) malloc(sizeof(Parametro));
	printPoint.prox[0].nome = (char*) malloc(sizeof(char) * 6);
	printPoint.prox[0].nome = "valor";
	printPoint.prox[0].qtd = 2;
	printPoint.prox[0].tipo = Ponto;
	printPoint.prox[0].isEnd = 0;

	insere(raiz, "printPoint", FUNC, Inteiro, 2, &printPoint);


	Parametro printShape;
	printShape.nome = (char*) malloc(sizeof(char) * 6);
	printShape.nome = "texto";
	printShape.qtd = 2;
	printShape.tipo = Literal;
	printShape.isEnd = 0;
	
	printShape.prox = (Parametro*) malloc(sizeof(Parametro));
	printShape.prox[0].nome = (char*) malloc(sizeof(char) * 6);
	printShape.prox[0].nome = "valor";
	printShape.prox[0].qtd = 2;
	printShape.prox[0].tipo = Forma;
	printShape.prox[0].isEnd = 0;

	insere(raiz, "printShape", FUNC, Inteiro, 2, &printShape);


	Parametro scanInt;
	scanInt.nome = (char*) malloc(sizeof(char) * 4);
	scanInt.nome = "var";
	scanInt.qtd = 2;
	scanInt.tipo = Inteiro;
	scanInt.isEnd = 1;
	
	scanInt.prox = (Parametro*) malloc(sizeof(Parametro));
	scanInt.prox[0].nome = (char*) malloc(sizeof(char) * 6);
	scanInt.prox[0].nome = "valor";
	scanInt.prox[0].qtd = 2;
	scanInt.prox[0].tipo = Inteiro;
	scanInt.prox[0].isEnd = 0;

	insere(raiz, "scanInt", FUNC, Inteiro, 2, &scanInt);


	Parametro scanFloat;
	scanFloat.nome = (char*) malloc(sizeof(char) * 4);
	scanFloat.nome = "var";
	scanFloat.qtd = 2;
	scanFloat.tipo = Decimal;
	scanFloat.isEnd = 1;
	
	scanFloat.prox = (Parametro*) malloc(sizeof(Parametro));
	scanFloat.prox[0].nome = (char*) malloc(sizeof(char) * 6);
	scanFloat.prox[0].nome = "valor";
	scanFloat.prox[0].qtd = 2;
	scanFloat.prox[0].tipo = Decimal;
	scanFloat.prox[0].isEnd = 0;

	insere(raiz, "scanFloat", FUNC, Inteiro, 2, &scanFloat);


	Parametro constroiPoint;
	constroiPoint.nome = (char*) malloc(sizeof(char) * 4);
	constroiPoint.nome = "var";
	constroiPoint.qtd = 3;
	constroiPoint.tipo = Ponto;
	constroiPoint.isEnd = 1;
	
	constroiPoint.prox = (Parametro*) malloc(sizeof(Parametro));
	constroiPoint.prox[0].nome = (char*) malloc(sizeof(char) * 6);
	constroiPoint.prox[0].nome = "val_x";
	constroiPoint.prox[0].qtd = 3;
	constroiPoint.prox[0].tipo = Decimal;
	constroiPoint.prox[0].isEnd = 0;

	constroiPoint.prox[0].prox = (Parametro*) malloc(sizeof(Parametro));
	constroiPoint.prox[1].nome = (char*) malloc(sizeof(char) * 6);
	constroiPoint.prox[1].nome = "val_y";
	constroiPoint.prox[1].qtd = 3;
	constroiPoint.prox[1].tipo = Decimal;
	constroiPoint.prox[1].isEnd = 0;

	insere(raiz, "constroiPoint", FUNC, Inteiro, 3, &constroiPoint);


	Parametro constroiShape;
	constroiShape.nome = (char*) malloc(sizeof(char) * 4);
	constroiShape.nome = "var";
	constroiShape.qtd = 2;
	constroiShape.tipo = Forma;
	constroiShape.isEnd = 1;
	
	constroiShape.prox = (Parametro*) malloc(sizeof(Parametro));
	constroiShape.prox[0].nome = (char*) malloc(sizeof(char) * 6);
	constroiShape.prox[0].nome = "valor";
	constroiShape.prox[0].qtd = 2;
	constroiShape.prox[0].tipo = Ponto;
	constroiShape.prox[0].isEnd = 0;

	insere(raiz, "constroiShape", FUNC, Inteiro, 2, &constroiShape);


	Parametro Perimetro;
	Perimetro.nome = (char*) malloc(sizeof(char) * 4);
	Perimetro.nome = "var";
	Perimetro.qtd = 1;
	Perimetro.tipo = Forma;
	Perimetro.isEnd = 0;

	insere(raiz, "Perimetro", FUNC, Decimal, 0, &Perimetro);


	Parametro IsIn;
	IsIn.nome = (char*) malloc(sizeof(char) * 6);
	IsIn.nome = "forma";
	IsIn.qtd = 2;
	IsIn.tipo = Forma;
	IsIn.isEnd = 0;
	
	IsIn.prox = (Parametro*) malloc(sizeof(Parametro));
	IsIn.prox[0].nome = (char*) malloc(sizeof(char) * 6);
	IsIn.prox[0].nome = "ponto";
	IsIn.prox[0].qtd = 2;
	IsIn.prox[0].tipo = Ponto;
	IsIn.prox[0].isEnd = 0;

	insere(raiz, "IsIn", FUNC, Inteiro, 2, &IsIn);


	Parametro IsCollided;
	IsCollided.nome = (char*) malloc(sizeof(char) * 7);
	IsCollided.nome = "forma1";
	IsCollided.qtd = 2;
	IsCollided.tipo = Forma;
	IsCollided.isEnd = 0;
	
	IsCollided.prox = (Parametro*) malloc(sizeof(Parametro));
	IsCollided.prox[0].nome = (char*) malloc(sizeof(char) * 7);
	IsCollided.prox[0].nome = "forma2";
	IsCollided.prox[0].qtd = 2;
	IsCollided.prox[0].tipo = Forma;
	IsCollided.prox[0].isEnd = 0;

	insere(raiz, "IsCollided", FUNC, Inteiro, 2, &IsCollided);
}

// RETORNO: retorna a chave do elemento encontrado, -1 se nao existir
int buscaTab(TabSimbolos* raiz, char* valor){
	if((*raiz) == NULL){
		// printf("\nTabela vazia\n");
		return -1;
	}
	else{
		TabSimbolos atual;
		atual = (*raiz);
		while(atual != NULL){
			if(strcmp(atual->valor, valor) == 0){
				// printf("\tJa existe %s na tabela de simbolos\n", valor);
				return atual->chave;
			}
			atual = atual->prox;
		}

		// printf("Nenhuma ocorrencia repetida.\n");
		free(atual);
		atual = NULL;
		return -1;
	}
}

void insere(TabSimbolos* raiz, char* valor, int isVar, TYPE tipo, int qtdParams, Parametro* params){

	int busca = buscaTab(raiz, valor);
	if(busca == -1){
		if(*raiz == NULL){  //Lista vazia
			*raiz = (TabSimbolos) malloc(sizeof(Simbolo));
			(*raiz)->valor = (char*) malloc(sizeof(char) * strlen(valor) + 1);
			strcpy((*raiz)->valor, valor);
			(*raiz)->chave = 1;
			(*raiz)->qtd = 1;
			(*raiz)->isVar = isVar;
			(*raiz)->tipo = tipo;
			(*raiz)->prox = NULL;
			if(isVar == FUNC){
				(*raiz)->qtdParams = qtdParams;
				(*raiz)->params = params;
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
			ultimoLista->prox->valor = (char*) malloc(sizeof(char) * strlen(valor) + 1);
			strcpy(ultimoLista->prox->valor, valor);
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
		printf("CHAVE\tQUANTIDADE\tVALOR\t\t\tVAR/FUNC\tTIPO\t\tPARAMS\n");

		while(atual != NULL){
			printf("%d\t%d\t\t%s\t\t\t%s\t\t", atual->chave, atual->qtd, atual->valor, atual->isVar == VAR ? "VAR" : (atual->isVar == FUNC ? "FUNC" : "LITERAL"));
			switch(atual->tipo){
				case Inteiro:
					printf("int\t\t");
				break;

				case Decimal:
					printf("float\t\t");
				break;

				case Ponto:
					printf("Point\t\t");
				break;

				case Forma:
					printf("Shape\t\t");
				break;
			
				default:
					printf("Literal\t\t");
					break;
			}

			if(atual->isVar == FUNC){
				int i;
				for(i = 0; i < atual->qtdParams; i++){
					switch(atual->params[i].tipo){
						case Inteiro:
							printf("int ");
						break;

						case Decimal:
							printf("float ");
						break;

						case Ponto:
							printf("Point ");
						break;

						case Forma:
							printf("Shape ");
						break;
					
						default:
							printf("Literal ");
							break;
					}

					printf("%s%s%s ", atual->params[i].isEnd == 0 ? "" : "&", atual->params[i].nome, (i+1) < atual->qtdParams ? "," : "");
				}
			}
			printf("\n");
			atual = atual->prox;
		}
	}

}

void destroiTab(TabSimbolos* raiz){
	if((*raiz) != NULL){
		if((*raiz)->prox != NULL){
			destroiTab(&((*raiz)->prox));
		}

		free((*raiz)->valor);
		(*raiz)->valor = NULL;
		free(*raiz);
		(*raiz) = NULL;
	}
}
