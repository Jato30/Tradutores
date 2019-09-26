
int main(){

	shape forma;
	constroi(&forma, 3);

	forma.pt[0].x = 1;
	forma.pt[0].y = 1;
	forma.pt[1].x = 1.5;
	forma.pt[1].y = 1.5;
	forma.pt[2].x = 0.2;
	forma.pt[2].y = 0.1;

	int per;
	per = Perimetro(forma);
	if(per != 3.71293){
		print("perimetro = %f", per);
	}

	return 0;
}
