//	{{{3
//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2

//	See 'HelloSilicon' example on calling _printf

.text
.global _start

.align 2

_start:
	stp FP, LR, [SP, #-16]!			//	push FP, LR

	adrp 	x0, str_printf@PAGE		//	x0 = &str_printf
	add x0, x0, str_printf@PAGEOFF

	mov x2, #4711
	mov x3, #2845
	mov x10, #65

	//	Ongoing: 2022-07-19T22:53:46AEST (cleaner) (more explicit/consistent) pushing/popping [...] (make clear how to pass variables on the stack of a variadic function) ... (printing a range of memory?) 
	str x10, [SP, #-32]!
	str x2, [SP, #8]
	str x3, [SP, #16]

	//	Ongoing: 2022-07-19T22:54:54AEST what do we have to do 
	bl _printf

	add SP, SP, #32					

	ldp FP, LR, [SP], #16			//	pop FP, LR
	


	//	Use _printf to print a single character (newline)
	//	<>


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
	str_printf: .asciz "Hello (printf) World, c=(%c), ld=(%ld), ld=(%ld)\n"

