//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	{{{
//	Ongoing: 2022-07-09T02:48:13AEST we use max size of output buffer instead of max size of input buffer for 'x2' (on the presumption it's better to read bad memory than to write to bad memory) -> what to C-string functions do?
//	Ongoing: 2022-07-09T02:53:54AEST regarding counter for bounds checking: is it <cheaper/better> to keep a counter, or to find our position as a difference between pointers each time?
//	}}}

//	Convert an ASCII null-terminated string to upper case
//	Arguments:
//		x0			pointer into input string
//		x1			pointer into output string
//		x2			buffer max len 
//	Registers:
//		x4			output string pointer
//		w5			current character
//		x6			loop count
//		x7			input string pointer 
//		x8			length of converted string
//	Returns:
//		x0			length of converted string

.global toupper 

.align 2

toupper:
	mov x4, x1
	mov x7, x0
	mov x6, #0					//	initalize counter
toupperloop:
	ldrb w5, [x7], #1			//	w5 = [x7]++
	cmp w5, #'z'				//	skip conversion if not lower
	b.gt 	toupcontinue
	cmp w5, #'a'				//	skip conversion if not lower
	b.lt 	toupcontinue
	sub w5, w5, #('a'-'A')		//	convert to uppercase
toupcontinue:
	cmp x6, x2 					//	break if x6 >= x2
	b.ge 	toupbreak
	strb w5, [x4], #1			//	[x4]++ = w5
	add x6, x6, #1				//	x6++
	cmp w5, #0					//	continue if w5 is not null-byte
	b.ne 	toupperloop
toupbreak:
	sub	x0, x4, x1  			//	Return length of result in x0
	ret	

.data
	.align 4
	nl: .asciz "\n"

