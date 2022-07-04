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
//	TODO: 2022-07-04T15:57:33AEST output register result values (hex/decimal)

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
//			MOVK XD, #imm16{, LSL #shift}
//			MOV XD, #imm16{, LSL #shift}
//			MOV XD, XS
//			MOV XD, operand2
//			MOVN XD, operand2
//			<(MOVZ?)>



//	Carry flag: <(set when the result of an integer operation overflows (and we are using a supported instruction))>
//	Barrel shifter: allows shifts to be applied to instruction Operand2 (before it is loaded)

//	Shifting and Rotating:
//	n left shifts is equivalent to multiplication by 2**n
//	n right shifts is equivalent to division by 2**n

//	0000 0011 << 3 = 0001 1000

//	logical shift left LSL
//	zeros come in from the right, last bit shifted out becomes the carry flag
//	multiply by 2**n

//	logical shift right LSR
//	zeros come in from the left, last bit shifted out becomes the carry flag
//	unsigned division by 2**n

//	arithmetic shift right ASR
//	one comes in from the left if the number is negative, zero if it is positive
//	signed division by 2**n

//	rotate right ROR
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



//	Add:
//	ADD{S} Xd, Xs, Operand2
//			S				set condition flags
//			Xd				destination register
//			Xs				source register
//	Operand2:
//			X2, LSL #1		Register and a shift
//			X2, SXTB 2		Register and an extension operand

//	Add-with-carry:
//			ADC{S} Xd, Xs, Operand2
//	Add values, then add value of carry flag
//	Used to synthesize multi-word arithmetic

//	Subtract:
//			SUB{S} Xd, Xs, Operand2

//	Subtract-with-carry:
//			SUBC{S} Xd, X2, Operand2
//	Subtract values, then subtract value of carry flag
//	Used to synthesize multi-word arithmetic


.global _start

.align 2

_start:

//	Loading and Shifting:

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


//	Addition and Subtraction:

	//	add x1 + x2
	mov x1, #1
	mov x2, #2
	add x1, x1, x2

	//	128-bit addition: (x0,x1) = (x2,x3) + (x4,x5)
	mov x2, #0x0000000000000003
	mov x3, #0xFFFFFFFFFFFFFFFF
	mov x4, #0x0000000000000005
	mov x5, #0x0000000000000001
	//	add lower order bits
	adds x1, x3, x5
	//	add higher order bits
	adc x0, x2, x4


	//	subtract x1 - x2
	mov x1, #4
	mov x2, #1
	sub x1, x1, x2

	//	128-bit subtraction: (x0,x1) = (x2,x3) - (x4,x5)
	mov x2, #0x0000000000000005
	mov x3, #0x0000000000000001
	mov x4, #0x0000000000000003
	mov x5, #0xFFFFFFFFFFFFFFFF
	//	subtract
	subs x1, x3, x5
	sbc x0, x2, x4
	//	Ongoing: 2022-07-04T16:00:50AEST 128bit subtraction is correct?


	//	Continue: 2022-07-02T12:34:22AEST (using ch03 debugger material) run (step-through) examples, displaying register values (hex/decimal)
	//	<>


	//	Write 'donemsg'
	mov x0, #1			//	1 = stdout
	adr x1, donemsg
	mov x2, #5			//	5 = len(donemsg)
	mov x16, #4			//	4 = write syscall
	svc 0

	//	macOS 'exit' syscall, return x0
	mov x0, #0
	mov x16, #1
	svc 0

.data:
	donemsg: .ascii "Done\n"

