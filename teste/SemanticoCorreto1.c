
int main(){

	float per;

	int x;
	int i;
	x = 2.2;

	per = 9153.2;

	for(i = 0; i < 10; i += 1){
		per /= x;
	}


	if(per != 3.71293){
		printFloat("per = ", per);
	}

	return 0;
}
