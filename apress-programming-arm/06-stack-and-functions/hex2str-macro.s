//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2

//	Convert the value of a register to a string as hex.
//	Preserves caller registers.
//	Arguments:
//			register = x0		input value
//	Registers:
//			w5					counter
//			w6					current hex digit
//			x7					x0 (input value) 
//			x8					x1 (output string)
//	Returns:
//			x0					input value


.macro hex2str 	register
	mov x0, \register

	//	Store registers x1-x8
	mov fp, sp
	sub sp, sp, #64
	str x1, [sp, #0]
	str x2, [sp, #8]
	str x3, [sp, #16]
	str x4, [sp, #24]
	str x5, [sp, #32]
	str x6, [sp, #40]
	str x7, [sp, #48]
	str x8, [sp, #56]

	adrp 	x1, hexstr@PAGE
	add x1, x1, hexstr@PAGEOFF
	mov x7, x0
	mov x8, x1

	add x8, x8, #17					//	index of last '0' in output string
	mov w5, #16						//	16 hex digits
1:	//	hex2strloop:
	and w6, w7, #0xF				//	current hex digit is last 4 bytes
	cmp w6, #10						//	is current hex digit 0-9 or A-F?
	b.ge	2f
	add w6, w6, #'0'				//	convert 0-9 to ascii
	b 		3f
2:	//	hex2strletter:
	add w6, w6, #('A'-10)			//	convert A-F to ascii
3:	//	hex2strcontinue:
	strb w6, [x8]					//	store ascii-digit in hexstr
	sub x8, x8, #1					//	x8--
	lsr x7, x7, #4					//	x7 <<= 4
	subs w5, w5, #1					//	w5--
	b.ne 	1b 						//	repeat if w5 != 0

	mov x7, x0						//	save x0

	//	Print 'hexstr' (result)
	mov x0, #1						//	1 = stdout
	mov x2, #19						//	len(hexstr)
	mov x16, #4						//	4 = write syscall
	svc 0

	mov x0, x7						//	restore x0

	//	Load registers x1-x8
	ldr x1, [sp, #0]
	ldr x2, [sp, #8]
	ldr x3, [sp, #16]
	ldr x4, [sp, #24]
	ldr x5, [sp, #32]
	ldr x6, [sp, #40]
	ldr x7, [sp, #48]
	ldr x8, [sp, #56]
	mov sp, fp
.endm

