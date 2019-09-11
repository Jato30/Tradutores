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
int checa_erro(char* valor, int lin, int col);
void insere(TabSimbolos* raiz, char* valor, int lin, int col);
void printTab(TabSimbolos* raiz);

void cria(TabSimbolos* raiz){
	*raiz = NULL;
}

// RETORNO: retorna a chave do elemento repetido, -1 se nao houver repeticao
int buscaTab(TabSimbolos* raiz, char* valor){
	if(*raiz == NULL){
		// printf("\nTabela vazia\n");
		return -1;
	}
	else{
		TabSimbolos atual;
		atual = *raiz;
		while(atual != NULL){
			if(strcmp(atual->valor, valor) == 0){
				// printf("\tJa existe %s na tabela de simbolos\n", valor);
				return atual->chave;
			}
			atual = atual->prox;
		}

		// printf("Nenhuma ocorrencia repetida.\n");
		return -1;
	}
}

// RETORNO: 0 nenhnum erro, 1 erro corrigido, 2 erro nao corrigido
int checa_erro(char* valor, int lin, int col){
	int erro = 0;

	// ERRO DE TAMANHO
	{
		int tam = (int) strlen(valor);
		if(tam > 33){
			erro = 1;
			printf("\t[WARNING]: Tamanho excede o maximo %d>33. valor sera truncado. Linha[%d:%d]\n", tam, lin+1, col);
			char aux_valor[33];
			int i = 0;
			for(i = 0; i < 33; i++){
				aux_valor[i] = valor[i];
			}
			valor[33] = '\0';
			valor = NULL;
			free(valor);
			valor = (char*) malloc(sizeof(char*) * 33);
			strcpy(valor, aux_valor);
		}
	}

	// ERRO DE IF
	{
		if(strcmp("fi", valor) == 0){
			printf("\t[WARNING]: em vez de %s, nao quis dizer if? Linha[%d:%d]\n", valor, lin+1, col);
		}
	}

	return 0;
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
		printf("Chave\t\tQuantidade\t\tValor\n");

		while(atual != NULL){
			printf("%d\t\t%d\t\t\t%s\n", atual->chave, atual->qtd, atual->valor);
			atual = atual->prox;
		}
	}

}


#endif // __TABSIMBOLO_H__
