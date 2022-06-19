
#	Instructions:
#	move:
#	mov{S}{cond} Rd, Operand2
#	mov{cond} Rd, #imm16
#		{S}:		(optional) suffix
#		{cond}:		(optional) conditional code
#		Rd:			destination
#		Operand2:	flexible second operand
#		imm16:		value in range 0-65535 
#
#	software interrupt (uses r7)
#	swi immed_8
#		immed_8		value in range 0-255 (used by exception handler)

#	export labels
.global _start

#	start label
_start:

	#	move 5 -> r0
	mov r0, #5
	#	move r0 -> r1
	mov r1, r0
	#	move 30 -> r0
	mov r0, #30


	#	exit syscall (not supported on CPULator)
	##	r7 is used for syscalls, 1 is the code to exit
	#mov r7, #10
	##	syscall, r7=1 -> exit
	#swi 0


#	end state (CPULator does not support exit syscall(?), infinite loop serves as our end state.
S:
	b S

.end

