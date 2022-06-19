
#	Use 'subs' instead of 'sub' (ect) whenever we cannot rule out the result being negative

#	op{cond}{S} Rd, Rn, Operand2
#		op			add/sub/rsb/adc/sbc/rsc
#		{cond}		(optional) condition code
#		{S}			(optional) suffix, enable results flags
#		Rd			destination register
#		Rn			register holding first operand
#		Operand2	flexible second operand

#	add-with-carry (abc): Rd = Rn+Operand2+carry
#	sub-with-carry (sbc): Rd = Rn-Operand2-carry

.global _start

_start:
	mov r0, #7
	mov r1, #5

	#	addition/multiplication
	add r2, r0, r1
	mul r2, r0, r1

	mov r0, #0xFFFFFFFF
	mov r1, #0x1

	#	subtraction with/without enabling results flags
	sub r2, r0, r1
	subs r2, r0, r1
	#	Ongoing: 2022-06-20T09:30:23AEST (how to) check negative / over/under-flow flags?

	#	addition with carry
	mov r0, #0xFFFFFFFF
	mov r1, #0x5
	adc r2, r0, r1	

	##	multi-word arithmetic
	##	[r0r1] + [r2r3] = [r4r5]
	#adds r4, r0, r2
	#adc r5, r1, r3

endstate:
	b endstate

.data

