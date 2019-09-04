#ifndef __HASH_H__
#define __HASH_H__


#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#define tam 677
#define FALSE 0
#define TRUE !(FALSE)



/*	Prototipos das funcaoes */
typedef struct chave{
	char* val;
	int qtd;
	struct chave *prox;
} Registro;

typedef Registro* Hash[tam];

int FuncaoHash(int seed);
void InicializaHash(Hash tab);
void ImprimeColisao(Hash tab, int pos);
void BuscaHashPos(Hash tab, int pos);
int BuscaHashChave(Hash tab, char* chave);
void InsereHashChave(Hash tab, char* chave);
void ImprimeHash(Hash tab);
void RemoveHashPos(Hash tab, int pos);
void RemoveHashChave(Hash tab, int pos);

void CriaArquivo(FILE* arquivo);
void ReescreveArquivo(FILE* arquivo);
void EscreveArquivo(FILE* arquivo, int n);
int CarregaArquivo(FILE* arquivo, Hash tab);



/*
 *	FuncaoHash
 *
 * Recebe um inteiro n e retorna o
 * resto da divisao do valor dessa variavel pelo tamanho da tabela
*/
int FuncaoHash(int seed){
	int pos = ((2 * seed + 3) * seed + 4) * seed + 5;
	return (pos % tam);
}

/*
 *	InicializaHash
 *
 * Recebe uma tabela Hash e define NULL em todas as posicoes
*/
void InicializaHash(Hash tab){
	int i;
	for(i = 0; i < tam; i++){
		tab[i] = NULL;
	}
}

/*
 *	ImprimeColisao
 *
 * Recebe uma tabela Hash e um inteiro pos
 * Imprime todos os elementos colididos na mesma posicao
*/
void ImprimeColisao(Hash tab, int pos){
	Registro* aux = tab[pos];
	if(aux != NULL){
		printf("\"%s\"", aux->val);

		while(aux->prox != NULL){
			printf(" -> \"%s\"", aux->prox->val);
			aux = aux->prox;
		}
	}
	else{
		printf("Esta posicao esta vazia!\n");
		return;
	}

}

/*
 *	BuscaHashPos
 *
 * Recebe uma tabela Hash tab e um inteiro pos
 * Retorna a(s) entrada(s) da tabela tab na posicao pos
*/
void BuscaHashPos(Hash tab, int pos){
	if(0 > pos || pos > tam){
		printf("Posicao nao encontrada!\n");
		return;
	}
	else{
		ImprimeColisao(tab, pos);
	}
}

/*
 *	BuscaHashChave
 *
 * Recebe uma tabela Hash tab e um inteiro pos
 * Retorna a posicao da chave na tabela tab, -1 se nao encontrar.
*/
int BuscaHashChave(Hash tab, char* chave){
	int i, pos = -1;
	Registro* aux;

	for(i = 0; i < tam; i++){
		aux = tab[i];
		if(aux == NULL){
			continue;
		}
		else{
			do{
				if(strcmp(aux->val, chave) == 0){
					pos = i;
					free(aux);
					aux = NULL;
				}
				else{
					aux = aux->prox;
				}
			} while(aux == NULL);
		}
		if(pos != -1){
			break;
		}
	}

	return pos;
}

/*
 *	InsereHashChave
 * 
 * Recebe uma tabela Hash tab e uma string chave.
 * Insere chave na tabela tab na posicao dada por FuncaoHash,
 * tratando as colisoes com encadeamento direto.
*/
void InsereHashChave(Hash tab, char* chave){
	int i = 0, pos = BuscaHashChave(tab, chave);

	if(pos < 0){
		srand(time(NULL));
		pos = FuncaoHash((int) rand());

		Registro* aux = tab[pos];

		while(aux != NULL){
			aux = aux->prox;
		}
		if(aux == NULL){
			aux = (Registro*) malloc(sizeof(Registro));
			aux->qtd = 0;
			strcpy(aux->val, chave);
			aux->prox = tab[pos];
			tab[pos] = aux;
		}
	}
	else{
		printf("Chave ja existe na posicao %d\n", pos);
		tab[pos]->qtd++;
	}
}

/*
 *	ImprimeHash
 * Recebe uma tabela Hash tab
 * Imprime todos os elementos da tabela
*/
void ImprimeHash(Hash tab){
	int i = 0, cont = 0;
	for(i = 0; i < tam; i++){
		if(tab[i] != NULL){
			printf("\n \"%s\"(%d)", tab[i]->val, tab[i]->qtd);
			Registro* aux = tab[i]->prox;

			while(aux != NULL){
				printf(" -> \"%s\"(%d)", aux->val, aux->qtd);
				aux = aux->prox;
			}
		}
	}
}

