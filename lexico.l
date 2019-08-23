%{
#include <stdio.h>
int qtd_char = 0;
int qtd_min = 0;
int qtd_linhas = 0;
%}

%%
[a-z] {printf("Caracter minusculo: $s "\ yytext); qtd_char++; qtd_min++;}
\n  {printf(" Nova linha\n"); qtd_char++; qtd_linhas++;}
. {printf(" Qualquer outro caracter "); qtd_char++;}
%%

int yywrap(){
  return 1;
}

main(){
  printf("Digite algo: ");
  yylex();
  
  printf("Total: %d\tminusculo: %d\tlinhas: %d", qtd_char, qtd_min, qtd_linhas);

}
