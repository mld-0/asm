#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
#	Ongoings:
#	{{{
#	Ongoing: 2022-07-30T00:50:38AEST does ARM not provide a shorter way to calculate the hypotenuse (of 4 floats) than (see below) 6 instructions?
#	Ongoing: 2022-07-30T00:51:55AEST ARM macros, pragma-once (book must have something to say about importing debug-printf (macros)?)
#	}}}

.global distance_f, distance_d

.align 2

//	Calculate length between points. '_f' uses floats, '_d' uses doubles.
//	Arguments:
//		x0			pointer to 4 (float/double) values: (x1,y1, x2,y2) 
//	Returns:
//		w0/x0		length (hypotenuse)
//	Registers:
//		s1,s2 = (x1,y1)
//		s3,s4 = (x2,y2)

distance_f: 	#	32-bit (float) input/output
	str LR, [SP, #-16]!

	ldp s0, s1, [x0]							//	s0,s1 = (x1,y1)
	ldp s2, s3, [x0, #8]						//	s2,s3 = (x2,y2)

	fsub s4, s2, s0
	fsub s5, s3, s1
	fmul s4, s4, s4
	fmul s5, s5, s5
	fadd s4, s4, s5
	fsqrt s4, s4

	fmov w0, s4

	ldr LR, [SP], #16
	ret

distance_d: 	#	64-bit (double) input/output 
	str LR, [SP, #-16]!

	ldp d0, d1, [x0]
	ldp d2, d3, [x0, #16]

	fsub d4, d2, d0
	fsub d5, d3, d1
	fmul d4, d4, d4
	fmul d5, d5, d5
	fadd d4, d4, d5
	fsqrt d4, d4

	fmov x0, d4

	ldr LR, [SP], #16
	ret

.data

