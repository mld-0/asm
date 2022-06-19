
#	Instructions:
#
#	mov{S}{cond} Rd, Operand2		(move)
#	mov{cond} Rd, #imm16
#		{S}:		(optional) suffix
#		{cond}:		(optional) conditional code
#		Rd:			destination
#		Operand2:	flexible second operand
#		imm16:		value in range 0-65535 
#
#	swi immed_8						(software interupt)
#		immed_8		value in range 0-255 (used by exception handler)

#	export labels
.global _start

#	start label
_start:

	#	place value in r0
	mov r0, #30

	#	r7 is used for syscalls, 1 is the code to exit
	mov r7, #1

	#	syscall, r7=1 -> exit
	swi 0

