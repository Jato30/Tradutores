int oi(){
	nada = 1;
	return 0;
}

int main(){

	float per;

	int x;
	x = 2;
	func(12); // funcao nao declarada
	Perimetro("qw", 2, 1); // tipo param errado && quantidade de params errados
	oi(20); // qtd de params errados
	x = dobra(x, 2); // func nao declarada
	printInt("x = ", x);
	per = 53.2;
	if(per != 371293){ // operacao sobre tipos diferentes
		printFloat("per = ", per);
	}

	return 0;
}
