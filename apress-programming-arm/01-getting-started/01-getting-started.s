#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2

//	CISC and RISC:
//	<(Practically everything written about CISC vs RISC is an oversimplification)>
//	<(CISC <is/has-become> a catch-all term for any architecture that is not load-store (register-memory/<others?>))>
//	<(Most modern processors can be considered CISC/RISC hybrids)>
//	Examples of 'complex' instructions include:
//			transferring multiple registers to/from memory at once
//			moving large blocks of memory
//			complex int/float functions: sqrt, log, sin, ect.
//			SIMD
//			atomic operations: test-and-set, read-modify-write, ect.
//			ALU operations on memory

//	Assembly is tightly coupled to a given CPU

//	Hex and Binary:
//	{{{
//		0	0		0000
//		1	1		0001
//		2	2		0010
//		3	3		0011
//		4	4		0100
//		5	5		0101
//		6	6		0110
//		7	7		0111
//		8	8		1000
//		9	9		1001
//		A	10		1010
//		B	11		1011
//		C	12		1100
//		D	13		1101
//		E	14		1110
//		F	15		1111
//	}}}

//	ARM64: memory-addresses / registers are 64 bits

//	ARM instructions are all 32 bits
//	Data processing instructions:
//			31			bits (W/X flag)
//			30			opcode
//			29			set condition code
//			28-24		opcode
//			23-22		shift
//			21			0
//			20-16		Rm (input register1)
//			15-10		imm6
//			9-5			Rn (input register 2)
//			4-0			Rd (destination register)

//	For both 32/64 bit ARM:
//	half-word			16 bits / 2 bytes
//	word  				32 bits / 4 bytes
//	double word 		64 bits / 8 bytes

//	ARM is a load-store architecture: Instructions are performed only on registers.
//	There are two basic kinds of instructions: load/store, and logical/arithmetic

//	ARM has various techniques for handling 64bit memory addresses despite only having 32bit instructions
//		Loads can be done relative to the PC (12bits offset allowed)
//		Loads can be done from an address in a register
//		(See ch2 for more)

//	Registers (Apple specific):
//	General Purpouse (64-bit) (use 'W' for 32-bit registers)
//	X/W registers cannot be mixed in a single instruction
//		X0-X7		parameters/results
//		X8			indirect result location
//		X9-X15		temporary 
//		X16			(IP0) intra-procedure-call temp (syscalls)
//		X17			(IP1) intra-procedure-call temp (syscalls?)
//		X18			(reserved) platform register
//		X19-X28		callee-saved regsiters
//		X29			(FP) frame pointer
//		X30			(LR) link register
//	Special
//		SP			stack pointer
//		PC			program counter (address of current instruction)
//		NZCV		global condition flag 
//		FPSR		floating point status
//		FPCR		floating point control
//		XZR			zero
//	Floating-point/SIMD
//		D0-D7		argument/result values
//		D8-D15		preserved across calls
//		D16-D31		temporary


//	Classic RISC Pipeline: fetch, decode, execute, memory-access, writeback

//	Format of an assembly instruction:
//			label:	opcode operands
//	label - optional, used to jump to instruction
//	opcode - eg, ADD / LDR / B
//	operands - <(Specify register(s) / immediate value)>

//	Assembly uses the same comments as C/C++: '//' and '/**/'

//	Conditional flags: NZCV
//		N	Negative:			1 if signed value is negative
//		Z	Zero:				1 if result is 0 (denote equal comparison)
//		C	Carry:				1 if addition overflowed / subtraction requires borrow, or value of last bit shifted out
//		V	Overflow:			1 if signed addition / subtraction overflow occured, or an error condition
//	Only set by instructions appended with 'S'
//	<(Accessed through OS privileged instructions. User mode programs do not directly access the register)>

