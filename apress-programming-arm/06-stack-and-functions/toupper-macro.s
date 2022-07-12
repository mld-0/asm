//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2

//	Define a macro:
//			.macro 	name arg1, arg2, ...
//			...
//			.endm

//	Use the arguments by prefixing them with '\'
//	What ever is passed as argument must be valid as used in macro when substituted for '\arg'


//	Numeric label can be defined repeatedly (allowing them to be used in macros).
//	To ensure the correct numeric label is used by our macro, we prefix them in branch calls with 'f' / 'b'

//	Next label '2' in forward direction
//	B.GT	2f

//	Next label '1' in backwards direction
//	B.NE	1b


//	Convert an ASCII null-terminated string to upper case
//	Requires 'nl' (newline as asciz string) be defined
//	Arguments:
//		x0 = instr			pointer into input string
//		x1 = outstr			pointer into output string
//		x2 = bufferlen		buffer max len 
//	Registers:
//		x4					output string pointer
//		w5					current character
//		x6					loop count
//		x7					input string pointer 
//		x8					length of converted string
//	Returns:
//		x0					length of converted string

.macro 		toupper			instr, outstr, bufferlen
	adrp 	x0, \instr@PAGE
	add x0, x0, \instr@PAGEOFF
	adrp 	x1, \outstr@PAGE
	add x1, x1, \outstr@PAGEOFF
	mov x2, \bufferlen

	mov x4, x1
	mov x7, x0
	mov x6, #0					//	initalize counter
1:	//	(toupperloop)
	ldrb w5, [x7], #1			//	w5 = [x7]++
	cmp w5, #'z'				//	skip conversion if not lower
	b.gt 	2f
	cmp w5, #'a'				//	skip conversion if not lower
	b.lt 	2f
	sub w5, w5, #('a'-'A')		//	convert to uppercase

2:	//	(toupcontinue)
	cmp x6, x2 					//	break if x6 >= x2
	b.ge 	3f
	strb w5, [x4], #1			//	[x4]++ = w5
	add x6, x6, #1				//	x6++
	cmp w5, #0					//	continue if w5 is not null-byte
	b.ne 	1b

3:	//	(toupbreak)
	sub	x8, x4, x1  			//	length of string placed in x8

	//	Print 'outstr' (result)
	mov x2, x8 					//	len(outstr)
	mov x0, #1					//	1 = stdout
	mov x16, #4					//	4 = write syscall
	svc 0

	//	Print newline:
	mov x0, #1					//	1 = stdout
	adrp 	x1, nl@PAGE
	add x1, x1, nl@PAGEOFF
	mov x2, #1					//	len(outstr)
	mov x16, #4					//	4 = write syscall
	svc 0

	mov x0, x8					//	Return length of string placed in x0
.endm

