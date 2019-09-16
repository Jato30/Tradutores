
int main(){
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
	if(tres.x <= quatro.y){
		um.x = 1;
		um.y = 2;
	}
	else{
		um.x = 1.5;
		um.y = 1;
	}
	tres.x = 2;
	tres.y = 2;// comentario\n
	//cria shape
	shape ret;
	constroi(&ret, um, dois, tres);

	print("O perimetro da forma criada eh: %.3f\n", Perimetro(ret));

	return 0;
}
