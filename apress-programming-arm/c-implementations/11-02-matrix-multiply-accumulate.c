//	{{{3
//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
#include "stdio.h"
//	Ongoings: 
//	{{{
//	Ongoing: 2022-07-23T00:52:16AEST (observation), assembly <lends-itself-to> do-while loops(?)
//	Ongoing: 2022-07-23T00:53:46AEST how closely asm output resembles asm <reference/origional/source> (is not 'asm-diff' something-to-do?)
//	Ongoing: 2022-07-23T00:54:28AEST how the compiler optimizer treats our loops
//	Ongoing: 2022-07-23T00:58:23AEST the hardest part of transforming (this piece of) asm -> C is (keeping track of) variable names (hence first implementation using xD variable names) (the second was realizing that our structure is a match for do-while expressions)
//	Ongoing: 2022-07-23T01:18:08AEST would it be faster to transpose B (so that when reading 'cols' of B, we actually read rows (being more cache friendly))
//	}}}

//	<(In C, (in constrast to C++) use 'define' instead of const variable (error to use const-int as array length?))>
#define MATRIX_N  3

char* strf_row = "%3d  %3d  %3d\n";
int A[MATRIX_N*MATRIX_N] = {1,2,3, 4,5,6, 7,8,9};
int B[9] = {9,8,7, 6,5,4, 3,2,1};
int C[9];

//	register_variable_names():
//	{{{
//void register_variable_names() 
//{
//	int x1 = MATRIX_N;
//	int* x4 = &A[0];
//	int* x19 = &C[0];
//	
//	do {								//	row_loop
//		int* x5 = &B[0];
//		int x2 = MATRIX_N;
//		do {							//	col_loop
//			int x7 = 0;
//			int x0 = MATRIX_N;
//			int* x12 = x4;
//			int* x6 = x5;
//			do {						//	dot_loop
//				int x9 = *x12++;
//				int x10 = *x6; 
//				x6 += MATRIX_N;
//				x7 = x9 * x10 + x7;
//				x0--;
//			} while (x0 > 0);			//	end dot_loop
//			*x19++ = x7;
//			x5++;
//			x2--;
//		} while (x2 > 0);				//	end col_loop
//		x4 += MATRIX_N;
//		x1--;
//	} while (x1 > 0);					//	end row_loop
//	int x20 = MATRIX_N;
//	x19 = &C[0];
//	do {
//		int x1 = *x19++;
//		int x2 = *x19++;
//		int x3 = *x19++;
//		printf(strf_row, x1, x2, x3);
//		x20--;
//	} while (x20 > 0);
//}
//	}}}

void improved_variable_names() 
{
	int row_index = MATRIX_N;

	int* row_pointer = &A[0];
	int* C_pointer = &C[0];
	do {		
		int* col_pointer = &B[0];
		int col_index = MATRIX_N;

		do {
			int sum = 0;
			int dot_index = MATRIX_N;
			int* dot_row_pointer = row_pointer;
			int* dot_col_pointer = col_pointer;

			do {
				int A_element = *dot_row_pointer++;
				int B_element = *dot_col_pointer; 
				dot_col_pointer += MATRIX_N;
				sum = A_element * B_element + sum;
				dot_index--;
			} while (dot_index > 0);

			*C_pointer++ = sum;
			col_pointer++;
			col_index--;
		} while (col_index > 0);

		row_pointer += MATRIX_N;
		row_index--;
	} while (row_index > 0);

	int counter = MATRIX_N;
	C_pointer = &C[0];
	do {
		int temp1 = *C_pointer++;
		int temp2 = *C_pointer++;
		int temp3 = *C_pointer++;
		printf(strf_row, temp1, temp2, temp3);
		counter--;
	} while (counter > 0);
}


int main()
{
	improved_variable_names();
	return 0;
}

