//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-08T20:26:27AEST returning 128-bits: (X0,X1) or (X1,X0)?
//	Ongoing: 2022-07-08T20:39:47AEST 'We can save steps if we just use X0–X18 for function parameters, return codes, and short-term work. then we never have to save and restore them around function calls' -> but isn't the point of X19-X30 that we get them back after the function call as we left them? (consider calling 'printf()' with as few pushes/pops as practicable) (are they making the point that a callee must save X19-X30 in order to use them, but does not have to save X0-X18?)
//	Ongoing: 2022-07-09T01:44:28AEST (plz clarify) 'BL' (Branch-with-Link) means 'call function'?
//	Ongoing: 2022-07-09T02:28:41AEST (example <of/for>) saving/restoring registers to/from stack for function call
//	Ongoing: 2022-07-09T13:46:57AEST Frame Pointer vs Stack Pointer
//	Ongoing: 2022-07-09T14:34:37AEST 'sub fp, sp, #16; sub sp, sp, #16' is equivalent to 'sub sp, sp, #16; mov fp, sp'?
//	Ongoing: 2022-07-09T15:00:33AEST when does FP get set? 
//	Ongoing: 2022-07-09T15:02:00AEST does our example need to store LR/FP when it does not call any functions?
//	Ongoing: 2022-07-09T16:02:22AEST what a function should push to the stack (lr, fp) or (fp, ip, lr, pc)?
//	}}}

//	A Stack (LIFO queue) is an area of memory with two operations:
//			Push
//			Pop
//	ARM Requires that SP is always 16-byte aligned - we can only add/subtract multiples of 16.
//	The Stack grows downward. 
//	The Stack Pointer (SP) points to the last element on the stack.

//	Copy single register to stack: (wasting 8-bytes to keep alignment)
//			STR X0, [SP, #-16]!

//	Load value previously stored:
//			LDR X0, [SP], #16

//	It common to use STP/LDP to push/pop two registers at once:
//			STP X0, X1, [SP, #-16]!
//			LDP X0, X1, [SP], #16

//	Calling a function requires resuming execution at the location of the call after returning.
//	This is done with the Link Register (LR), <(X30)>

//	Branch with Link:
//			BL label
//	Used for calling functions, stores address of following instruction in LR.
//	Continue: 2022-07-09T15:31:49AEST what does BL set?

//	Return:
//			RET
//	Resume execution at location in LR.

//	A function that calls other functions must push LR (Link-Register) onto the stack before the call, then pop it back after returning. Even for functions that do not call other functions, this is good practice in-case function calls are added later.
//		myfunc1:	STR LR, [SP, #-16]!		//	push LR
//					BL myfunc2
//					LDR LR, [SP], #16		//	pop LR
//					RET

//	Function Parameters and Return Values: 
//	Caller passes the first 8 parameters as X0-X7. Additional parameters are pushed onto the stack.
//	Return a value using X0, or (X0,X1). Larger values are returned as a memory address in X0.
//	ARM places variadic arguments on the stack.

//	Managing Registers:
//			X0-X18		Caller should save if used (Call-clobberd)
//			X19-X30		Callee should save if used (Call-preserved)
//			SP			Callee must perform the same number of pushes and pops
//			LR			Callee must save if it calls any other functions
//			NZCV		Undefined after returning
//	Apple Silicon: Do not use X18

//	Calling function in another source file:
//		Make function label available as '.global'
//		<Compile> each source as an *.o object file
//		Use both object files to build the executable.


//	Stack Frames:
//	Pushing variables onto the stack is problematic, since they are not accessed in LIFO order.
//	Instead we update the stack pointer to allocate/release space for our local variables. 
//	(SP must always be 16-byte aligned).
//			SUB SP, SP, #16
//			STR W0, [SP]
//			STR W1, [SP, #4]
//			STR W2, [SP, #8]
//			...
//			ADD SP, SP, #16
//	A function must restore SP to its original state before returning.


//	Frame Pointer (FP) X29
//	SP may change during the execution of a function, meaning the offset from SP at which variables are located can change.
//	FP is used to store the value of SP just before a function is called. It does not change as the function is executing, allowing the same offsets to be used to locate the same variables even as SP changes. 
//	<(Use of FP is optional)>, <(The callee is responsible for saving FP (X19-X30) (before calling another function))>
//	<(SP = where local data is, FP = where last local data is)>
//	<(When using FP, push it at the beginning of the function and pop it at the end)>
//			SUB FP, SP, #16
//	<(FP contains (because we put it there) the SP for the function, (after we have saved our registers to the stack, but before we grow the stack in the function for local variables?))>
//	<(Current scope is everything between SP and FP inclusive?)>



//	'.equ' directive:
//			.equ varname, <value>
//	Defines a variable that can be used as '#varname'.
//	Instances of this variable will have their value substituted by the assembler.


//	In ARM, it is legal to set PC to return address instead of returning:
//			MOV PC, LR

.global _start

.align 2

_start:

	//	Call 'toupper(instr, outstr)'
	adrp 	x0, instr@PAGE
	add x0, x0, instr@PAGEOFF
	adrp 	x1, outstr@PAGE
	add x1, x1, outstr@PAGEOFF
	mov x2, #255			//	max_len(outstr)
	bl 		toupper

	
	//	Call 'hex2str(x0, hexstr)
	mov x0,  #0xABCD
	movk x0, #0x1234, LSL #16
	movk x0, #0xABCD, LSL #32
	movk x0, #0x1234, LSL #48
	bl 		hex2str


	//	Store variables on stack using SP
	sub sp, sp, #16
	str x0, [sp]
	str x1, [sp, #8]
	add sp, sp, #16


	//	Call 'framepointer()'
	bl 		framepointer


	//	Example: Callee saved variables
	//	<>


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

	.align 4
	instr: .asciz "This is our Test STring that wE will convert to upper"
	.align 4
	outstr: .fill 255, 1, 0

