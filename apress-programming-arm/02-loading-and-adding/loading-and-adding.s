//   vim: set tabstop=4 modeline modelines=10:
//   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-06-28T04:04:04AEST (how hard is it to) get 'donemsg' length (in order to put it into 'x2' instead of using const '#5')
//	Ongoing: 2022-07-01T22:48:15AEST no arithmetic-shift/rotate left? (arithmetic-shift left not applicable), (rotate left should be a thing?)
//	Ongoing: 2022-07-02T11:22:01AEST (loading into X2) Use (ascending) (more readable) example value? '0x0123456789ABCDEF'(?)
//	Ongoing: 2022-07-02T12:12:01AEST (if the problem (with shift versions of MOV) is with clang) (compile assembly for macOS-on-ARM with gnu-gcc?)
//	}}}

//	Two's Complement
//	The N-bit representation of -n in binary is: 2**N - n
//		-1 = 2**8 - 1 = 255 = 0xFF
//	Alternatively, flip the bits and add 1.
//	<(The max positive value of an N-bit signed number is 2**(N-1)?)>

//	One's Complement
//	Flip the bits (without adding 1).

//	Big Endian: 		MSB -> LSB
//	Little Endian: 		LSB -> MSB
//	ARM/x86 are (bi) little-endian. TCP/IP uses big-endian.
//	Little-endian allows easy conversion between integer sizes (1st byte of an int becomes only bytes of a short).

//	'MOV' is an alias. 'MOV X0, X1' is implemented as 'ORR X0, XZR, X1'

//	Forms of MOV:
//			MOVK XD, #imm16{, LSL, #shift}
//			MOV XD, #imm16{, LSL, #shift}
//			MOV XD, XS
//			MOV XD, operand2
//			MOVN XD, operand2
//			<(MOVZ?)>



//	Carry flag: <(set when the result of an integer operation overflows)>
//	Barrel shifter: allows shifts to be applied to instruction Operand2 (before it is loaded)

//	Shifting and Rotating:
//	n left shifts is equivalent to multiplication by 2**n
//	n right shifts is equivalent to division by 2**n

//	0000 0011 << 3 = 0001 1000

//	logical shift left
//	zeros come in from the right, last bit shifted out becomes the carry flag
//	multiply by 2**n

//	logical shift right
//	zeros come in from the left, last bit shifted out becomes the carry flag
//	unsigned division by 2**n

//	arithmetic shift right
//	one comes in from the left if the number is negative, zero if it is positive
//	signed division by 2**n

//	rotate right
//	bits that leave on the right reappear on the left

//	rotate left
//	<(not available? (almost?) any rotate left can be performed using rotate right?)>


//	Ongoing: 2022-07-02T12:16:49AEST why no rotate left? (other rotate commands?)
//	Shifts Codes:
//		LSL		logical-shift-left
//		LSR		logical-shift-right
//		ASR		arithemtic-shift-right
//		ROR		rotate-right
//		<>
//		RRX		rotate-right-extend

//	Command								Is an alias for:
//	LSL X1, X2, #1 			->			MOV X1, X2, LSL #1
//	LSR X1, X2, #1			->			MOV X1, X2, LSR #1
//	ASR X1, X2, #1			->			MOV X1, X2, ASR #1
//	ROR X1, X2, #1			->			MOV X1, X2, ROR #1
//	(And clang does not support the later?)

//	Register and extension:
//	extract byte / halfword (2-bytes) / word (4-bytes)
//	zero or sign extend
//	shift left 0-4 bits
//			uxtb				unsigned-extended byte
//			uxth				unsigned-extended halfword
//			uxtw				unsigned-extended word
//			sxtb				sign-extended byte
//			sxth				sign-extended halfword
//			sxtw				sign-extended word
//	(word not available for 32-bit W registers)
//	<(available with MOV or not?)>

//	MOV: register-to-register-move
//			MOV Xd, Operand2
//	Where
//			Xd				destination register
//	Formats of Operand2
//			X2, LSL #1			Register and a shift
//			<>					Register and an extension operantion <(not available for MOV?)>
//			<>					Small number and a shift

//	Some numbers larger than 16-bits can be rotated by the assembler, that is:
//			MOV X1, #0xAB000000
//	becomes
//			MOV x1, #xAB00, LSL #16
//	However, this does not work for all numbers:
//			MOV X1, #0xABCDEF11
//	fails

//	MOVK: move-keep
//			MOVK Xd, #imm16{, LSL, #shift}
//	loads the 16-bit intermediate into 1-of-4 positions in a register without disturbing the other 48-bits
//	(When using 'MOV', other 48-bits are zeroed)
//			#imm16			16-bit unsigned [0,65535]
//			LSL				logical-shift-left
//			#shift			amount to shift left (allowed: 0,16,32,48)
//			Xd				destination register

//	MOVN: move-not
//	Loads the logical-not of the value that the equivalent move would load.


.global _start

.align 2

_start:

	//	load 0x1234FEDC4F5D6E3A into X2: 
	mov x2,  #0x6E3A
	movk x2, #0x4F5D, LSL #16
	movk x2, #0xFEDC, LSL #32
	movk x2, #0x1234, LSL #48

	//	move w2 into w1
	mov w1, w2

	//	<(all?)> shift versions of MOV
	//	error for shift versions of MOV? (unsupported by clang?)
	//mov x1, x2, LSL #1
	//mov x1, x2, LSR #1
	//mov x1, x2, ASR #1
	//mov x1, x2, ROR #1
	//	Instead use:
	lsl x1, x2, #1
	lsr x1, x2, #1
	asr x1, x2, #1
	ror x1, x2, #1

	//	If the immediate value can be created by shifting a 16-bit number, the assembler will make that subsitution
	//	Ongoing: 2022-07-02T12:22:26AEST (assembler will not make subsitution?)
	mov x1, #0xAB000000

	//	Error, cannot be used:
	//mov x1, #0xAB000001

	//	load !0x1234 <(0xFFFFFFFFFFFFEDCB?)>
	movn x1, #0x1234

	//	Assembler will replace with MOVN(?)
	mov w1, #0xFFFFFFFE

	//	Example: <(shifting value into <overflow/carry> register)>
	//	<>

	//	Example: <(left-rotate as right-rotate)>
	//	<>



	//	Continue: 2022-07-02T12:33:54AEST ADD/ADC, SUB/SBC
	//	Continue: 2022-07-02T12:34:22AEST (using ch03 debugger material) run (step-through) example, displaying register values



	//	Write 'donemsg'
	mov x0, #1			//	1 = stdout
	adr x1, donemsg
	mov x2, #5			//	5 = len(donemsg)
	mov x16, #4			//	4 = write syscall
	svc 0

	//	macOS 'exit' syscall
	mov x0, #0
	mov x16, #1
	svc 0

.data:
	donemsg: .ascii "Done\n"

