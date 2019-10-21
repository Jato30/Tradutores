
int main(){
	int i;
	point um;
	constroiPoint(&um, 1, 1);

	/* Inicia os pontos
	Cada ponto com coord diferentes
	:) */
	point dois, tres, quatro;
	constroiPoint(&dois, 1.0, 2.0);
	if(42 <= -59.3){
		constroiPoint(&um, 1.0, 2.0);
	}
	else{
		constroiPoint(&um, 1.5, 1.0);
	}
	constroiPoint(&tres, 2.0, 2.0);// comentario\n
	//cria shape
	shape ret;
	constroiShape(&forma, um);
	constroiShape(&forma, dois);
	constroiShape(&forma, tres);

	printFloat("O perimetro da forma criada eh: ", Perimetro(ret));

	return 0;
}
