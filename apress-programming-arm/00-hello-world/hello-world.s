#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-06-24T02:28:23AEST need to use 'adr' (not 'ldr') (because macOS linker/loader doesn't like doing relocations)
//	Ongoing: 2022-06-24T02:30:35AEST Linux uses '_start', macOS uses '_main'(?)
//	Ongoing: 2022-06-24T01:41:09AEST no '.data' section? [...] (create a data section, as you think it would look, and it works, as you think it would work?)
//	}}}

//	LINK: https://smist08.wordpress.com/2021/01/08/apple-m1-assembly-language-hello-world/

//	ARM64 Registers:
//	{{{
//	General Purpouse (64-bit) (use 'W' for 32-bit registers)
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
//	}}}

//	Move:				
//			mov{S}{cond} Rd, Operand2
//			mov{cond} Rd, #imm16

//	Register-Relative: 	
//	Generate a PC-relative address in 'Rd' for 'label' (must be within limited distance of current instruction).
//			adr{cond}{.W} Rd, label

//	Address of page at PC-relative offset:
//			adrp Xd, label

//	Supervisor (syscall)
//	Causes an exception (switch processor to supervisor mode)
//			svc{cond} #imm


//	Default entry-point is '_main' for macOS, '_start' for Linux
.global _start

//	Must start on 64-bit boundary
.align 2

_start:
	//	1 = stdout
	mov x0, #1

	//	output string
	//	<(can't use ldr?)>
	adr x1, helloworld
	//ldr x1, =helloworld
	//	Ongoing: 2022-07-12T22:27:35AEST use of 'adr x1, helloworld' vs 'adrp x1, helloworld@PAGE; add x1, x1, helloworld@PAGEOFF'? [...] (label used with 'adr' must be in same code section?)

	//	12 = length of string
	mov x2, #12

	//	macOS 'write' syscall
	mov x16, #4
	svc 0

	//	macOS 'exit' syscall, return x0 
	mov x0, #0
	mov x16, #1
	svc 0

.data:
	helloworld: .ascii "Hello World\n"

