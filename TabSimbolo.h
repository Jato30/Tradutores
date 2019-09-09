#infndef __TABSIMBOLO_H__
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
void insere(TabSimbolos* raiz, char* valor);
void printTab(TabSimbolos raiz);
int buscaTab(TabSimbolos raiz, char* valor);

void cria(TabSimbolos* raiz){
  *raiz = NULL;
  return 0;
}

int buscaTab(TabSimbolos raiz, char* valor){
   if(raiz == NULL){
      printf("\nTabela vazia");
      return 0;
   }
    else{
        TabSimbolos atual;
       atual = *raiz;
       while(strcmp(atual->valor, valor) != 0){
           atual = atual->prox;
           if(atual == NULL){
             printf("Nenhuma ocorrencia repetida.\n");
             return 0;
            }
       }
       // aqui se pode incrementar um campo que diz quantas ocorrencias
       atual->qtd++;
       return 1;
    }
}

void insere(TabSimbolos* raiz, char* valor){

    if(buscaTab(*raiz, valor) == 1){
        printf("valor ja existente na tabela de simbolos.\n");
    }
    else{
    
        Simbolo* novo; 
        Simbolo* atual;
        int aux_chave = 0;

        novo = (Simbolo*) malloc(sizeof(Simbolo));
        if(novo == NULL){
            printf("Falta Memoria\n");
        }
        strcpy(novo->valor, valor);
        novo->qtd = 0;
        novo->prox = NULL;

        if(*raiz == NULL){  //Lista vazia
            novo->chave = 0;
            *raiz = novo;
        }
        else{
            atual = *raiz;   /*@ Primeiro elemento*/

            while(atual->prox != NULL){
                aux_chave++;
                atual = atual->prox;
            }
            atual->prox = novo;
            novo->chave = aux_chave + 1;
        }
    }
}

void printTab(TabSimbolos raiz){
    if(raiz == NULL){
       printf("\nTabela vazia");
    }
    else{
        TabSimbolos atual;
        atual = *raiz;
        printf("\n\nTABELA DE SIMBOLOS ########\n\n");
        printf("Chave\t\tQuantidade\t\tValor\n");
        while(atual != NULL){
            printf("%d\t\t\t%d\t\t%s\n", atual->chave, atual->qtd, atual->valor);
            atual = atual->prox;
                 
        }
    }
}


#endif // __TABSIMBOLO_H__
