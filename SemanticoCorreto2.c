int x;

int func(){
	int x;
	x = 3;
	return x;
}

int main(){

	int per;
	int x;
	x = func();

	per = 53.2;
	if(per != 3.71293){
		printFloat("per = ", per);
	}

	return 0;
}
