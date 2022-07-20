//	{{{3
//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-20T06:18:59AEST asm, reason to prefix a constant '35' with # i.e: '#35'?
//	Ongoing: 2022-07-20T17:29:16AEST (what makes) integer multiplication (much) harder than addition
//	Ongoing: 2022-07-20T17:47:15AEST multiply instructions and overflow/condition flags? (official <32-bit> docs say there is a 'MUL{S}') [...] 'MULS x4, x2, x3' does not assemble [...] 
//	}}}

//	Multiplication:
//	The product of two 64-bit numbers is 128-bits.

//	Lower 64-bits of Multiply Result:
//			MUL 	Xd, Xn, Xm
//	The result 'Xd', is the lower 64-bits of the product (the upper 64-bits is discarded).
//	There is no 'S' equivalent to set conditional flags.
//	<(There are no separate signed/unsigned versions)>

//	Negative of Multiply:
//			MNEG	Xd, Xn, Xm

//	Upper 64-bits of Multiply Result:
//			SMULH	Xd, Xn, Xm			(signed)
//			UMULH	Xd, Xn, Xm			(unsigned)

//	Multiply 32-bit numbers and get 64-bit Result:
//			SMULL	Xd, Wn, Wm			(signed)
//			UMULL	Xd, Wn, Wm			(unsigned)

//	<(Multiply 32-bit numbers and get Negative of 64-bit Result)>
//			SMNEGL	Xd, Wn, Wm			(signed)
//			UMNEGL	Xd, Wn, Wm			(unsigned)

//	Signed vs Unsigned Multiplication:
//	<>


//	Division:
//	64-bit ARM proccessors are required to have integer division (whereas some 32-bit ARM processors did not).
//	<(Integer division is even more problematic than integer multiplication?)>

//	Divide:
//			SDIV	Xd, Xn, Xm			(signed)
//			UDIV	Xd, Xn, Xm			(unsigned)
//	The registers can be all 'X' or all 'W' registers (all 32/64-bit)
//	There is no 'S' equivalent to set conditional flags.
//	Doesn't throw exception for division by zero (incorrectly returns 0)
//	Performs integer division (discards remainder)
//	<(Get remainder with:)> remainder = numerator - (quotient * denominator)

//	Need to use floating-point processor to divide 128-bit numbers

//	Signed vs Unsigned Division:
//	<>


//	macros: 'printf_reg(reg)', 'printf_str(str)'
.include "debug-printf.s"
.global _start
.align 2

_start:
	mov x2, #25
	mov x3, #4
	printf_reg	2
	printf_reg 	3

	//	Multiply: 
	mul x4, x2, x3
	printf_str 	"MUL x4 = x2 * x3"
	printf_reg 	4

	//	Negative of Multiply:
	mneg x4, x2, x3
	printf_str 	"MNEG x4 = x2 * x3"
	printf_reg 	4

	//	Multiply 32-bit numbers and get 64-bit Result:
	smull x4, w2, w3
	printf_str 	"SMULL x4 = w2 * w3"
	printf_reg 	4

	//	Multiply 32-bit numbers and get Negative of 64-bit Result:
	smnegl x4, w2, w3
	printf_str 	"SMNEGL x4 = -w2 * w3"
	printf_reg 	4

	//	Multiple 32-bit unsigned numbers and get 64-bit Result:
	umull x4, w2, w3
	printf_str 	"UMULL x4 = w2 * w3"
	printf_reg 	4

	//	Multiple 32-bit unsigned numbers and get Negative of 64-bit Result:
	umnegl x4, w2, w3
	printf_str 	"UMNEGL x4 = w2 * w3"
	printf_reg 	4
	printf_str 	""

	adrp 	x2, A@PAGE			//	x2 = A
	add x2, x2, A@PAGEOFF
	ldr x2, [x2]
	adrp 	x3, B@PAGE			//	x3 = B
	add x3, x3, B@PAGEOFF
	ldr x3, [x3]
	printf_reg 	2
	printf_reg 	3

	//	Ongoing: 2022-07-20T17:33:12AEST Order (lower/higher-order) of x4/x5?
	//	128-bit (signed) Multiplication Product
	mul 	x4, x2, x3		//	bottom 64-bits
	smulh 	x5, x2, x3		//	top 64-bits
	printf_str "SMULH/MUL (x5,x4) = x2 * x3"
	printf_reg 	5
	printf_reg 	4

	//	128-bit (unsigned) Multiplication Product
	mul 	x4, x2, x3		//	bottom 64-bits
	umulh 	x5, x2, x3		//	top 64-bits
	printf_str "UMULH/MUL (x5,x4) = x2 * x3"
	printf_reg 	5
	printf_reg 	4
	printf_str 	""

	//	Detecting Multiplication <Overflow/?>
	//	<>

	
	mov x2, #100
	mov x3, #4
	printf_reg 	2
	printf_reg	3

	//	Signed Division
	sdiv x4, x2, x3
	printf_str "SDIV x4 = x2 / x3"
	printf_reg 4

	//	Unsigned Division
	udiv x4, x2, x3
	printf_str 	"UDIV x4 = x2 / x3"
	printf_reg 	4

	//	Division by 0
	mov x3, #0
	sdiv x4, x2, x3
	printf_str "SDIV x4 = x2 / 0"
	printf_reg 4
	printf_str ""

	//	Detecting Division-by-0
	//	<>


	//	return 0
	mov x0, #0
	ret

.data:
	.align 4
	donemsg: .ascii "Done\n"

	.align 4
	A: .dword 		0x7812345678
	.align 4
	B: .dword 		0xFABCD12345678901

