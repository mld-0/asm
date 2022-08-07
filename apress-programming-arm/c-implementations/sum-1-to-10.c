#include "stdio.h"

int main()
{
	long sum = 0;
	long count = 1;
	long count_end = 10;

	do 
	{
		sum = sum + count;
		count = count + 1;
	} 
	while (count <= count_end);

	printf("sum=(%ld)\n", sum);
	return 0;
}

