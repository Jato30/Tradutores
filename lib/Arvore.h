#ifndef __ARVORE_H__
#define __ARVORE_H__

/* Implementação de árvore binária */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Cada nó armazena três informações:
 * 1) Uma string para armazenar o token, ou variável, lida;
 * 2) Ponteiro para subárvore à direita (sad); e
 * 3) Ponteiro para subárvore à esquerda (sae).
*/
typedef struct ArvoreSint{
	char* val;
	struct ArvoreSint* sad;
	struct ArvoreSint* sae;
} ArvoreSint;

typedef ArvoreSint* Arvore;

/* Obs: A estrutura da árvore é representada por um ponteiro
 * para o nó raiz. Com esse ponteiro, temos acesso aos demais nós.
*/

/* Função que cria uma árvore */
void criaArvore(Arvore* raiz){
	/*
	 * Uma árvore é representada pelo endereço do nó raiz,
	 * essa função recebe um no e assume que eh uma nova raiz
	 * vazia a definindo como NULL.
	*/
	*raiz = NULL;
}

/* Função que verifica se uma árvore é vazia */
int ArvoreIsEmpty(Arvore* raiz){
	/* Retorna 0 caso a árvore não seja vazia e !=0 caso contrario */
	return *raiz == NULL;
}

/* Função que mostra a informação da árvore */
void showArvore(Arvore t){
	/* Essa função imprime os elementos de forma recursiva */

	printf("<"); /* notação para organizar na hora de mostrar os elementos */
	if(ArvoreIsEmpty(t) == 0){ /* se a árvore não for vazia... */
		/* Mostra os elementos em pré-ordem */
		printf("%s ", t->val); /* mostra a raiz */
		showArvore(t->sae); /* mostra a sae (subárvore à esquerda) */
		showArvore(t->sad); /* mostra a sad (subárvore à direita) */
	}
	printf(">"); /* notação para organizar na hora de mostrar os elementos */
}

/* Função que insere um dado na árvore */
void insertArvore(Arvore* raiz, char* valor){
	/* Essa função insere os elementos de forma recursiva */
	if(*raiz == NULL){
		*raiz = (Arvore) malloc(sizeof(ArvoreSint)); /* Aloca memória para a estrutura */
		(*raiz)->val = (char*) malloc(sizeof(char) * strlen(valor));
		(*raiz)->sae = NULL; /* Subárvore à esquerda é NULL */
		(*raiz)->sad = NULL; /* Subárvore à direita é NULL */
		strcpy((*raiz)->val, valor); /* Armazena a informação */
	}
	else {
		if(num < (*t)->num){ /* Se o número for menor então vai pra esquerda */
			/* Percorre pela subárvore à esquerda */
			insertArvore(&(*t)->sae, num);
		}
		if(num > (*t)->num){ /* Se o número for maior então vai pra direita */
			/* Percorre pela subárvore à direita */
			insertArvore(&(*t)->sad, num);
		}
	}
}

/* Função que verifica se um elemento pertence ou não à árvore */
int isInArvore(Arvore t, int num) {

if(ArvoreIsEmpty(t)) { /* Se a árvore estiver vazia, então retorna 0 */
return 0;
}

/* O operador lógico || interrompe a busca quando o elemento for encontrado */
return t->num==num || isInArvore(t->sae, num) || isInArvore(t->sad, num);
}

int main()
{
Arvore t = criaArvore(); /* cria uma árvore */

insertArvore(&t, 12); /* insere o elemento 12 na árvore */
insertArvore(&t, 15); /* insere o elemento 15 na árvore */
insertArvore(&t, 10); /* insere o elemento 10 na árvore */
insertArvore(&t, 13); /* insere o elemento 13 na árvore */

showArvore(t); /* Mostra os elementos da árvore em pré-ordem */

if(ArvoreIsEmpty(t)) /* Verifica se a árvore está vazia */
{
printf("\n\nArvore vazia!!\n");
} else {
printf("\n\nArvore NAO vazia!!\n");
}

if(isInArvore(t, 15)) { /* Verifica se o número 15 pertence a árvore */
printf("\nO numero 15 pertence a arvore!\n");
} else {
printf("\nO numero 15 NAO pertence a arvore!\n");
}

if(isInArvore(t, 22)) { /* Verifica se o número 22 pertence a árvore */
printf("\nO numero 22 pertence a arvore!\n\n");
} else {
printf("\nO numero 22 NAO pertence a arvore!\n\n");
}

free(t); /* Libera a memória alocada pela estrutura árvore */

return 0;
}

#endif // __ARVORE_H__