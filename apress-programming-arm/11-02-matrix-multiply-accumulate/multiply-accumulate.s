//	{{{3
//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-20T19:04:54AEST algorithm works for different values of 'MATRIX_N'?
//	Ongoing: 2022-07-20T19:39:34AEST how generalisable is 'strf_row'? ((it is) not usable with different values of 'MATRIX_N')
//	}}}

//	Multiply and Accumulate is a common linear algebra instruction.
//	(Most multiply instructions are aliases for multiply-accumulate instructions with XZR as Xa)

//	Xd = Xa + Xn * Xm
//	Xd = Xa - Xn * Xm
//	(Xd can be the same as Xa, for calculating a running sum).

//	Basic instructions:
//			MADD	Xd, Xn, Xm, Xa
//			MSUB	Xd, Xn, Xm, Xa

//	32-bit values into 64-bit result:
//			SMADDL	Xd, Wn, Wm, Xa			(signed)
//			UMADDL	Xd, Wn, Wm, Xa			(unsiged)
//			SMSUBL	Xd, Wn, Wm, Xa
//			UMSUBL	Xd, Wn, Wm, Xa

.include "debug-printf.s"
.include "debug-timing.s"
.global _start
.align 4

//	Multiply 3x3 matricies, register usage:
//		x0		dotloop/printloop counter 
//		w1		row_index
//		w2		col_index
//		x4		row_pointer
//		x5		col_pointer
//		x12		dotloop_row_pointer
//		x6		dotloop_col_pointer
//		x7		sum
//		w9		A_element
//		w10		B_element
//		x19		C_pointer
//		x20		printloop counter

.equ MATRIX_N, 3			//	matrix dimensions 
.equ WDSIZE, 4				//	size of elements <(bytes?)>

_start:
	timer_start

matrix_multiply:
	str LR, [SP, #-16]!							//	push LR, x19-20
	stp x19, x20, [SP, #-16]!

	mov w1, #MATRIX_N							//	row_index
	adrp 	x4, A@PAGE							//	start (in A)
	add x4, x4, A@PAGEOFF
	adrp 	x19, C@PAGE							//	start (in C)
	add x19, x19, C@PAGEOFF

row_loop:
	adrp 	x5, B@PAGE							//	start (in B)
	add x5, x5, B@PAGEOFF
	mov w2, #MATRIX_N							//	col_index = [MATRIX_N, 0)

col_loop:
	mov x7, #0									//	initalize sum
	mov w0, #MATRIX_N							//	counter = [MATRIX_N, 0)
	mov x12, x4									//	dotloop_row = current row (in A)
	mov x6, x5									//	dotloop_col = current col (in B)

dot_loop:
	ldr w9, [x12], #WDSIZE						//	A_cell = A[dotloop_row]; dotloop_row += WDSIZE
	ldr w10, [x6], #(MATRIX_N*WDSIZE)			//	B_cell = B[dotloop_col]; dotloop_col += MATRIX_N*WDSIZE 
	smaddl x7, w9, w10, x7						//	x7 = x7 + w9 * w10
	subs w0, w0, #1								//	counter--
	b.ne 	dot_loop							//	if counter != 0

	str w7, [x19], #WDSIZE						//	C[C_position] = sum; C_position += WDSIZE
	add x5, x5, #WDSIZE							//	col_address += WDSIZE
	subs w2, w2, #1								//	col_index--
	b.ne 	col_loop							//	if col_index != 0

	add x4, x4, #(MATRIX_N*WDSIZE)				//	row_address += MATRIX_N*WDSIZE
	subs w1, w1, #1								//	row_index -= 1
	b.ne 	row_loop							//	if row_index != 0


print_C:										//	print 3x3 matrix 'C'
	mov w20, #MATRIX_N
	adrp 	x19, C@PAGE
	add x19, x19, C@PAGEOFF
print_loop:
	adrp 	x0, strf_row@PAGE					//	call 'printf()' with 3 elements of current <(row?)>
	add x0, x0, strf_row@PAGEOFF
	ldr w1, [x19], #WDSIZE
	ldr w2, [x19], #WDSIZE
	ldr w3, [x19], #WDSIZE
	sub SP, SP, #32
	str w1, [SP, #0]
	str w2, [SP, #8]
	str w3, [SP, #16]
	bl 	_printf
	add SP, SP, #32
	subs w20, w20, #1
	b.ne 	print_loop

	ldp x19, x20, [SP], #16						//	pop LR, x19-20
	ldr LR, [SP], #16
	b 	done


done:
	timer_elapsed
	printf_str 	"Done"
	mov x0, #0
	ret

.data
	.align 4
	A:		.word	1, 2, 3
			.word	4, 5, 6
			.word	7, 8, 9

	.align 4
	B:		.word	9, 8, 7
			.word	6, 5, 4
			.word	3, 2, 1

	.align 4
	C:		.fill	(MATRIX_N*MATRIX_N), WDSIZE, 0

	.align 4
	strf_row: .asciz  "%3d  %3d  %3d\n"

