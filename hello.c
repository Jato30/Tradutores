#include <stdio.h>

int main(){
	printf("Hello World!\n");
	int i;
	point um = {1, 1};
	point dois = {1, 2};
	point tres = {2, 2};
	point quatro = {2, 1};
	shape ret = {um, dois, tres, quatro};

	printf("O perimetro da forma criada eh: %.3f\n", Perimetro(ret));

	return 0;
}