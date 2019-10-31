
int main(){

	shape forma;
	int per;
	point pt1;
	point pt2;
	point pt3;

	constroiPoint(&pt1, 1.0, 1);
	constroiPoint(&pt2, 1.5, 1.5);
	constroiPoint(&pt3, 0.2, 0.1);
	constroiShape(&forma, pt1);
	constroiShape(&forma, pt2);
	constroiShape(&forma, pt3);

	per = Perimetro(forma);
	if(per != 3.71293){
		printFloat("perimetro = ", per);
	}

	return 0;
}
