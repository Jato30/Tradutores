
%{
	#include <stdio.h>
	#include <stdlib.h>

	int yylex();

	typedef struct Expressao Expressao;
	Expressao* novaExpr(Expressao* esq, Expressao* dir, char op, int val);
	void printArvore(Expressao *raiz, int tabs);
	void destroiArvore(Expressao *raiz);
	void novaFolhaFloat(double val);
	void novaFolhaInt(int val);
	void novaFolhaText(char* val);
	
	void yyerror(char const *s);

	struct Expressao{
		Expressao *esquerda;
		Expressao *direita;
		char op;
		int valor;
	};

	Expressao* raiz;
%} 

%token IF
%token ELSE
%token FOR
%token RETURN
%token INT
%token FLOAT
%token POINT
%token SHAPE
%token LITERAL

%token INTEIRO
%token DECIMAL
%token ID

%token LT
%token GT
%token LE
%token GE
%token EQ
%token NE
%token NOT
%token AND
%token OR

%token ATR
%token PLUS_ATR
%token MINUS_ATR
%token TIMES_ATR
%token OVER_ATR

%token PLUS_OP
%token MINUS_OP
%token TIMES_OP
%token OVER_OP

%token INI_PARAM
%token FIM_PARAM
%token INI_INSTRUC
%token FIM_INSTRUC

%token FIM_EXPRESS
%token SEPARA_ARG
%token ACESSO_END


%union{
	int INTEIRO;
	double DECIMAL;
	char ID[33];
	char* LITERAL;
}


%type <num> DECIMAL


%start programa



%%


programa:
			lista_decl
			;

lista_decl:
			declaracao recursao1
			;

recursao1:
			/* %empty */
			| declaracao recursao1
			;


declaracao:
			decl_var
			| decl_func
			;

decl_var:
			tipo_especif ID FIM_EXPRESS
			;

decl_func:
			tipo_especif ID INI_PARAM params FIM_PARAM instruc_composta
			;

tipo_especif:
			INT
			| FLOAT
			| POINT
			| SHAPE
			;

params:
			/* %empty */
			| lista_param
			;


lista_param:
			param recursao2
			;

recursao2:
			/* %empty */
			| SEPARA_ARG param recursao2
			;


param:
			tipo_especif ID 
			;

instruc_composta:
			INI_INSTRUC decl_local lista_instruc FIM_INSTRUC
			;


decl_local:
			recursao3
			;

recursao3:
			/* %empty */
			| decl_var recursao3
			;


lista_instruc:
			recursao4
			;

recursao4:
			/* %empty */
			| instrucao recursao4
			;


instrucao:
			instruc_expr
			| instruc_composta
			| instruc_cond
			| instruc_iterac
			| instruc_return
			;

instruc_expr:
			expressao FIM_EXPRESS
			| FIM_EXPRESS
			;


instruc_cond:
			IF INI_PARAM expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC fatora1
			;

fatora1:
			/* %empty */
			| ELSE INI_INSTRUC instrucao FIM_INSTRUC
			;


instruc_iterac:
			FOR INI_PARAM expressao FIM_EXPRESS express_simp FIM_EXPRESS expressao FIM_PARAM INI_INSTRUC instrucao FIM_INSTRUC
			;

instruc_return:
			RETURN expressao FIM_EXPRESS
			;

expressao:
			var atrop expressao
			| express_simp
			;


var:
			ID
			;

express_simp:
			express_soma fatora2
			;

fatora2:
			/* %empty */
			| relop express_soma
			;


express_soma:
			termo recursao5
			;

recursao5:
			/* %empty */
			| addop termo recursao5
			;


termo:
			factor recursao6
			;

recursao6:
			/* %empty */
			| mulop factor recursao6
			;


factor:
			INI_PARAM expressao FIM_PARAM
			| endereco
			| var
			| chamada
			| num
			| LITERAL {
				novaFolhaText(yylval.LITERAL);
			}
			;

chamada:
			ID INI_PARAM arg FIM_PARAM
			;

arg:
			/* %empty */
			| lista_arg
			;


lista_arg:
			expressao recursao7
			;

recursao7:
			/* %empty */
			| SEPARA_ARG expressao recursao7
			;


atrop:
			ATR {
				novaFolhaText("=");
			}
			| PLUS_ATR {
				novaFolhaText("+=");
			}
			| MINUS_ATR {
				novaFolhaText("-=");
			}
			| TIMES_ATR {
				novaFolhaText("*=");
			}
			| OVER_ATR {
				novaFolhaText("/=");
			}
			;

relop:
			LT {
				novaFolhaText("<");
			}
			| GT {
				novaFolhaText(">");
			}
			| LE {
				novaFolhaText("<=");
			}
			| GE {
				novaFolhaText(">=");
			}
			| EQ {
				novaFolhaText("==");
			}
			| NE {
				novaFolhaText("!=");
			}
			| logop
			;

logop:
			NOT {
				novaFolhaText("!");
			}
			| AND {
				novaFolhaText("&&");
			}
			| OR {
				novaFolhaText("||");
			}
			;

addop:
			PLUS_OP {
				novaFolhaText("+");
			}
			| MINUS_OP {
				novaFolhaText("-");
			}
			;

mulop:
			TIMES_OP {
				novaFolhaText("*");
			}
			| OVER_OP {
				novaFolhaText("/");
			}
			;

num:
			INTEIRO {
				
				novaFolhaInt(yylval.INTEIRO);
			}
			| DECIMAL {
				
				novaFolhaFloat(yylval.DECIMAL);
			}
			;

endereco:
			ACESSO_END var
			;



%%


Expressao* novaExpr(Expressao* esq, Expressao* dir, char op, int val){
	Expressao *exp = (Expressao*) malloc(sizeof(Expressao));
	exp->esquerda = esq;
	exp->direita = dir;
	exp->op = op;
	exp->valor = val;
	return exp;
}

void printArvore(Expressao *raiz, int tabs){
	int i;
	for(i = 0; i < tabs; ++i){
		printf("  ");
	}
	if(raiz->op) {
		printf("%c{\n", raiz->op);
		printArvore(raiz->esquerda, tabs + 1);
		printArvore(raiz->direita, tabs + 1);
		for(i = 0; i < tabs; ++i){
			printf("  ");
		}
		printf("}\n");
	}
	else{
		printf("%d\n", raiz->valor);
	}
}

void destroiArvore(Expressao *raiz){
	if(raiz->esquerda){
		destroiArvore(raiz->esquerda);
	}
	if(raiz->direita){
		destroiArvore(raiz->direita);
	}
	free(raiz);
}

void novaFolhaFloat(double val){

}

void novaFolhaInt(int val){

}

void novaFolhaText(char* val){

}

void yyerror(char const *s){
	fprintf(stderr, "%s\n", s);
}

int main(void){
	yyparse();

	return 0;
}

