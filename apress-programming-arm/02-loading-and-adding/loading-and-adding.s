//	Ongoing: 2022-06-28T04:04:04AEST (how hard is it to) get 'donemsg' length (in order to put it into 'x2' instead of using const '#5')

.global _start

.align 2

_start:

	//	Write 'donemsg'
	mov x0, #1			//	1 = stdout
	adr x1, donemsg
	mov x2, #5			//	5 = len(donemsg)
	mov x16, #4			//	4 = write syscall
	svc 0

	//	macOS 'exit' syscall
	mov x0, #0
	mov x16, #1
	svc 0

.data:
	donemsg: .ascii "Done\n"

