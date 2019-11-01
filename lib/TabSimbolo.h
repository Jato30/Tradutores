#ifndef __TABSIMBOLO_H__
#define __TABSIMBOLO_H__

#define VAR 100000
#define FUNC 100001

typedef enum {
	Inteiro,
	Decimal,
	Ponto,
	Forma,
	Literal
} TYPE;

typedef struct Parametro{
	TYPE tipo;
	char* nome;
	int isEnd; // Se eh &endereco
	struct Parametro *prox;
	
} Parametro;

typedef struct Simbolo{
	char* valor;
	int qtd; // Quantidade de vezes que aparece
	int chave; // Numero do no, valor unico.
	int isVar; // flag que determina se variavel ou funcao
	TYPE tipo; // para definir os tipos basicos (se funcao, tipo do retorno)
	int qtdParams;
	Parametro *params; // para ser usado somente se for funcao
	struct Simbolo *prox;
} Simbolo;

typedef Simbolo* TabSimbolos;

void criaTab(TabSimbolos* raiz);
int buscaTab(TabSimbolos* raiz, char* valor);
int checa_warn(char* valor, int lin, int col);
void insere(TabSimbolos* raiz, char* valor, int lin, int col, int isVar, TYPE tipo, int qtdParams, Parametro* params);
void printTab(TabSimbolos* raiz);
void destroiTab(TabSimbolos* raiz);


#endif // __TABSIMBOLO_H__
