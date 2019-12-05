int main(){

	int i;
	int j;

	printInt("Digite o tamanho do loop: ", 0);
	scanInt(&j);
	for(i = 0; i < j; i += 1){
		printInt("i: ", i);
	}

	return 0;
}