/*
 *	RemoveHash
 *
 * Recebe uma tabela Hash tab e um inteiro pos
 * mostra o valor das chaves da posicao pos na tabela tab e o usuario escolhe qual deseja apagar
 * 
 * OBS: talvez nem precise de eliminacao, mas se precisar, vai ter que ser por chave, nao por posicao
*/
void RemoveHash(Hash tab, int pos){
	// int ex;
	// if(0 > pos || pos > tam){
	// 	printf("\nEsta posicao nao existe na tabela!");
	// }
	// else{
	// 	if(tab[pos] == NULL){
	// 		printf("Esta chave esta vazia!");
	// 	}
	// 	else{
	// 		printf("\n\n\n");
	// 		ImprimeColisao(tab,pos);
	// 		printf("\n\nQual registro deseja apagar =  ");
	// 		scanf("%d",&ex);

	// 		if(tab[pos]->val == ex){
	// 			if(tab[pos]->prox == NULL){
	// 				tab[pos] = NULL;
	// 				return;
	// 			}
	// 			if(tab[pos]->prox != NULL){
	// 				tab[pos]->val = tab[pos]->prox->val;
	// 				tab[pos]->prox = tab[pos]->prox->prox;
	// 				return;
	// 			} 
	// 		}
	// 		else{
	// 			if(tab[pos]->val != ex){    
	// 				if(tab[pos]->prox == NULL){
	// 					printf("\nRegistro nao encontrado!");
	// 					//getc();
	// 					return;
	// 				}
	// 				else{
	// 					Registro* ant = NULL;
	// 					Registro* aux = tab[pos]->prox;
	// 					while(aux->prox != NULL  && aux->val != ex){
	// 						ant = aux;
	// 						aux = aux->prox;
	// 					}
	// 					if(aux->val != ex){
	// 						printf("\nRegistro nao encontrado!\n");
	// 						return;
	// 					}
	// 					else{
	// 						if(ant == NULL){
	// 							tab[pos]->prox = aux->prox;
	// 						}
	// 						else{
	// 							ant->prox = aux->prox;
	// 						}
	// 						aux = NULL;
	// 						free(aux);
	// 					}
	// 				}
	// 			}
	// 		}
	// 	}
	// }
}

/*
 *	CriaArquivo
 *
 * Recebe um ponteiro para arquivo FILE
 * Abre o arquivo ./hash.txt para leitura. Se nao existir, cria e abre para escrita
*/
void CriaArquivo(FILE* arquivo){
	arquivo = fopen("hash.txt", "r");
	if(arquivo == NULL){
		arquivo = fopen("hash.txt", "w");
		fclose(arquivo);
	}
	else{
		return;
	}
}

/*
 *	ReescreveArquivo
 *
 * Recebe ponteiro para arquivo FILE
 * Limpa o conteudo do arquivo
*/
void ReescreveArquivo(FILE* arquivo){
	arquivo = fopen("hash.txt", "w");
	fclose(arquivo);
}

/*
 *	EscreveArquivo
 *
 * Recebe ponteiro para arquivo FILE e um inteiro n.
 * Escreve o novo registro n no arquivo
*/
void EscreveArquivo(FILE* arquivo, int n){
	arquivo = fopen("hash.txt", "a");
	fprintf(arquivo, "%3d\n", n);
	fclose(arquivo);
}

/*
 *	CarregaArquivo
 *
 * Recebe ponteiro para arquivo FILE e uma tabela Hash.
 * Insere na tabela Hash os elementos que estao no arquivo.
 * Retorna 0 para erro e != 0 para sucesso
*/
int CarregaArquivo(FILE* arquivo, Hash tab){
	int elemento;

	arquivo = fopen("hash.txt", "r");
	fseek(arquivo, 0, SEEK_END);

	if(ftell(arquivo) == 0){
		return FALSE;
	}
	fseek(arquivo,0,SEEK_SET);
	if(arquivo == NULL){
		return FALSE;
	}
	else{
		while(!feof(arquivo)){
			fscanf(arquivo, "%d", &elemento);
			// InsereHashChave(tab, elemento);
		}
		//system("cls");
	}

	fclose(arquivo);
	return TRUE;
}



#endif // __HASH_H__
