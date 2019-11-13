#ifndef __TABSIMBOLO_H__
#define __TABSIMBOLO_H__

#define VAR 100000
#define FUNC 100001
#define KEYWORD 100007
#define OTHER -100000

typedef enum TYPE{
	Inteiro = 10000,
	Decimal,
	Ponto,
	Forma,
	Literal,
	other
} TYPE;

typedef struct Parametro{
	TYPE tipo;
	char* nome;
	int qtd; // quantidade de params
	int isEnd; // Se nao eh &endereco, 0
	struct Parametro *prox;
	
} Parametro;

struct Contexto;

typedef struct Simbolo{
	char* valor; // valor da variavel
	char* nome; // nome da variavel
	int qtd; // Quantidade de vezes que aparece
	int chave; // Numero do no, valor unico.
	int isVar; // flag que determina se variavel ou funcao
	TYPE tipo; // para definir os tipos basicos (se funcao, tipo do retorno)
	int qtdParams;
	Parametro *params; // para ser usado somente se for funcao
	struct Simbolo *prox;
	struct Contexto *meu;
	struct Contexto *interno;
} Simbolo;

typedef Simbolo* TabSimbolos;

typedef struct Contexto{
	Simbolo* criador;
	Simbolo* primeiro;
} Contexto;

void criaTab();
int buscaAquiNome(char* nome);
int buscaAquiVal(char* valor);
Simbolo* buscaTabNome(char* nome);
Simbolo* buscaTabVal(char* valor);
int checa_warn(char* valor, int lin, int col);
Simbolo* insere(char* nome, char* valor, int isVar, TYPE tipo, int qtdParams, Parametro* params);
void printAqui(Contexto* contexto);
void printTab();
void destroiParams(Parametro* parametro);
void destroiAqui(Contexto* contexto);
void destroiTab();


#endif // __TABSIMBOLO_H__
