//	As taken from: 06-01-stack-and-functions/toupper.s

//	Usage: 'extern int mytoupper(char*, char*, int)'
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
//		x0			length of converted string (including null byte)

//	We prefix the function name with '_' to enable it to be found by C-on-Darwin.
.global _mytoupper 

//	Ongoing: 2022-08-07T23:29:26AEST book uses '.p2align'?
.p2align 2

_mytoupper:
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
	sub	x8, x4, x1  			//	length of result placed in x8
	mov x0, x8					//	Return length of result
	ret	

