#	{{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
#	Ongoings:
#	{{{
#	Ongoing: 2022-07-29T04:31:53AEST Apple Silicon and half-floats(?)
#	Ongoing: 2022-07-29T23:13:18AEST float<->int conversions, signed/unsigned referes to integer side of conversion(?)
#	Ongoing: 2022-07-29T23:21:50AEST Does C have the same behaviour vis-a-vis FP normalized form?
#	Ongoing: 2022-07-30T01:10:23AEST The C-printf function can only print doubles (not floats) (according to book and HelloSilicon) (but is that actually true?)
#	Ongoing: 2022-07-30T01:34:56AEST printf "%f" is hiding part of our decimal (how to get printf to print the <exact/actual> value of a double?
#	Ongoing: 2022-07-30T01:41:21AEST (How much work is required for) printf converting double to string (for) '%f'?
#	Ongoing: 2022-07-30T01:50:48AEST printing more decimal places than float supports results in incorrect values (not .****00000)
#	}}}
#	Continue: 2022-07-30T02:15:24AEST review 'floating-point-is-hard' series (see worklog)

#	The ARM FPU (floating-point unit) performs floating point calculations as well as limited SIMD instructions.
#	(The NEON co-processor offers much more extensive SIMD capabilities).

#	Floating point numbers store a fractional part and an exponent.
#	IEEE754 is the standard for most floating-point implementations, including ARM.

#	Bits of a floating-point number:
#	ARM supports half/single/double precision floats (16/32/64 bits)
#		Name			Precision		Sign		Fraction		Exponent 	Decimal-digits <(significant figures)>
#		Half			16-bits			1			10				5			3
#		Single			32-bits			1			23				8			7
#		Double			64-bits			1			52				11			16
#	Not all combinations of 16/32/64 bits are valid floating-point numbers.

#	'NaN' (not-a-number) is produced by illegal operations. 
#	It allows errors to propagate through a calculation without crashing the program. 
#	NaN is denoted by an exponent of all-1 bits

#	floating-point allows the same number to be represented in multiple ways:
#			1E0 = 0.1E1 = 0.01E2 = 0.001E3
#	The form with no leading zeros is the 'normalized' form. 
#	The ARM FPU tries to keep numbers in normalized form, except for very small numbers to avoid underflow.

#	<(floating point only has rounding errors for decimals (no decimal component = no rounding errors)?)>
#	Floating point numbers are inherently prone to rounding errors. It is not a suitable datatype for currency.

#	The FPU and NEON share a set of (32) 128-bit registers (although the FPU only support 64-bit calculations).
#	To access the lower-N bits of the register, use: (upper bits are set to 0)
#			V (FPU)		128-bits
#			Q (NEON)	128-bits
#			D			64-bits
#			S			32-bits
#			H			16-bits
#	These registers can be used with (regular) load/store instructions.
#	<(Use 'Q' when loading/storing floating-point registers on the stack.)> <(Not 'V'?)>

#	Function call protocol:
#			Callee saved: v8-v15 <(q8-q15?)>
#			Caller saved: v0-v7 <(q0-q7?)>

#	Use 'FMOV' to move between floating-point registers (bit are copied un-modified)
#	<(Registers should (generally?) be same size, except for copying H -> larger-int registers)>
#			FMOV 	H1, W2
#			FMOV	W2, H1
#			FMOV	S1, W2
#			FMOV	X1, D2
#			FMOV	D2, D3

#	Basic floating-point Arithmetic: (use H, S, or D registers)
#			FADD	Dd, Dn, Dm				//	Dd = Dn + Dm
#			FSUB	Dd, Dn, Dm				//	Dd = Dn - Dm
#			FMUL	Dd, Dn, Dm				//	Dd = Dn * Dm
#			FDIV	Dd, Dn, Dm				//	Dd = Dn / Dm
#			FMADD	Dd, Dn, Dm, Da			//	Dd = Da + Dm * Dn
#			FMSUB	Dd, Dn, Dm, Da			//	Dd = Da - Dm * Dn
#			FNEG	Dd, Dn					//	Dd = -Dn
#			FABS	Dd, Dn					//	Dd = abs(Dn)
#			FMAX	Dd, Dn, Dm				//	Dd = max(Dn, Dm)
#			FMIN	Dd, Dn, Dm				//	Dd = min(Dn, Dm)
#			FSQRT	Dd, Dn					//	Dd = sqrt(Dn)

#	Conversion between half/single/double floating-point: any combination of D/S/H registers
#			FCVT	Dd, Sm	

#	Integer to floating point: (D->X or S->W)
#			SCVTF	Dd, Xm					//	(signed)
#			UCVTF	Dd, Xm					//	(unsiged)

