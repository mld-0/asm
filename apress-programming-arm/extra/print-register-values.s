#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-06T22:44:53AEST 'adr x1, donemsg' is acceptable for a variable not in '.data' (or where '.data:' is used incorrectly), but need to use 'adrp x1 donemsg@PAGE; add x1, x1, donemsg@PAGEOFF' for variable that is in '.data'
//	}}}
//	LINKS:
//	{{{
//	LINK: https://stackoverflow.com/questions/17357467/how-to-print-a-number-in-arm-assembly
//	LINK: https://stackoverflow.com/questions/17357467/how-to-print-a-number-in-arm-assembly
//	}}}
//	Continue: 2022-07-04T23:05:15AEST Use printf str 'x%d=(0x%x)', with register number / value as arguments

.global _start

.align 2

_start:

	//	Example: call printf for example value (loaded into x8) (macOS Specific)
	//	LINK: https://stackoverflow.com/questions/69454175/calling-printf-from-aarch64-asm-code-on-apple-m1-macos
	//	64-bytes = 16-hex-digits
	mov x8,  #0x6E3A
	movk x8, #0x4F5D, LSL #16
	movk x8, #0xFEDC, LSL #32
	movk x8, #0x1234, LSL #48
	stp x29, x30, [sp, -0x10]!
    sub sp, sp, 0x10
    str x8, [sp]
	adrp x0, hexformatstr@PAGE
	add x0, x0, hexformatstr@PAGEOFF
    bl _printf
    mov w0, 0
    add sp, sp, 0x10
    ldp x29, x30, [sp], 0x10


	//	Example: register hexvalue to string (loaded into x4) (macOS Specific)
	//	HelloSilicon/04/printdword
	mov x4,  #0x6E3A
	movk x4, #0x4F5D, LSL #16
	movk x4, #0xFEDC, LSL #32
	movk x4, #0x1234, LSL #48
	//	Darwin does not like 'ldr x1, =hexstr' <(for variables in '.data'?)>
	adrp 	x1, hexstr@PAGE
	add x1, x1, hexstr@PAGEOFF
	add x1, x1, #17						//	index of last '0' in string
	//	for w5 = range(16,0,-1):
	mov w5, #16							//	16 hex digits
hex2strloop:
	and w6, w4, #0xf					//	current digit is last 4-bytes
	cmp w6, #10							//	is digit 0-9 or A-F?
	B.GE hex2strletter
	add w6, w6, #'0'					//	convert 0-9 to ascii
	B hex2strcontinue
hex2strletter:
	add w6, w6, #('A'-10)				//	convert A-F to ascii
hex2strcontinue:
	strb w6, [x1]						//	store ascii-digit in hexstr
	sub x1, x1, #1						//	x1 -= 1
	lsr x4, x4, #4						//	x4 <<= 4
	subs w5, w5, #1						//	w5 -= 1
	B.NE hex2strloop					//	repeat if w5 != 0
	//	Print 'hexstr'
	mov x0, #1							//	1 = stdout
	adrp 	x1, hexstr@PAGE
	add x1, x1, hexstr@PAGEOFF
	mov x2, #19							//	len(hexstr)
	mov x16, #4							//	write syscall
	svc #0x80


	//	Write 'donemsg'
	mov x0, #1			//	1 = stdout
	adrp x1, donemsg@PAGE
	add x1, x1, donemsg@PAGEOFF
	mov x2, #5			//	5 = len(donemsg)
	mov x16, #4			//	4 = write syscall
	svc 0
	//	macOS 'exit' syscall, return x0
	mov x0, #0
	mov x16, #1
	svc 0

.data
	.align 4
	hexstr: .ascii "0x0000000000000000\n"

	.align 4
	hexformatstr: .ascii "0x%016lX\n"

	.align 4
	donemsg: .ascii "Done\n"

