int x;

int func(int par, int par2){
	int x;
	x = par;
	return x;
}

int main(){

	int x;
	x = 2;
	x = func(7, x);
	scanInt(&x, 15);
	printInt("x: ", x);

	return 0;
}
