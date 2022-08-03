#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-20T00:21:10AEST '.text' '.align 2' ect. for macros source
//	Ongoing: 2022-08-03T18:54:16AEST Using '.data' string variables vs strings embedded at a label in macro?
//	Ongoing: 2022-08-03T22:22:11AEST handle labeling of registers containing multiple digits
//	}}}

//	Continue: 2022-08-03T17:26:57AEST add label string argument to print register macros

//	These macros preseve all registers. Beware they will change the condition flags.

//	'printf_reg(reg)':
//		reg:		must be a register number (as literal integer, '3' is valid but '#3' is not)
.macro 		printf_reg		reg
	push_registers
	mov x2, x\reg 					//	%lx, %ld
	mov x1, #\reg + '0'				//	%c
	mov FP, SP
	sub SP, SP, #32
	str x1, [SP, #0]
	str x2, [SP, #8]
	str x2, [SP, #16]
	adrp 	x0, str_printf_reg@PAGE
	add x0, x0, str_printf_reg@PAGEOFF
	bl	_printf
	mov SP, FP
	pop_registers
.endm


//	'printf_str(str)':
//		str: 		must be a literal string
.macro 		printf_str		str
	push_registers
	adr x0, 1f
	bl 	_printf
	pop_registers
	b 	2f
1:	.asciz "\str\n"
	.align 4
2: 	
.endm


//	'printf_[float|double]_reg(reg)'
//		reg:		must be a register number (as literal integer, '3' is valid but '#3' is not)
.macro 		printf_float_reg 	reg
	push_registers
	mov x1, #\reg + '0'
	fmov s2, s\reg
	fcvt d0, s2
	fmov x2, d0
	adrp 	x0, str_printf_float_reg@PAGE
	add x0, x0, str_printf_float_reg@PAGEOFF
	mov FP, SP
	sub SP, SP, #32
	str x1, [SP, #0]
	str x2, [SP, #8]
	str x2, [SP, #16]
	bl 	_printf
	mov SP, FP
	pop_registers
.endm
.macro		printf_double_reg 	reg
	push_registers
	mov x1, #\reg + '0'
	fmov x2, d\reg
	adrp 	x0, str_printf_double_reg@PAGE
	add x0, x0, str_printf_double_reg@PAGEOFF
	mov FP, SP
	sub SP, SP, #32
	str x1, [SP, #0]
	str x2, [SP, #8]
	str x2, [SP, #16]
	bl 	_printf
	mov SP, FP
	pop_registers
.endm


//	printf_memory_[ints|bytes](start,end): print a memory range as ints/bytes
//		start:		register containing start of memory range
//		len:		number of bytes (as literal integer)
.macro 		printf_memory_ints 		start, len
	push_registers
	mov x19, \start
	mov x20, #\len
	adrp 	x0, str_printf_report_ints@PAGE
	add x0, x0, str_printf_report_ints@PAGEOFF
	mov FP, SP
	sub SP, SP, #16
	str x19, [SP, #0]
	str x20, [SP, #8]
	bl 	_printf
	mov SP, FP
	adrp 	x21, str_printf_int@PAGE
	add x21, x21, str_printf_int@PAGEOFF
1: 	ldr w3, [x19]
	mov FP, SP
	sub SP, SP, #16
	mov x0, x21
	str w3, [SP, #0]
	bl 	_printf
	mov SP, FP
	add x19, x19, #4
	subs x20, x20, #1
	b.gt 	1b
	adrp 	x0, str_printf_nl@PAGE
	add x0, x0, str_printf_nl@PAGEOFF
	bl 	_printf
	pop_registers
.endm
.macro 		printf_memory_bytes		start, len
	push_registers
	mov x19, \start
	mov x20, #\len
	adrp 	x0, str_printf_report_bytes@PAGE
	add x0, x0, str_printf_report_bytes@PAGEOFF
	mov FP, SP
	sub SP, SP, #16
	str x19, [SP, #0]
	str x20, [SP, #8]
	bl 	_printf
	mov SP, FP
	adrp 	x21, str_printf_byte@PAGE
	add x21, x21, str_printf_byte@PAGEOFF
1:	ldrb w3, [x19]
	mov FP, SP
	sub SP, SP, #16
	mov x0, x21
	str w3, [SP, #0]
	bl 	_printf
	mov SP, FP
	add x19, x19, #1
	subs x20, x20, #1
	b.gt 	1b
	adrp x0, str_printf_nl@PAGE
	add x0, x0, str_printf_nl@PAGEOFF
	bl 	_printf
	pop_registers
.endm


//	Push/Pop [x0-18, LR, q0-q7] on/off stack <(288-bytes total?)>
.macro 		push_registers
	stp 	x0, x1, [SP, #-16]!
	stp 	x2, x3, [SP, #-16]!
	stp 	x4, x5, [SP, #-16]!
	stp 	x6, x7, [SP, #-16]!
	stp 	x8, x9, [SP, #-16]!
	stp 	x10, x11, [SP, #-16]!
	stp 	x12, x13, [SP, #-16]!
	stp 	x14, x15, [SP, #-16]!
	stp 	x16, x17, [SP, #-16]!
	stp 	x18, LR, [SP, #-16]!
	stp 	q0, q1, [SP, #-32]!
	stp 	q2, q3, [SP, #-32]!
	stp 	q4, q5, [SP, #-32]!
	stp 	q6, q7, [SP, #-32]!
.endm
.macro 		pop_registers
	ldp 	q6, q7, [SP], #32
	ldp 	q4, q5, [SP], #32
	ldp 	q2, q3, [SP], #32
	ldp 	q0, q1, [SP], #32
	ldp 	x18, LR, [SP], #16
	ldp 	x16, x17, [SP], #16
	ldp 	x14, x15, [SP], #16
	ldp 	x12, x13, [SP], #16
	ldp 	x10, x11, [SP], #16
	ldp 	x8, x9, [SP], #16
	ldp 	x6, x7, [SP], #16
	ldp 	x4, x5, [SP], #16
	ldp 	x2, x3, [SP], #16
	ldp 	x0, x1, [SP], #16
.endm

.data
	str_printf_report_bytes:	.asciz 		"bytes, addr=(0x%016lX), len=(%d):\n"
	.align 4
	str_printf_report_ints:		.asciz 		"ints, addr=(0x%016lX), len=(%d):\n"
	.align 4
	str_printf_int: .asciz "%i "
	.align 4
	str_printf_byte: 	.asciz 	"%02X "
	.align 4
	str_printf_nl: 	.asciz 	"\n"
	.align 4
	str_printf_reg: .asciz "x%c=(0x%016lX): %+ld\n"			//	change 'ld' to 'lu' for unsigned value
	.align 4
	str_printf_float_reg:	.asciz 	"s%c=(%A): %+.9g\n"
	.align 4
	str_printf_double_reg:	.asciz 	"s%c=(%A): %+.17g\n"
	.align 4
.text