#	Floating point to integer: <(any combination of X/W and D/S/H?)>
#			FCVTAS	Wd, Hn					//	(signed), round to nearest
#			FCVTAU	Wd, Sn					//	(unsigned), round to nearest
#			FCVTMS	Xd, Dn					//	(signed), round towards -inf <(floor)>
#			FCVTMU	Xd, Dn					//	(unsigned), round towards -inf <(floor)>
#			FCVTPS	Xd, Dn					//	(signed), round towards +inf <(ceil)>
#			FCVTPU	Xd, Dn					//	(unsigned), round towards +inf <(ceil)>
#			FCVTZS	Xd, Dn					//	(signed) round towards 0
#			FCVTZU	Xd, Dn					//	(unsigned) round towards 0

#	Comparing floating-point numbers: <(D/S/H)>
#	Update conditional flags
#			FCMP	Dd, Dm
#			FCMP	Dd, #0.0
#	<(Use same 'b.le' conditional branch instructions as with integer comparions (CMP?))>

#	Comparing floating-point numbers is problematic due to rounding errors. For this reason, we check if numbers are equal using:
#			abs(D1 - D2) < e
#	For some small value of 'e'.

#	Floating point number variables are defined with '.single' and '.double' <('.half'?)>

#	printf floating point:
#	<(printf only accepts doubles, not floats?)>
#			%A			FP hex representation
#			%f			floating point (<round/truncate> small values)
#			%e			scientific notation
#			%g			

#	Print floating point numbers losslessly:
#	(such that they can be read back in to exactly the same number, except NaN and Infinity)
#			printf("%.9g", float_var)
#			printf("%.17g", double_var)
#	{{{
#	Do NOT use %f, since that only specifies how many significant digits after the decimal and will truncate small numbers. For reference, the magic numbers 9 and 17 can be found in float.h which defines FLT_DECIMAL_DIG and DBL_DECIMAL_DIG.
#	LINK: https://stackoverflow.com/questions/16839658/printf-width-specifier-to-maintain-precision-of-floating-point-value
#	LINK: https://randomascii.wordpress.com/2012/03/08/float-precisionfrom-zero-to-100-digits-2/
#	}}}
#	<(or alternatively, for the 'exact' value of a (float/double?) use "%A" (float hex value?))>


.include "debug-printf.s"
.global _start
.align 4

_start:
	stp x19, x20, [SP, #-16]!
	str LR, [SP, #-16]!

pushpop_fp_reg:
	#	Use 'Q' (128-bit) version when push/pop-ing FP registers 
	stp q8, q9, [SP, #-32]!
	str q10, [SP, #-16]!
	ldr q10, [SP], #16
	ldp q8, q9, [SP], #32


#	Continue: 2022-07-30T04:32:58AEST 'fp_int_conversion', 'normalized_form'
fp_int_conversion:
	#	<>

normalized_form:
	#	<>


call_distance_f:
	adrp 	x0, f_AB@PAGE
	add x0, x0, f_AB@PAGEOFF
	bl 	distance_f
	
	fmov s2, w0 							//	convert result to double for printf <(required?)> 
	fcvt d0, s2
	fmov x1, d0

	str x1, [SP, #-16]!						//	printf()
	adrp 	x0, str_printf_float@PAGE
	add x0, x0, str_printf_float@PAGEOFF
	bl 	_printf
	add SP, SP, #16


call_distance_d:
	adrp 	x0, d_AB@PAGE
	add x0, x0, d_AB@PAGEOFF
	bl 	distance_d

	str x0, [SP, #-16]!						//	printf()
	adrp 	x0, str_printf_double@PAGE
	add x0, x0, str_printf_double@PAGEOFF
	bl 	_printf
	add SP, SP, #16


call_fp_compare:
	adrp 	x0, f_abc@PAGE
	add x0, x0, f_abc@PAGEOFF
	bl 	fp_compare_f
	printf_reg 	0

	adrp 	x0, f_def@PAGE
	add x0, x0, f_def@PAGEOFF
	bl 	fp_compare_f
	printf_reg 	0

	adrp 	x0, d_abc@PAGE
	add x0, x0, d_abc@PAGEOFF
	bl 	fp_compare_d
	printf_reg 	0

	adrp 	x0, d_def@PAGE
	add x0, x0, d_def@PAGEOFF
	bl 	fp_compare_d
	printf_reg 	0


done:
	ldr LR, [SP], #16
	ldp x19, x20, [SP], #16
	printf_str "Done"
	mov x0, #0
	ret

.data
	f_AB:	.single 	1.3, 5.4, 3.1, -1.5						//	(x1,y1, x2,y2)
	.align 4
	d_AB:	.double 	1.3, 5.4, 3.1, -1.5						
	.align 4

	f_abc:	.single 	0.1, 0.10001, 0.001 					//	(num1, num2, e)
	.align 4
	d_abc:	.double 	0.1, 0.10001, 0.001
	.align 4

	f_def:	.single 	0.1, 0.11, 0.001 
	.align 4
	d_def:	.double 	0.1, 0.11, 0.001
	.align 4

	str_printf_float:	.asciz		"Distance = %.9g\n"
	.align 4
	str_printf_double:	.asciz		"Distance = %.17g\n"
	.align 4

