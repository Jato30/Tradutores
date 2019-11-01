#include "TabSimbolo.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void criaTab(TabSimbolos* raiz){
	(*raiz) = NULL;
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

void insere(TabSimbolos* raiz, char* valor, int lin, int col, int isVar, TYPE tipo, int qtdParams, Parametro* params){

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
		printf("CHAVE\t\tQUANTIDADE\t\tVALOR\t\t\tVAR/FUNC\t\tTIPO\t\tPARAMS\n");

		while(atual != NULL){
			printf("%d\t\t%d\t\t\t%s\t\t%s\t\t", atual->chave, atual->qtd, atual->valor, atual->isVar == VAR ? "VAR" : (atual->isVar == FUNC ? "FUNC" : "LITERAL"));
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
