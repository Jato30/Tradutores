
int main(){
	int i;
	shape um_poligono_com_seis_lados_diferentes; // cria uma poligono um_poligono_com_seis_lados_diferentes
	constroi(&um_poligono_com_seis_lados_diferentes, 6); // aloca 6 pontos (tera 6 lados)
	/*
	* Define posicoes para cada ponto
	* e atribui a um_poligono_com_seis_lados_diferentes
	*/
	for(i = 1; i < 4; i = i+1){
		point a, z;
		a.x = i;
		a.y = i*i - a.x;
		z.y = 2 - i;
		z.x = 2 - (z.y - i*i);
		um_poligono_com_seis_lados_diferentes.vertice[i-1] = a;
		um_poligono_com_seis_lados_diferentes.vertice[5-(i-1)] = z;
	}

	return 0;
}
