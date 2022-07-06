#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-05T00:00:03AEST when must be use a '*S' instruction in order to branch with the result?
//	}}}

//	Compare:					Equivalent to:
//	CMP Xn, Operand2 			SUBS XZR, Xn, Operand2

//	Compare using Addition		<(Equivalent to)>:
//	CMN Xn, Operand2			<(ADDS XZR, Xn, Operand2)>

//	Compare using And			<(Equivalent to)>:
//	TST Xn, Operand2			<(?)>

//	Unconditional branch: goto
//			B label
//	label (26-bits) is interpreted as an offset from PC

//	Closed loop branch (infinite loop):
//	label:	
//		mov x1, #1
//		B label 

//	Branch on condition:
//			B.{condition} label

//	Condition flags: NZCV 
//	Only updated by instructions appended with 'S'
//			N	negative	1 if signed value is negative
//			Z	zero		1 if result is 0 (denote equal comparison)
//			C	carry		1 if addition overflows / subtraction does not require borrow, or last bit shifted out
//			V	overflow	1 if signed overflow occurs, or error condition

//	Branch conditional codes:
//			EQ				Z set							==
//			NE				Z clear							!=
//			CS or HS		C set							unsigned >=
//			CC or LO		C clear							unsiged <
//			MI				N set							-ive
//			PL				N clear							+ive or 0
//			VS				V set							overflow
//			VC				V clear							no overflow
//			HI				C set and Z clear				unsigned >
//			LS				C clear and Z set				unsigned <=
//			GE				N and V the same				signed >=
//			LT				N and V differ					signed <
//			GT				Z clear, N and V the same		signed >
//			LE				N set, N and V differ			signed <=
//			AL				Any								always

//	Branch if w4 == 45:
//	cmp w4, #45
//	B.EQ label


//	Bitwise And:
//		AND{S} Xd, Xs, Operand2
//	Bitwise Exclusive-Or:
//		EOR{S} Xd, Xs, Operand2
//	Bitwise Or:
//		ORR{S} Xd, Xs, Operand2
//	And Not (bit-clear):
//		BIC{S} Xd, Xs, Operand2


//	Expresions in immediate constants:
//	add w6, w6, #('A'-10)



.global _start

.align 2

_start:

	//	for w2 in range(1, 10): ...
	mov w2, #1
loop1: 
	//	...
	add w2, w2, #1
	cmp w2, #10
	b.lt loop1

	//	for w2 in range(10, 0, -1):
	mov w2, #10
loop2:
	//	...
	subs w2, w2, #1
	b.ne loop2

	//	while w8 < 5: ...
	mov w8, #0
loop3:
	//	...
	add w8, w8, #1
	cmp w8, #5
	b.ge loop3done
	b loop3
loop3done:


	//	If / then / else:
	mov w5, #3
	//	if w5 < 10
	cmp w5, #10
	b.ge else
	//	... if true statements ...
else:
	//	... else statements ...
endif:	


	//	Example: register (x4) hexvalue to string 
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

	
	//	Continue: 2022-07-06T23:39:36AEST switch statement

	
	//	Write 'donemsg'
	mov x0, #1			//	1 = stdout
	adrp 	x1, donemsg@PAGE
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
	hexformat: .ascii "0x%016lX\n"

	.align 4
	donemsg: .ascii "Done\n"

