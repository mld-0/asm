#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
#	Ongoings:
#	{{{
#	Ongoing: 2022-08-02T00:47:53AEST use 3x3 (not 4x4) variables (as input)
#	}}}

.include "debug-printf.s"
.global _start
.align 4

_start:
	stp x19, x20, [SP, #-16]!
	str LR, [SP, #-16]!

#	Continue: 2022-08-02T00:45:50AEST matrix-multiply-neon
#	<>

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

