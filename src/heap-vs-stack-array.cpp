
void example_heap(const int SIZE) 
{
	int v1[SIZE];
	v1[0] = 53;
	for (int i = 1; i < SIZE; ++i) {
	    v1[i] = v1[i - 1];
	}
}

void example_stack(const int SIZE) 
{
	int *v2 = new int[SIZE]; 
	v2[0] = 21;
	for (int i = 1; i < SIZE; ++i) {
	    v2[i] = v2[i - 1];
	}
	delete[] v2; 
}

int main()
{
	example_heap(2'000'000);
	example_stack(2'000'000);
	return 0;
}

