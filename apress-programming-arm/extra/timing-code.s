#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-29T03:30:43AEST Why it causes a setfault to close with 'ret' (instead of 'x16=1; svc 0') after calling 'clock()'?
//	}}}

.include "debug-printf.s"
.global _start
.align 4

//	Uses C function 'clock()' - result is (process) CPU time (does not record 'sleep(1)')
//	<('CLOCKS_PER_SEC' is defined as 1000000?)>

//	Registers:
//		x19	= startTime
//		x20 = endTime
//		x21 = elapsedTime

_start:

	//	x19 = clock()
	stp 	x18, LR, [SP, #-16]!
	bl 		_clock
	ldp 	x18, LR, [SP], #16
	mov x19, x0


	//	for x0 in range(LOOP_N, 0, -1)
	adrp 	x1, LOOP_N@PAGE
	add x1, x1, LOOP_N@PAGEOFF
	ldr x0, [x1]
L1:
	subs x0, x0, #1
	b.ne 	L1


	//	x20 = clock()
	stp 	x18, LR, [SP, #-16]!
	bl 	_clock
	ldp 	x18, LR, [SP], #16
	mov x20, x0


	//	x21 = (x20 - x19) * S_TO_uS / CLOCKS_PER_SEC
	sub x21, x20, x19
	adrp 	x0, S_TO_uS@PAGE
	add x0, x0, S_TO_uS@PAGEOFF
	ldr x0, [x0]
	mul x21, x21, x0
	adrp 	x0, CLOCKS_PER_SEC@PAGE
	add x0, x0, CLOCKS_PER_SEC@PAGEOFF
	ldr x0, [x0]
	sdiv x21, x21, x0
	mov x0, x21
	printf_str "Elapsed: (us)"
	printf_reg 	0

done:
	printf_str "Done"
	mov x0, #0
	//ret						//	segfault?
	mov x16, #1
	svc 0


.data
	.align 4
	LOOP_N: 	.quad 	500000000

	.align 4
	CLOCKS_PER_SEC: .quad 	 1000000

	.align 4
	S_TO_uS: 	.quad 	1000000

