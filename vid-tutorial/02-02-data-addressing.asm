
#	load:
#	ldr{type}{cond} Rt, [Rn {,#offset}]		;	immediate offset
#	ldr{type}{cond} Rt, [Rn, #offset]!		;	pre-indexed
#	ldr{type}{cond} Rt, [Rn], #offset		;	post-indexed
#		{type}		(omitted for word) B=unsigned-byte, SB=signed-byte, H=unsighed-halfword, SH=signed-halfword)
#		{cond}		(optional) conditional code
#		Rt			<(destination)>
#		Rn			memory address register
#		offset		(omitted if 0) applied to contents of Rn to form address

.global _start

_start:
	#	r0 = address(my_vals) 
	ldr r0, =my_vals

	#	memory[r0] -> r1
	ldr r1, [r0]

	#	r1 = memory[r0+4] 
	ldr r2, [r0, #4]

	#	(pre-increment) r0=r0+4, r1 = memory[r0] 
	ldr  r3, [r0, #8]!

	add r0, #4

	#	(post-increment) r1 = memory[r0], r0=r0+4
	ldr r4, [r0], #4

#	end state
S:
	b S

.data

#	list of 4 byte values, loaded into memory at program launch(?)
my_vals:
	.word 3,5,7,9

