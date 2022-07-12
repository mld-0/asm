
.macro 	PUSH1 	reg
	str \reg, [sp, #-16]!
.endm

.macro 	POP1	reg
	ldr \reg, [sp], #16
.endm

.macro 	PUSH2	reg1, reg2
	stp \reg1, \reg2, [sp, #-16]!
.endm

.macro 	POP2	reg1, reg2
	ldp \reg1, \reg2, [sp], #16
.endm

