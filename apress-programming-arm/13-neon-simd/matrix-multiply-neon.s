#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
#	Ongoings:
#	{{{
#	Ongoing: 2022-08-02T00:47:53AEST use 3x3 (not 4x4) variables (as input)
#	Ongoing: 2022-08-03T23:21:49AEST meaning/purpouse of '[\d]' in 'mulcol'? [...] access a single lane of a <vector/SIMD> register (as a register)(?)
#	Ongoing: 2022-08-03T23:29:34AEST Update book code to perform SIMD matrix multiplication on ints/longs
#	}}}

#	'\()' is a null expression, used here to seperate parameter and following characters

.include "debug-printf.s"
.global _start
.align 4

_start:
	stp x19, x20, [SP, #-16]!
	str LR, [SP, #-16]!


#	Registers:
#		A (columns) = (D0,D1,D2)
#		B (columns) = (D3,D4,D5)
#		C (columns) = (D6,D7,D8)
matmul_neon:
	adrp	x0, A@PAGE						//	load A into d0,d1,d2
	add	x0, x0, A@PAGEOFF
	ldp	d0, d1, [x0], #16
	ldr	d2, [x0]

	adrp	x0, B@PAGE						//	load B into d3,d4,d5
	add	x0, x0, B@PAGEOFF
	ldp	d3, d4, [x0], #16
	ldr	d5, [x0]

.macro 	mulcol 	c_col b_col
	mul.4H		\c_col\(), v0, \b_col\()[0]
	mla.4H		\c_col\(), v1, \b_col\()[1]
	mla.4H		\c_col\(), v2, \b_col\()[2]
.endm
	mulcol	v6, v3							//	v6 = C col1
	mulcol	v7, v4							//	v7 = C col2
	mulcol	v8, v5							//	v8 = C col3

	adrp	x0, C@PAGE						//	store d6,d7,d8 in C
	add	x0, x0, C@PAGEOFF
	stp	d6, d7, [x0]
	str	d8, [x0, #16]

	adrp	x0, C@PAGE						//	print C
	add	x0, x0, C@PAGEOFF
	bl 	print_col_major_matrix
	b	done


print_col_major_matrix:
	str LR, [SP, #-16]!
	adrp 	x21, str_printf_row_3x3@PAGE
	add x21, x21, str_printf_row_3x3@PAGEOFF
	mov w19, #3								//	w19 = 3 rows to print
	mov x20, x0 							// 	x20 = matrix address
1: 	
	ldrh 	w1, [x20], #2					//	1st element in current row
	ldrh 	w2, [x20, #6]					//	2nd element in current row
	ldrh 	w3, [x20, #14]					//	3rd element in current row
	sub SP, SP, #32							//	call printf()
	str w1, [SP, #0]
	str w2, [SP, #8]
	str w3, [SP, #16]
	mov  x0, x21
	bl 	_printf
	add SP, SP, #32
	subs w19, w19, #1
	b.ne 	1b
	ldr LR, [SP], #16
	ret


done:
	ldr LR, [SP], #16
	ldp x19, x20, [SP], #16
	printf_str "Done"
	mov x0, #0
	ret

.data
	// First matrix in column major order
	A:	.short	1, 4, 7, 0
		.short	2, 5, 8, 0
		.short	3, 6, 9, 0
	// Second matrix in column major order
	B:	.short	9, 6, 3, 0
		.short	8, 5, 2, 0
		.short	7, 4, 1, 0
	// Result matix in column major order
	C:	.fill	12, 2, 0

	vals: 	.word 	1, 2, 3, 0
			.word 	4, 5, 6, 0
			.word 	7, 8, 9, 0

	str_printf_row_3x3:		.asciz		"%5d %5d %5d\n"

