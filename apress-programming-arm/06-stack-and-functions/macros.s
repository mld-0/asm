//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2

//	Macros are an inline alternative to functions:
//	Wherever a macro is called, the assembler replaces that call with a copy of the code from the macro.
//	This reduces the number of (expensive) branching operations versus using regular function calls.

//	There are no standard rules on register usage for macro calls as there is for function calls.

//	Import file containing macro.
//	This effectively inserts the contents of the specified file at this point.
//	Changes to files imported thus do not cause make to rebuild.
.include "toupper-macro.s"
.include "pushpop-macro.s"
.include "hex2str-macro.s"

.global _start 

.align 2

_start:

	//	Call macro 'toupper(instr, outstr, bufferlen)'
	toupper		instr, outstr, #255

	mov x0, #0xFEDC
	mov x1, #0xABCD
	mov x2, #0x1234

	//	Use of PUSH/POP macros
	PUSH1 	x0
	PUSH2 	x1, x2
	mov x0, #0
	mov x1, #0
	mov x2, #0
	POP2	x1, x2
	POP1	x0
	
	//	Call macro 'hex2str(x)'
	hex2str 	x0
	hex2str 	x1
	hex2str 	x2


	//	Write 'donemsg'
	mov x0, #1								//	1 = stdout
	adrp 	x1, donemsg@PAGE
	add x1, x1, donemsg@PAGEOFF
	mov x2, #5								//	5 = len(donemsg)
	mov x16, #4								//	4 = write syscall
	svc 0
	//	macOS 'exit' syscall, return x0
	mov x0, #0
	mov x16, #1
	svc 0

.data
	.align 4
	donemsg: .asciz "Done\n"

	//	Used in macro 'toupper'
	.align 4
	nl: .asciz "\n"

	//	Used in macro 'hex2str'
	.align 4
	hexstr: .asciz "0x0000000000000000\n"

	.align 4
	instr: .asciz "This is our Test STring that wE will convert to upper with a macro"
	.align 4
	outstr: .fill 255, 1, 0

