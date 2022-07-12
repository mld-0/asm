//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2

.global framepointer

.align 2

//	{{{
//fpexample:
	//	Continue: 2022-07-09T14:59:09AEST Example use of FP
	//	{{{
	//.equ var1, 0
	//.equ var2, -8
	//.equ sum, -12
	//stp lr, fp, [sp, #-16]!					//	store LR, FP on stack
	//sub sp, sp, #32							//	grow stack 16-bytes
	////mov fp, sp								//	<(update FP?)>
	//add x2, x0, x1
	//str x0, [fp, #var1]
	//str x1, [fp, #var2]
	//str x2, [fp, #sum]
	////ldr x0, [fp, #sum]
	//ldr x0, [sp, 
	//add sp, sp, #32							//	decrease stack 16-bytes
	//ldp lr, fp, [sp], #16					//	restore LR, FP from stack
	//	}}}
	//	{{{
	//mov fp, sp
	//stp lr, fp, [sp, #-16]!
	//#sub fp, sp, #16
	//sub sp, sp, #16
	////mov x0, sp
	////bl 		hex2str
	////mov x0, fp
	////bl 		hex2str
	//mov x0, fp
	//bl 		hex2str
	//mov x0, sp
	//bl 		hex2str
	//add x2, x0, x1
	//str x0, [sp, #0]
	//str x1, [sp, #-8]
	//str x2, [sp, #-16]
	//add sp, sp, #16
	//ldp lr, fp, [sp], #16
	//	}}}
	//	LINK: https://bob.cs.sonoma.edu/IntroCompOrg-RPi/sec-stack-manage.html
	//	LINK: https://www.youtube.com/watch?v=7fezHk7nmzY
	//	{{{
	//sub sp, sp, #16					//	store FP/LR on stack
	//str fp, [sp, #0]				//	[SP] = old FP 
	//str lr, [sp, #8]
	//add fp, sp, #8					//	FP = start of saved registers
	//sub sp, sp, #32
	//add x2, x0, x1
	//str x0, [fp, #-16]	//	[sp, #24]
	//str x1, [fp, #-24]	//	[sp, #16]
	//str x2, [fp, #-32]	//	[sp, #8]
	//add sp, sp, #32
	//ldr fp, [sp, #0]
	//ldr lr, [sp, #8]
	//add sp, sp, #16
	//ret
	//	}}}
//	}}}
framepointer:
	mov x0, #5
	mov x1, #7

	sub sp, sp, #16		//	Store fp/lr on stack
	str fp, [sp, #0]
	str lr, [sp, #8]

	mov fp, sp			//	FP points to old-SP (SP once FP/LR have been saved)

	sub sp, sp, #32
	add x2, x0, x1

	str x0, [sp, #0]	//	[fp, #-32]
	str x1, [sp, #8]	//	[fp, #-24]
	str x2, [sp, #16]	//	[fp, #-16]

	ldr x0, [fp, #-32]	//	[sp, #0]
	ldr x1, [fp, #-24]	//	[sp, #8]
	ldr x2, [fp, #-16]	//	[sp, #16]

	mov sp, fp
	ldr fp, [sp, #0]
	ldr lr, [sp, #8]
	add sp, sp, #16
	ret

.data 
	.align 4
	nl: .asciz "\n"

