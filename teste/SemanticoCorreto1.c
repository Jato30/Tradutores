
int main(){

	float per;

	int x;
	int i;
	point p;
	float quadrado;
	constroiPoint(&p, 7.0, 3.2);
	printPoint("meu p: ", p);
	x = 2.2;

	per = 9153.2;

	for(i = 0; i < 10; i += 1){
		per /= x;
	}

	quadrado = x * x;
	printFloat("quad: ", quadrado);


	if(per != 3.71293){
		printFloat("per = ", per);
	}

	return 0;
}
