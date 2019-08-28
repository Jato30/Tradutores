%option nounput yylineno

%{
	#include <stdio.h>
	#include <ctype.h>
%}

int	num_char = 0;
int	num_lin = 0;


%%

[a-z]		toupper(yytext);
.		printf("O que encontrei nao eh letra: %s\n", yytext);


%%

void main(){
	yylex();
	printf("# of lines = %d, # of chars = %d\n", num_lin, num_char);

}