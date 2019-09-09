#include <stdio.h>
#include "hash.h"

int main(int argc, char **argv) {

	if (argc != 2) {
		printf("Usage: ./hash_table <size of table>\n");
		return -1;
	}

	int tam = (int) strtol(argv[1], (char**) NULL, 10);
	
	Hash *tabela = InicializaHash(tam);

	hash_destroy(tabela);

	return 0;
}