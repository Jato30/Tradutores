
int main(){
	print("Hello World!\n");
	int i;
	point um;
	um.x = 1;
	um.y = 1;

	/* Inicia os pontos
	Cada ponto com coord diferentes
	:) */
	point dois, tres, quatro;
	dois.x = 1;
	dois.y = 2;
	tres.x = 2;
	tres.y = 2;
	quatro.x = 2;// comentario\n
	quatro.y = 1;
	//cria shape
	shape ret = {um, dois, tres, quatro};

	print("O perimetro da forma criada eh: %.3f\n", Perimetro(ret));

	return 0;
}