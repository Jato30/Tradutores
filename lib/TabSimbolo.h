#ifndef __TABSIMBOLO_H__
#define __TABSIMBOLO_H__

#include <stdlib.h>
#include <string.h>

typedef struct Simbolo{
	char* valor;
	int qtd;
	int chave;
	struct Simbolo *prox;
} Simbolo;

typedef Simbolo* TabSimbolos;

void cria(TabSimbolos* raiz);
int buscaTab(TabSimbolos* raiz, char* valor);
int checa_warn(char* valor, int lin, int col);
void insere(TabSimbolos* raiz, char* valor, int lin, int col);
void printTab(TabSimbolos* raiz);
void destroiTab(TabSimbolos* raiz);

void cria(TabSimbolos* raiz){
	(*raiz) = NULL;
}

// RETORNO: retorna a chave do elemento repetido, -1 se nao houver repeticao
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

void insere(TabSimbolos* raiz, char* valor, int lin, int col){

	int busca = buscaTab(raiz, valor);
	if(busca == -1){
		if(*raiz == NULL){  //Lista vazia
			*raiz = (TabSimbolos) malloc(sizeof(Simbolo));
			(*raiz)->valor = (char*) malloc(sizeof(char) * strlen(valor));
			strcpy((*raiz)->valor, valor);
			(*raiz)->chave = 1;
			(*raiz)->qtd = 1;
			(*raiz)->prox = NULL;
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
			ultimoLista->prox->valor = (char*) malloc(sizeof(char) * strlen(valor));
			strcpy(ultimoLista->prox->valor, valor);
			ultimoLista->prox->chave = aux_chave;
			ultimoLista->prox->qtd = 1;
			ultimoLista->prox->prox = NULL;
		}

	}
	else{
		TabSimbolos atual;
		atual = *raiz;   /*@ Primeiro elemento*/

		while(atual->prox != NULL){
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
		printf("CHAVE\t\tQUANTIDADE\t\tVALOR\n");

		while(atual != NULL){
			printf("%d\t\t%d\t\t\t%s\n", atual->chave, atual->qtd, atual->valor);
			atual = atual->prox;
		}
	}

}

void destroiTab(TabSimbolos* raiz){
	if((*raiz)->prox != NULL){
		destroiTab(&((*raiz)->prox));
	}

	free((*raiz)->valor);
	(*raiz)->valor = NULL;
	free(*raiz);
	(*raiz) = NULL;
}


#endif // __TABSIMBOLO_H__
