
int main(){

	point p1;
	point p2;
	point p3;
	shape forma;
	constroi(&forma, &p1, &p2, &p3);
	
	forma.pt[0].x = 1;
	forma.pt[0].y = 1;
	forma.pt[1].x = 2.5;
	forma.pt[1].y = 2;
	forma.pt[2].x = 1;
	forma.pt[2].y = 2;

	shape forma2;
	constroi(&forma2, 4);

	forma2.pt[0].x = 2.49;
	forma2.pt[0].y = 1;
	forma2.pt[1].x = 2.49;
	forma2.pt[1].y = 3.5;
	forma2.pt[2].x = 4.2;
	forma2.pt[2].y = 3.5;
	forma2.pt[3].x = 4.2;
	forma2.pt[3].y = 1;

	int i;
	int dentro = 0;
	for(i = 0; i < forma2.qtd; i++){
		if(IsIn(forma, forma2.pt[i])){
			print("Ponto esta dentro");
			dentro = 1;
			i = forma2.qtd;
			print("Ponto esta dentro, saindo do loop...");
		}
		else{
			print("Ponto esta fora");
		}
	}

	return 0;
}
