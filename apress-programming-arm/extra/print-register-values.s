#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:

//	Continue: 2022-07-04T23:05:15AEST passing 2 arguments, register number, register value (to print 'xn=(%x)')

.global _start

.align 2

_start:
	//	Saving value as string, printing string, requires implementation of 'itoa()'
	//	LINK: https://stackoverflow.com/questions/17357467/how-to-print-a-number-in-arm-assembly


	//	Example: call printf for each example value (loaded into x8) (macOS Specific)
	//	LINK: https://stackoverflow.com/questions/69454175/calling-printf-from-aarch64-asm-code-on-apple-m1-macos
	//	64-bytes = 16-hex-digits
	mov x8,  #0x0
	stp x29, x30, [sp, -0x10]!
    sub sp, sp, 0x10
    str x8, [sp]
    adr x0, hexformatstr
    bl _printf
    mov w0, 0
    add sp, sp, 0x10
    ldp x29, x30, [sp], 0x10

    mov x8, #0x1010
	stp x29, x30, [sp, -0x10]!
    sub sp, sp, 0x10
    str x8, [sp]
    adr x0, hexformatstr
    bl _printf
    mov w0, 0
    add sp, sp, 0x10
    ldp x29, x30, [sp], 0x10

    mov x8, #0xF0F0
	stp x29, x30, [sp, -0x10]!
    sub sp, sp, 0x10
    str x8, [sp]
    adr x0, hexformatstr
    bl _printf
    mov w0, 0
    add sp, sp, 0x10
    ldp x29, x30, [sp], 0x10

	mov x8,  #0x6E3A
	movk x8, #0x4F5D, LSL #16
	movk x8, #0xFEDC, LSL #32
	movk x8, #0x1234, LSL #48
	stp x29, x30, [sp, -0x10]!
    sub sp, sp, 0x10
    str x8, [sp]
    adr x0, hexformatstr
    bl _printf
    mov w0, 0
    add sp, sp, 0x10
    ldp x29, x30, [sp], 0x10

	mov x8,  #0xFFFFFFFFFFFFFFFF
	stp x29, x30, [sp, -0x10]!
    sub sp, sp, 0x10
    str x8, [sp]
    adr x0, hexformatstr
    bl _printf
    mov w0, 0
    add sp, sp, 0x10
    ldp x29, x30, [sp], 0x10


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
	//	64-bytes = 16-hex-digits, use 16 leading zeros
	hexformatstr: .asciz "0x%016lX\n"
	donemsg: .ascii "Done\n"

