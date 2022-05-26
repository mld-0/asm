
void run_test(const int SIZE) 
{
	int v1[SIZE];
	v1[0] = 53;
	for (int i = 1; i < SIZE; ++i) {
	    v1[i] = v1[i - 1];
	}

	int *v2 = new int[SIZE]; 
	v2[0] = 21;
	for (int i = 1; i < SIZE; ++i) {
	    v2[i] = v2[i - 1];
	}
	delete[] v2; 
}

int main()
{
	run_test(2'000'000);
	return 0;
}


