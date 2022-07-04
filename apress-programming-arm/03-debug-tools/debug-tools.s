#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:

//	lldb is the clang equivalent of gdb


.global _start

.align 2

_start:


	//	128-bit addition: (x0,x1) = (x2,x3) + (x4,x5)
	mov x2, #0x0000000000000003
	mov x3, #0xFFFFFFFFFFFFFFFF
	mov x4, #0x0000000000000005
	mov x5, #0x0000000000000001
	//	add lower order bits
	adds x1, x3, x5
	//	add higher order bits
	adc x0, x2, x4

	
	//	Write 'donemsg'
	mov x0, #1			//	1 = stdout
	adr x1, donemsg
	mov x2, #5			//	5 = len(donemsg)
	mov x16, #4			//	4 = write syscall
	svc 0

	//	macOS 'exit' syscall, return x0 
	mov x0, #0
	mov x16, #1
	svc 0

.data:
	donemsg: .ascii "Done\n"

