#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
#	Ongoings:
#	{{{
#	Ongoing: 2022-08-02T00:14:39AEST Use of 'V' vs 'Q' (book says Q is for NEON - then uses 'V' in NEON instructions?) [...] use 'Q' for load/store(?)
#	Ongoing: 2022-08-02T00:31:58AEST FADD vs FADDP(?)
#	Ongoing: 2022-08-02T00:37:12AEST Our (previous) use of '.align 2' (in function source files) is incorrect(?)
#	Ongoing: 2022-08-03T03:47:32AEST (please) verify equivalency of 'add Vd.T, Vn.T, Vm.T' / 'ADD.T Vd, Vn, Vm' (name-of/reason-for having two formats (consider that 'otool' outputs the later)) - (must 'T' always be the same for each register of the former)
#	}}}

#	The NEON Coprocessor is responsible for single-instruction-multiple-data (SIMD) instructions.

#	The FPU and NEON share a set of (32) 128-bit registers (although the FPU only support 64-bit calculations).
#	To access the lower-N bits of the register, use: (upper bits are set to 0)
#			V (FPU)		128-bits
#			Q (NEON)	128-bits
#			D			64-bits
#			S			32-bits
#			H			16-bits
#	These registers can be used with (regular) load/store instructions.
#	<(Use 'Q' when loading/storing floating-point registers on the stack.)> <(Not 'V'?)>

#	When performing Neon instructions, each register is segmented into multiple values:
#									8-bit elements		16-bit elements			32-bit elements
#			D (64-bits)				8					4						2
#			<(Q/V?)> (128-bits)		16					8						4
#	The regions containing each value are referred to as 'lanes'.
#	These lanes can be used for integer or floating-point data.
#	Vector instructions are applied to each lane individually.

#	Designators for lane size:
#		D			64-bits
#		S			32-bits
#		H			16-bits
#		B			8-bits

#	V1 can be divided into the following lanes:
#		V1.2D
#		V1.4S
#		V1.8H
#		V1.16B

#	Vector addition:
#			ADD		Vd.T, Vn.T, Vm.T			//	integer
#			FADD	Vd.T, Vn.T, Vm.T			//	floating-point
#	Values of 'T':
#		ADD: 		8H, 16B, 4H, 8H, 2S, 4S, or 2D
#		FADD: 		4H, 8H, 2S, 4S, 2D
#	The NEON processor supports all <(common?)> integer <(and floating-point?)> instructions in this manner.

#	Equivalent(?):
#			ADD		Vd.T, Vn.T, Vm.T
#			ADD.T	Vd, Vn, Vm




.include "debug-printf.s"
.global _start
.align 4

_start:
	stp x19, x20, [SP, #-16]!
	str LR, [SP, #-16]!


call_distance4d:
	adrp 	x20, points@PAGE
	add x20, x20, points@PAGEOFF
	adrp 	x19, num_points@PAGE
	add x19, x19, num_points@PAGEOFF
	ldr w19, [x19]
1:
	mov x0, x20
	bl 	distance4d


	fmov s2, w0
	fcvt d0, s2
	fmov x1, d0
	str x1, [SP, #-16]!
	adrp 	x0, str_printf_distance@PAGE
	add x0, x0, str_printf_distance@PAGEOFF
	bl 	_printf
	add SP, SP, #16

	add x20, x20, #(8*4)
	subs w19, w19, #1
	b.ne 	1b


done:
	ldr LR, [SP], #16
	ldp x19, x20, [SP], #16
	printf_str "Done"
	mov x0, #0
	ret

.data
	points:		
		.single		0.0, 0.0, 0.0, 0.0, 17.0, 4.0, 2.0, 1.0
		.single		1.3, 5.4, 3.1, -1.5, -2.4, 0.323, 3.4, -0.232
		.single 	1.323e10, -1.2e-4, 34.55, 5454.234, 10.9, -3.6, 4.2, 1.3
	.align 4

	num_points:		.word	3
	.align 4

	str_printf_distance:	.asciz 		"Distance = %.9g\n"
	.align 4

