//	{{{3
//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-19T22:53:46AEST (cleaner) (more explicit/consistent) pushing/popping [...] (make clear how to pass variables on the stack of a variadic function) ... (printing a range of memory?) 
//	Ongoing: 2022-07-19T22:54:54AEST what do we have to do to make '_printf()' available? [...] what other functions are available?
//	}}}

//	'_printf' takes the address of a string as x0. The remaining arguments are variatic. 
//	On Apple Silicon (Darwin), variatic arguments are passed, 8-byte-aligned, on the stack.

.text
.align 2
.global _start
_start:

printf_teststr:
	stp FP, LR, [SP, #-16]!			//	push FP, LR

	adrp 	x0, teststr@PAGE		//	x0 = &teststr
	add x0, x0, teststr@PAGEOFF
	mov x10, #65					//	65 = 'a'
	mov x2, #1234
	mov x3, #2845

	mov FP, SP						//	save arguments on stack
	sub SP, SP, #32
	str x10, [SP, #0]				//	[FP, #-32]
	str x2,  [SP, #8]				//	[FP, #-24]
	str x3,  [SP, #16]				//	[FP, #-16]

	bl 	_printf

	mov SP, FP						//	restore stack

	ldp FP, LR, [SP], #16			//	pop FP, LR
	

printf_nl:
	adrp 	x0, charcode@PAGE
	add x0, x0, charcode@PAGEOFF
	mov x1, #0x0a					//	0x0a = '\n'
	mov FP, SP
	sub SP, SP, #-16
	str x1, [SP]
	bl 	_printf
	mov SP, FP


exit_done:
	//	Write 'donemsg'
	mov x0, #1						//	1 = stdout
	adr x1, donemsg
	mov x2, #5						//	5 = len(donemsg)
	mov x16, #4						//	4 = write syscall
	svc 0

	//	macOS 'exit' syscall, return x0
	//	<(return is limited to 0-255?)>
	mov x0, #0
	mov x16, #1
	svc 0

.data:
	.align 4
	donemsg: .ascii "Done\n"
	.align 4
	teststr: .asciz "Hello (printf) World, c=(%c), ld=(%ld), ld=(%ld)\n"
	.align 4
	charcode: .asciz "(%c)\n"

