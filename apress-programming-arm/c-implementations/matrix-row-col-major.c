#include <stdio.h>

char* strf_row = "%3d  %3d  %3d\n";

#define MATRIX_N  3
int A[MATRIX_N*MATRIX_N] = {1,2,3, 4,5,6, 7,8,9};
int B[MATRIX_N*MATRIX_N] = {9,8,7, 6,5,4, 3,2,1};
int C[MATRIX_N];

//	Row-major ordering: rows are contiguous in memory
//		M[row_i,col_j] = M[row_i*nCol + col_j]
//	Column-major ordering: columns are contiguous in memory
//		M[row_i,col_j] = M[col_j*nRow + row_i]
//	Most (C) arrays are accessed in row-major order (which is generally superior vis-a-vis caching).
//	<(Fortran uses column-major order)>

//	<(Convert from one format to the other by taking the transpose of the matrix?)>


void __attribute__ ((noinline)) transpose_square_inplace(int N, int* A)
{
	for (int i = 0; i < N; ++i) {
		for (int j = i; j < N; ++j) {
			int L = A[i*N+j];
			int R = A[j*N+i];
			A[i*N+j] = R;
			A[j*N+i] = L;
		}
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
	print_NxN(MATRIX_N, A);
	printf("\n");

	transpose_square_inplace(MATRIX_N, A);
	print_NxN(MATRIX_N, A);
	printf("\n");

	transpose_square_inplace(MATRIX_N, A);
	print_NxN(MATRIX_N, A);
	printf("\n");


	return 0;
}

