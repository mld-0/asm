#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-20T00:21:10AEST '.text' '.align 2' ect. for macros source
//	}}}

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

//	Push/Pop [x0-18, LR] on/off stack <(160-bytes total?)>
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
.endm

.macro 		pop_registers
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
	str_printf_reg: .asciz "x%c=(0x%016lX): %+ld\n"			//	change 'ld' to 'lu' for unsigned value
	.align 4
.text

