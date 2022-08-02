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

//	Continue: 2022-08-02T23:34:16AEST Can C++ perform any further optimizations if we provide N as a template parameter?

//	<(In C, (in constrast to C++) use 'define' instead of const variable (error to use const-int as array length?))>
#define MATRIX_N  3

const int A[MATRIX_N*MATRIX_N] = {1,2,3, 4,5,6, 7,8,9};
const int B[MATRIX_N*MATRIX_N] = {9,8,7, 6,5,4, 3,2,1};
int C[MATRIX_N];

#define MATRIX_N2 	1000
int A2[MATRIX_N2*MATRIX_N2];
int B2[MATRIX_N2*MATRIX_N2];
int C2[MATRIX_N2*MATRIX_N2];


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

template<size_t N>
void __attribute__ ((noinline)) multiply_NxN(const int* A, const int* B, int* C)
{
	const int *A_row = A;
	int *pC = C;
	for (int row_index = 0; row_index < N; ++row_index) {
		const int *B_col = B;
		for (int col_index = 0; col_index < N; ++col_index) {
			int sum = 0;
			const int* pA = A_row;
			const int* pB = B_col;
			for (int dot_index = 0; dot_index < N; ++dot_index) {
				sum += (*pA) * (*pB);
				pA += 1; 
				pB += 3;
			}
			*pC = sum;
			B_col += 1;
			pC += 1;
		}
		A_row += N;
	}
}

void __attribute__ ((noinline)) print_NxN(const int N, const int* A) 
{
	const int* pA = A;
	for (int row_index = 0; row_index < N; ++row_index) {
		for (int col_index = 0; col_index < N; ++col_index) {
			printf("%5d ", *pA);
			pA += 1;
		}
		printf("\n");
	}
}


int main()
{
	//multiply_NxN<MATRIX_N>(A, B, C);
	//print_NxN(MATRIX_N, C);

	multiply_NxN<MATRIX_N2>(A2, B2, C2);

	return 0;
}

