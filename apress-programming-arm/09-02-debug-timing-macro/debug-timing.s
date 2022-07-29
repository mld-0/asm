#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2

#	Register Usage:
#		x9		startTime
#		x10		endTime
#		x11		elapsedTime

.macro		timer_start
	#	push x0-x18, LR
	#	{{{
	stp 	x0, x1, [SP, #-16]!
	stp 	x2, x3, [SP, #-16]!
	stp 	x4, x5, [SP, #-16]!
	stp 	x6, x7, [SP, #-16]!
	stp 	x8, x9, [SP, #-16]!
	stp 	x10, x11, [SP, #-16]!
	stp 	x12, x13, [SP, #-16]!
	stp 	x14, x15, [SP, #-16]!
	stp 	x16, x17, [SP, #-16]!
	stp 	x18, LR, [SP, #-16]!
	#	}}}

	#	startTime = clock()
	bl 	_clock
	mov x9, x0
	adrp 	x1, startTime@PAGE
	add x1, x1, startTime@PAGEOFF
	str x9, [x1]

	#	pop x0-18, LR
	#	{{{
	ldp 	x18, LR, [SP], #16
	ldp 	x16, x17, [SP], #16
	ldp 	x14, x15, [SP], #16
	ldp 	x12, x13, [SP], #16
	ldp 	x10, x11, [SP], #16
	ldp 	x8, x9, [SP], #16
	ldp 	x6, x7, [SP], #16
	ldp 	x4, x5, [SP], #16
	ldp 	x2, x3, [SP], #16
	ldp 	x0, x1, [SP], #16
	#	}}}
.endm

.macro 		timer_elapsed
	#	push x0-18, LR
	#	{{{
	stp 	x0, x1, [SP, #-16]!
	stp 	x2, x3, [SP, #-16]!
	stp 	x4, x5, [SP, #-16]!
	stp 	x6, x7, [SP, #-16]!
	stp 	x8, x9, [SP, #-16]!
	stp 	x10, x11, [SP, #-16]!
	stp 	x12, x13, [SP, #-16]!
	stp 	x14, x15, [SP, #-16]!
	stp 	x16, x17, [SP, #-16]!
	stp 	x18, LR, [SP, #-16]!
	#	}}}

	#	endTime = clock()
	bl 	_clock
	mov x10, x0
	adrp 	x1, endTime@PAGE
	add x1, x1, endTime@PAGEOFF
	str x10, [x1]

	#	elapsedTime = (endTime - startTime) * S_TO_uS / CLOCKS_PER_SEC
	adrp 	x1, startTime@PAGE
	add x1, x1, startTime@PAGEOFF
	ldr x9, [x1]
	sub x11, x10, x9
	adrp 	x0, S_TO_uS@PAGE
	add x0, x0, S_TO_uS@PAGEOFF
	ldr x0, [x0]
	mul x11, x11, x0
	adrp 	x0, CLOCKS_PER_SEC@PAGE
	add x0, x0, CLOCKS_PER_SEC@PAGEOFF
	ldr x0, [x0]
	sdiv x11, x11, x0

	#	printf()
	adrp 	x0, str_print_elapsed@PAGE
	add x0, x0, str_print_elapsed@PAGEOFF
	mov FP, SP
	sub SP, SP, #16
	str x11, [SP]
	bl 	_printf
	mov SP, FP

	#	pop x0-18, LR
	#	{{{
	ldp 	x18, LR, [SP], #16
	ldp 	x16, x17, [SP], #16
	ldp 	x14, x15, [SP], #16
	ldp 	x12, x13, [SP], #16
	ldp 	x10, x11, [SP], #16
	ldp 	x8, x9, [SP], #16
	ldp 	x6, x7, [SP], #16
	ldp 	x4, x5, [SP], #16
	ldp 	x2, x3, [SP], #16
	ldp 	x0, x1, [SP], #16
	#	}}}
.endm


.data
	startTime:			.quad 	0
	.align 4
	endTime:			.quad 	0
	.align 4
	str_print_elapsed:	.asciz 	"elapsed (us): %lu\n"
	.align 4
	CLOCKS_PER_SEC: 	.quad 	1000000
	.align 4
	S_TO_uS: 			.quad 	1000000
	.align 4
.text

