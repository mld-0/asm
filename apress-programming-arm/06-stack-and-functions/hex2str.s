//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2

//	Convert the value of a register to a string as hex
//	Arguments:
//			x0		input value
//	Registers:
//			w5		counter
//			w6		current hex digit
//			x7		x0 (input value) 
//			x8		x1 (output string)
//	Returns:
//			x0		input value
//			x1 		pointer to output string

.global hex2str

.align 2

hex2str:
	adrp 	x1, hexstr@PAGE
	add x1, x1, hexstr@PAGEOFF
	mov x7, x0
	mov x8, x1

	add x8, x8, #17					//	index of last '0' in output string
	mov w5, #16						//	16 hex digits
hex2strloop:
	and w6, w7, #0xF				//	current hex digit is last 4 bytes
	cmp w6, #10						//	is current hex digit 0-9 or A-F?
	b.ge	hex2strletter
	add w6, w6, #'0'				//	convert 0-9 to ascii
	b 	hex2strcontinue
hex2strletter:
	add w6, w6, #('A'-10)			//	convert A-F to ascii
hex2strcontinue:
	strb w6, [x8]					//	store ascii-digit in hexstr
	sub x8, x8, #1					//	x8--
	lsr x7, x7, #4					//	x7 <<= 4
	subs w5, w5, #1					//	w5--
	b.ne 	hex2strloop				//	repeat if w5 != 0

	//	Print 'hexstr' (result)
	mov x0, #1						//	1 = stdout
	mov x2, #19						//	len(hexstr)
	mov x16, #4						//	4 = write syscall
	svc 0

	ret

.data
	.align 4
	hexstr: .asciz "0x0000000000000000\n"

