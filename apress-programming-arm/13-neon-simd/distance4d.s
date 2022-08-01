
.global distance4d
.align 4

distance4d:
	str LR, [SP, #-16]!

	ldp q2, q3, [x0]

	fsub v1.4s, v2.4s, v3.4s
	fmul v1.4s, v1.4s, v1.4s

	faddp v0.4s, v1.4s, v1.4s
	faddp v0.4s, v0.4s, v0.4s

	fsqrt s4, s0
	fmov w0, s4

	ldr LR, [SP], #16
	ret

