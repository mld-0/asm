#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
#	Ongoings:
#	{{{
#	Ongoing: 2022-08-04T04:17:01AEST which registers <should/must> 'multiply_NxN' function(s) save?
#	Ongoing: 2022-08-04T04:21:15AEST gcc does not save certain registers (which should be saved for completeness sake?)
#	Ongoing: 2022-08-04T04:33:28AEST does compiler-explorer produce same functions?
#	}}}
#	Continue: 2022-08-04T04:31:20AEST unimplemented functions, row<->col-major, print-matrix
#	Continue: 2022-08-04T04:31:44AEST cleanup/comment/decipher</step-through> copy-pasted functions
#	Continue: 2022-08-04T04:32:16AEST what (additional) registers <should/must> be saved/restored?

.include "debug-printf.s"
.global _start
.align 4

//	'multiply_NxN' Arguments:
//		x0 = N (where matricies are NxN)
//		x1 = &A
//		x2 = &B
//		x3 = &C

_start:
	str LR, [SP, #-16]!
	stp x19, x20, [SP, #-16]!
	b 	main

row_major_to_col_major:
	nop
col_major_to_row_major:
	nop
print_row_major_square_matrix:
	nop

main:
	mov x0, #4
	adrp 	x1, A1@PAGE
	add x1, x1, A1@PAGEOFF
	adrp 	x2, B1@PAGE
	add x2, x2, B1@PAGEOFF
	adrp 	x3, C1@PAGE
	add x3, x3, C1@PAGEOFF

	printf_memory_ints 		x1, 16
	printf_memory_ints 		x2, 16

	bl 	multiply_NxN_O3

	adrp 	x3, C1@PAGE
	add x3, x3, C1@PAGEOFF
	printf_memory_ints 		x3, 16

	b 	done


multiply_NxN_Os:
	cmp	w0, #0x1
	b.lt	L4
	mov	w8, #0x0
	sxtw	x10, w0
	mov	w9, w0
	lsl	x10, x10, #2
L1:	mov	w11, #0x0
	mov	x12, x2
L2:	mov	x14, #0x0
	mov	w13, #0x0
	mov	x15, x12
L3:	ldr	w16, [x1, x14, lsl #2]
	ldr	w17, [x15], #0xc
	madd	w13, w17, w16, w13
	add	x14, x14, #0x1
	cmp	w9, w14
	b.ne	L3
	str	w13, [x3], #0x4
	add	x12, x12, #0x4
	add	w11, w11, #0x1
	cmp	w11, w0
	b.ne	L2
	add	w8, w8, #0x1
	add	x1, x1, x10
	cmp	w8, w9
	b.ne	L1
L4:	ret


multiply_NxN_O3:
	stp	x24, x23, [sp, #-0x30]!
	stp	x22, x21, [sp, #0x10]
	stp	x20, x19, [sp, #0x20]
	subs	w8, w0, #0x1
	b.lt	LC
	mov	w9, #0x0
	sxtw	x14, w0
	mov	w10, w0
	add	x12, x8, #0x1
	and	x11, x12, #0xf
	tst	x12, #0xf
	mov	w13, #0x10
	csel	x11, x13, x11, eq
	sub	x12, x12, x11
	add	x13, x1, #0x20
	lsl	x14, x14, #2
	add	x15, x2, #0x60
	mov	w16, #0xc
	umull	x17, w8, w16
	msub	x16, x11, x16, x17
	add	x16, x16, #0xc
	lsl	x17, x8, #2
	sub	x17, x17, x11, lsl #2
	add	x17, x17, #0x4
	b	L8
LA:	add	w9, w9, #0x1
	add	x13, x13, x14
	add	x1, x1, x14
	cmp	w9, w0
	b.eq	LC
L8:	cmp	w8, #0x10
	b.hs	LB
	mov	w4, #0x0
	mov	x5, x2
L10: mov	x7, #0x0
	mov	w6, #0x0
	mov	x19, x5
L9:	ldr	w20, [x1, x7, lsl #2]
	ldr	w21, [x19], #0xc
	madd	w6, w21, w20, w6
	add	x7, x7, #0x1
	cmp	w10, w7
	b.ne	L9
	str	w6, [x3], #0x4
	add	x5, x5, #0x4
	add	w4, w4, #0x1
	cmp	w4, w10
	b.ne	L10
	b	LA
LB:	mov	w4, #0x0
	mov	x5, x15
	mov	x6, x2
L6:	movi.2d	v0, #0000000000000000
	mov	x7, x5
	mov	x19, x13
	mov	x20, x12
	movi.2d	v1, #0000000000000000
	movi.2d	v2, #0000000000000000
	movi.2d	v3, #0000000000000000
LD:	sub	x21, x7, #0x60
	sub	x22, x7, #0x30
	ld3.4s	{ v4, v5, v6 }, [x21]
	ld3.4s	{ v16, v17, v18 }, [x22]
	ldp	q7, q19, [x19, #-0x20]
	ldp	q20, q21, [x19], #0x40
	mov	x21, x7
	ld3.4s	{ v22, v23, v24 }, [x21], #48
	ld3.4s	{ v25, v26, v27 }, [x21]
	mla.4s	v0, v4, v7
	mla.4s	v1, v16, v19
	mla.4s	v2, v22, v20
	mla.4s	v3, v25, v21
	add	x7, x7, #0xc0
	subs	x20, x20, #0x10
	b.ne	LD
	add.4s	v0, v1, v0
	add.4s	v0, v2, v0
	add.4s	v0, v3, v0
	addv.4s	s0, v0
	fmov	w7, s0
	mov	x19, x17
	mov	x20, x16
	mov	x21, x11
L7:	ldr	w22, [x1, x19]
	ldr	w23, [x6, x20]
	madd	w7, w23, w22, w7
	add	x20, x20, #0xc
	add	x19, x19, #0x4
	subs	w21, w21, #0x1
	b.ne	L7
	str	w7, [x3], #0x4
	add	x6, x6, #0x4
	add	w4, w4, #0x1
	add	x5, x5, #0x4
	cmp	w4, w0
	b.ne	L6
	b	LA
LC:	ldp	x20, x19, [sp, #0x20]
	ldp	x22, x21, [sp, #0x10]
	ldp	x24, x23, [sp], #0x30
	ret
	

done:
	ldp x19, x20, [SP], #16						//	pop LR, x19-20
	ldr LR, [SP], #16
	printf_str "Done"
	mov x0, #0
	ret

.data
	A1: 	.word 		1, 2, 3, 4
			.word 		4, 3, 2, 1
			.word 		1, 2, 3, 4
			.word 		4, 3, 2, 1

	B1: 	.word 		9, 8, 7, 6
			.word 		6, 7, 8, 9
			.word 		9, 8, 7, 6
			.word 		6, 7, 8, 9

	C1:		.fill 		4*4, 4, 0

