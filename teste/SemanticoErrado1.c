int dobra(int x){
	x *= 2;
	return x;
}


int main(){

	int per;

	int x;
	x = 2;
	printInt("x = ", x);
	x = dobra(x, 2);
	printInt("x = ", x);
	per = 53.2;
	if(per != 3.71293){
		printFloat("per = ", per);
	}

	return 0;
}
