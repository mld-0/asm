#include <stdio.h>

//	If we follow the assembly function-calling protocol (see ch6), functions written in assembly can be called from C as-if they were written in C.

//	This is the simplest method of using an asm-function - providing its declaration in C, and supplying both source files to the compiler.

//	Provide the asm-function declaration, so that we may call it.
//	Note that it is up to us to ensure that the asm-function recieves our arguments correctly.
extern int mytoupper(char*, char*, int);

#define MAX_BUFFSIZE	255

int main()
{
	char *test_str = "This is our test string.";
	char out_buffer[MAX_BUFFSIZE];
	int len_result;

	len_result = mytoupper(test_str, out_buffer, MAX_BUFFSIZE);

	printf("test_str=(%s)\n", test_str);
	printf("out_buffer=(%s)\n", out_buffer);
	printf("len_result=(%d)\n", len_result);

	return 0;
}

