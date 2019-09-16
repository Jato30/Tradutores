#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * Estrutura da entrada da tabela Hash
*/
typedef struct entrada_hash{
	int chave;
	char *val;
	struct entrada_hash *prox;
} entrada_hash;

/**
 * Estrutura da tabela Hash
*/
typedef struct tabela_hash {
	int tam;
	int qtd_entradas;
	entrada_hash **entradas;
} Hash;

Hash *InicializaHash();

int FuncaoHash(Hash *tabela, int chave);
int InsereHash(Hash *tabela, int chave, char *val);
int RemoveHash(Hash *tabela, int chave);
int DestroiHash(Hash *tabela);



/**
 * Inicializa tabela hash
 * @return Ponteiro para a tabela hash ou NULL se falhar
*/
Hash *InicializaHash(){
	int tam = 1;
	//printf("Inicializando tabela hash com tamanho: %d\n", tam);
	
	if(tam <= 0){
		return NULL;
	}

	// aloca tabela
	Hash *tabela = malloc(sizeof(Hash));
	if(tabela == NULL){
		return NULL;
	}

	// aloca lista de entradas na tabela
	tabela->entradas = malloc(sizeof(entrada_hash*) * tam);
	if(tabela->entradas == NULL){
		return NULL;
	}

	// inicializa todas as entradas
	for(int i = 0; i < tam; i ++){
		tabela->entradas[i] = NULL;
	}

	tabela->tam = tam;
	tabela->qtd_entradas = 0;

	return tabela;
}


/**
 * Funcao Hash para calcular o indice na tabela
 */
int FuncaoHash(Hash *tabela, int chave){
	return chave % tabela->tam;
}


/**
 * Insere a chave e o valor na tabela
 *
 * @return indice da entrada que esta sendo inserida, -1 em caso de erro
 */
int InsereHash(Hash *tabela, int chave, char *val){
	if(tabela == NULL){
		return -1;
	}

	int i = hash(tabela, chave);
	entrada_hash *entrada = tabela->entradas[i];

	while(entrada){
		if(entrada->chave == chave){
			// entrada com a mesma chave quer dizer que o valor ja existe
			free(entrada->val);
			entrada->val = malloc(strlen(val) * sizeof(char));

			if(entrada->val == NULL){
				return -1;
			}
			strcpy(entrada->val, val);
			return i;
		}
		entrada = entrada->prox;
	}

	// aloca entrada
	entrada_hash *nova_entrada = malloc(sizeof(entrada_hash));
	if(nova_entrada == NULL){
		return -1;
	}

	// define os valores da entrada
	nova_entrada->chave = chave;
	nova_entrada->val = malloc(strlen(val) * sizeof(char));

	if(entrada->val == NULL){
		return -1;
	}
	strcpy(entrada->val, val);
	entrada->prox = tabela->entradas[i];

	// insere entrada no inicio da linked list
	tabela->entradas[i] = entrada;
	return i;
}


/**
 * Remove entrada pela chave da tabela
 *
 * @return indice da entrada que sera removida, -1 se falhar
 */
int RemoveHash(Hash *tabela, int chave){
	if(tabela == NULL){
		return -1;
	}

	int i = hash(tabela, chave);
	entrada_hash *entrada = tabela->entradas[i];

	// encontra a entrada na linked list
	while(entrada){
		if(entrada->chave == chave){
			break;
		}
		entrada = entrada->prox;
	}

	// atualiza tabela
	tabela->entradas[i] = entrada->prox;

	free(entrada->val);
	free(entrada);
	return i;
}


/**
 * Destroi e desaloca tabela
 *
 * @return 0 se bem sucedido, -1 se nao
 */
int DestroiHash(Hash *tabela){
	//printf("destroying hash tabela with tam: %d\n", tabela->tam);

	if(tabela == NULL){
		return -1;
	}

	for(int i = 0; i < tabela->tam; i++){
		entrada_hash *entrada = tabela->entradas[i];

		while(entrada){
			entrada_hash *temp = entrada;
			
			free(temp->val);
			free(temp);

			entrada = entrada->prox;
		}
	}
	
	return 0;
}
