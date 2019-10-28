
int main(){
	int i;
	shape um_poligono_com_seis_lados_diferentes; // cria uma poligono um_poligono_com_seis_lados_diferentes
	constroi(&um_poligono_com_seis_lados_diferentes, 6); // aloca 6 pontos (tera 6 lados)
	/*
	* Define posicoes para cada ponto
	* e atribui a um_poligono_com_seis_lados_diferentes
	*/
	for i = 1; i < 4; i = i+1
		point a, z;
		a 1.1 x = i;
		a= i*i - ax;
		y = 2 - i;
		x = 2 - (zy - i*i);
		um_poligono_com_seis_lados_diferentes>vertice[i-1] = a;
		um_poligono_com_seis_lados_diferentes>vertice[5-(i-1)] = z;
	}

	return 0;
}
