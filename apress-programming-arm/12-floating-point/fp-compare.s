#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2

.global fp_compare_f, fp_compare_d

.align 2

//	Determine whether abs(num1-num2) < e. '_f' uses floats, '_d' uses doubles.
//	Arguments:
//			x0 = pointer to 3 FP numbers (num1,num2,e)
//	Returns:
//			x0 = 1 if x1==x2 otherwise 0
//	Registers:
//			s0,s1,s2 = num1,num2,e

fp_compare_f:
	ldp s0, s1, [x0]	
	ldr s2, [x0, #8]

	fsub s3, s1, s0 		//	s3 = abs(x2 - x1)
	fabs s3, s3
	fcmp s3, s2
	b.le	1f				//	if <(?)>, return 0

	mov x0, #0				//	otherwise return 1
	b		2f
1: 	mov x0, #1
2:	ret

fp_compare_d:
	ldp d0, d1, [x0]	
	ldr d2, [x0, #16]

	fsub d3, d1, d0 		//	s3 = abs(x2 - x1)
	fabs d3, d3
	fcmp d3, d2

	b.le	1f				//	if <(?)>, return 0
	mov x0, #0				//	otherwise return 1
	b		2f
1: 	mov x0, #1
2:	ret

.data

