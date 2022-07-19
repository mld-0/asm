//	{{{3
//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-19T02:10:36AEST book/HelloSilicon examples push/pop LR on stack for body as-if 'main' were called as a function? [...] (do any previous HelloSilicon examples do this?) [...] it literally does terminate by calling 'ret' -> is this a way to terminate the program? <- it is (when doing so, do we have to update LR?) (LR is the <only> register (in such case) we need to save?)
//	Ongoing: 2022-07-19T02:23:47AEST Size of a 'word' on ARM32/ARM64? <(8-bytes on 64bit ARM?)> [...] (a word is 32-bits / 4-bytes ? (the size of an integer?) <- this is 32bit ARM)
//	}}}

.include "debug-printf.s"

.text
.global _start

.align 2

_start:
//	Addition and Subtraction:
	//	{{{
	////	128-bit addition: (x0,x1) = (x2,x3) + (x4,x5)
	//mov x2, #0x0000000000000003
	//mov x3, #0xFFFFFFFFFFFFFFFF
	//mov x4, #0x0000000000000005
	//mov x5, #0x0000000000000001
	////	add lower order bits
	////printf_register 2
	////printf_register 3
	////printf_register 4
	////printf_register 5
	////	add higher order bits
	//adds x1, x3, x5
	//adc x0, x2, x4
	////printf_register 0
	////printf_register 1
	////	128-bit subtraction: (x0,x1) = (x2,x3) - (x4,x5)
	//mov x2, #0x0000000000000005
	//mov x3, #0x0000000000000001
	//mov x4, #0x0000000000000003
	//mov x5, #0xFFFFFFFFFFFFFFFF
	////	subtract
	////printf_register 2
	////printf_register 3
	////printf_register 4
	////printf_register 5
	//subs x1, x3, x5
	//sbc x0, x2, x4
	////	Ongoing: 2022-07-04T16:00:50AEST 128bit subtraction is correct?
	////printf_register 0
	////printf_register 1
	//	}}}

	//	(x2,x3) = 0x0000000000000003FFFFFFFFFFFFFFFF
	//	(x4,x5) = 0x00000000000000050000000000000001
	//	<( '(x0,x1) = (x2,x3) + (x4,x5)' ?)>

	mov	x2, #0x0000000000000003
	mov	x3, #0xFFFFFFFFFFFFFFFF	
	mov	x4, #0x0000000000000005
	mov	x5, #0x0000000000000001
	printf_str 		"Inputs:"
	printf_reg		2
	printf_reg		3
	printf_reg		4
	printf_reg		5

	adds 	x1, x3, x5			//	lower-order word
	adc 	x0, x2, x4			//	higher-order word
	printf_str 		"Outputs:"
	printf_reg 		1
	printf_reg 		0



	//	Write 'donemsg'
	mov x0, #1							//	1 = stdout
	adr x1, donemsg
	adrp 	x2, len_donemsg@PAGE		//	len(donemsg)
	add x2, x2, len_donemsg@PAGEOFF
	ldr x2, [x2]
	mov x16, #4							//	4 = write syscall
	svc 0
	//	macOS 'exit' syscall, return x0
	mov x0, #0
	mov x16, #1
	svc 0

.data:
	.align 4
	donemsg: .ascii "Done\n"
	.align 4
	len_donemsg: .word .-donemsg



