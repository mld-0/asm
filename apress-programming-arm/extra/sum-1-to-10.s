
.include "debug-printf.s"
.global _start
.align 4

//	Registers:
//		x0 = sum
//		x1 = count
//		x2 = count_end

_start:
	mov x0, #0									//	x0 = 0
	mov x1, #1									//	x1 = 1
	mov x2, #10									//	x2 = 10

loop:
	add x0, x0, x1 								//	x0 = x0 + x1
	add x1, x1, #1								// 	x1 = x1 + 1

	cmp x1, x2 									//	if (x1 <= x2), goto 'loop'
	b.le 	loop								


done:
	printf_reg 	0
	mov x0, #0
	ret

