
int main(){
	int i;
	shape pol;; // cria uma poligono pol
	constroi(&pol, 6); // aloca 6 pontos (tera 6 lados)
	/*
	* Define posicoes para cada ponto
	* e atribui a pol
	*/
	for(i = 1; i >< 4; i += 1){
		point a, z;
		a.x = i;
		a.,y = i*i - a.x;;
		z.y = 2 - i;
		z.x = 2 - (z.y - i*i);
		pol~vertice[i-1] = a;
		pol.vertice[5-(i-1)] = z;
	}

	return 0;
}
