#include <stdio.h>
#include <stdlib.h>
#include "Erro.h"

#define FALSE 0
#define TRUE 1

/*
	r	Abre um arquivo texto para leitura. O arquivo deve existir antes de ser aberto.
	w	Abre um arquivo texto para escrita. Se o arquivo nao existir, ele sera criado. Se ja existir, o conteudo anterior sera destruido.
	a	Abre um arquivo texto para escrita. Os dados serao adicionados no fim do arquivo se ele ja existir. Um novo arquivo sera criado no caso do arquivo nao existir.
	r+	Abre um arquivo texto para leitura e escrita. O arquivo deve existir e pode ser modificado.
	w+	Cria um arquivo texto para leitura e escrita. O conteudo anterior sera destruido se o arquivo ja existir. Se nao existir, sera criado.
	a+	Abre um arquivo texto para leitura e escrita. Os dados serao adicionados no fim do arquivo se ele ja existir. Um novo arquivo sera criado no caso do arquivo nao existir.
	*b	arquivos binarios
*/
#define LEITURA "r"
#define NOVA_ESCR "w"
#define CONT_ESCR "a"

#define LER_ESCR "r+" // Arquivo deve existir, mas sobrescreve.
#define NOVO_LER_ESCR "w+" // Arquivo não precisa existir, mas sobrescreve.
#define CONT_LER_ESCR "a+" // Arquivo não precisa existir. Escrita é acrescida ao final.

#define BLEITURA "rb"
#define BNOVA_ESCR "wb"
#define BCONT_ESCR "ab"

// int AbrirArquivo(const char* caminho, const char* tipo){
// 	FILE* arq = fopen(caminho, tipo);

// 	if(!arq){
// 		Erro("Erro na abertura do arquivo. Fim de programa.");
// 		return FALSE;
// 	}
// 	return TRUE;
// }

int main(int argc, char* argv[]){
	if(argc < 2){
		Erro("oi");
		return FALSE;
	}


	return TRUE;
}