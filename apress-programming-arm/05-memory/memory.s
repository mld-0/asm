//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-08T16:56:58AEST 'quad' (8-bytes) is (only) double the length of 'word' (4-bytes)?
//	Ongoing: 2022-07-08T18:32:33AEST Apple Silicon doesn't like 'LDR Xd, =varname' -> what is the correct way to use this instruction (is it (the seemingly in-elegant) adrp/add with PAGE/PAGEOFF?)
//	Ongoing: 2022-07-08T18:36:42AEST to-upper-conversion (still works if we) s/sub/add/, swapping a/A?
//	Ongoing: 2022-07-08T19:19:04AEST get the length of a string (for ascii/asciz)?
//	Ongoing: 2022-07-08T19:20:24AEST where does the '.text' label go (where is it place implicitly)?
//	}}}

//	Memory directives:
//		ascii		string
//		asciz		string with 0-byte terminator
//		double		8-byte float
//		float		4-byte float
//		octa		16-byte integer
//		quad		8-byte integer
//		word		4-byte integer
//		short		2-byte integer
//		byte		1-byte integer
//	<(These are the same for 32/64-bit ARM?)>

//	Byte: decimal, octal, binary, hex, ascii
//		.byte 74, 0112, 0b00101010, 0x4A, 'J', 'H'+2
//	Word: (32bits)
//		.word 0x1234ABCD, -1434
//	Quad: (64bits)
//		.quad 0x123456789ABCDEF0
//	ASCII string: 
//		.ascii "Hello World\n"


//	A constant beginning with '0' is octal, not decimal

//	Prefix operators:
//		Negative (-): Two's complement of integer
//		Complement (~): One's complement of integer

//	Define block of memory:
//		.fill 	repeat, size, value

//	Repeat statement: equivalent to '...' repeated 'count' times
//		.rept count
//		...
//		.endr

//	Align directive: align the next piece of data
//		.align	4
//	Instructions are word (4-byte) aligned

//	ARM64 prevents us manipulating register PC. Loading relative to PC is effectively loading relative to the current instruction. The PC offset used by load is 19-bits, or +/- 1MB.


//	Load:
//		LDR{type} Xt, [Xa]
//		LDR{type} Xt, =varname
//		LDR{type}{cond} Rt, [Rn {, #offset}]		//	immediate offset
//		LDR{type}{cond} Rt, [Rn, #offset]			//	pre-indexed
//		LDR{type}{cond}
//	Where
//		Xt			destination
//		[Xa]		address in Xa 
//		=varname	address of variable
//	type:
//		B		unsigned byte
//		SB 		signed byte
//		H		unsighed halfword
//		SH		signed halfword
//		SW		signed word
//	The signed version will extend the sign across the rest of the register

//	Load address of 'varname' into X1
//		LDR X1, =varname

//	Load 64-bit quantity into register:
//		LDR, X1, =0x1234ABCD1234ABCD
//	(The assembler will turn our value into a variable and load the address of that).

//	<(LDR and Darwin: loading the address of a variable becomes)>
//		ADRP 	X1, varname@PAGE
//		ADD X1, X1, varname@PAGEOFF

//	For variables in the '.text' section
//		ADR X1, varname

//	Loading and offsets:
//		LDR X2, [X1, num]				//	[X1] + num
//		LDR X2, [X1, X3]				//	[X1] + X3
//		LDR X2, [X1, X3, LSL #2]		//	[X1] + (X3 << 2)

//	Pre-indexed addressing:
//		LDR X2, [X1, #(2 * 4)]!			//	Update X1 with address calculated

//	Post-indexed addressing:
//		LDR X2, [X1], #2				//	Use [X1], then add '#2' to it

//	Store:
//		STR{type}{cond} Rt, [Rn {, #offset}]		//	immediate offset
//		STR{type}{cond} Rt, [Rn, #offset]!			//	pre-indexed
//		STR{type}{cond} Rt, [Rn], #offset			//	post-indexed

//	LDRD / STRD are load/store for double-word instructions (these have 2 source/dest registers)

.global _start

.align 2

_start:

	//	Loading address of a variable:
	//ldr x1, =mynumber
	adrp 	x1, mynumber@PAGE
	add x1, x1, mynumber@PAGEOFF
	//	Load value at that address:
	ldr x2, [x1]

	//	Load &myarray[0]:
	adrp 	x1, myarray@PAGE
	add x1, x1, myarray@PAGEOFF
	//	Load myarray[2]
	ldr w2, [x1, #(2 * 4)]
	//	Load myarray[2] using register as offset
	mov x3, #(2 * 4)
	ldr w2, [x1, x3]


	//	Convert instr to upper-case as outstr
	adrp 	x4, instr@PAGE
	add x4, x4, instr@PAGEOFF
	adrp 	x3, outstr@PAGE
	add x3, x3, outstr@PAGEOFF
touploop:
	ldrb w5, [x4], #1
	cmp w5, #'z'			//	skip subtraction if w5 > 'z'
	b.gt toupcont
	cmp w5, #'a'			//	skip subtraction if w5 < 'a'
	b.lt toupcont
	sub w5, w5, #('a'-'A')	//	lower to upper
toupcont:
	strb w5, [x3], #1		//	write w5 to outstr
	cmp w5, #0				//	continue if w5 is not null-byte
	b.ne touploop

	//	Print outstr
	mov x0, #1					//	1 = stdout
	adrp 	x1, outstr@PAGE
	add x1, x1, outstr@PAGEOFF
	sub x2, x3, x1				//	len(outstr)
	mov x16, #4					//	4 = write syscall
	svc 0


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

//	Any variables that need to be modified should be placed in '.data'
.data
	.align 4
	donemsg: .ascii "Done\n"

	.align 4
	mynumber: .quad 0x1234ABCD1234ABCD

	//	array of zeros (10 words, 4-bytes each, value = 0)
	.align 4
	myarray: .FILL 10, 4, 0

	.align 4
	instr: .asciz "This is our Test STring that wE will convert.\n"
	.align 4
	outstr: .fill 255, 1, 0

