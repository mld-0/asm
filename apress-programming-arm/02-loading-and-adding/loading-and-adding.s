//   vim: set tabstop=4 modeline modelines=10:
//   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-06-28T04:04:04AEST (how hard is it to) get 'donemsg' length (in order to put it into 'x2' instead of using const '#5')
//	Ongoing: 2022-07-01T22:48:15AEST no arithmetic-shift/rotate left? (arithmetic-shift left not applicable), (rotate left should be a thing?)
//	}}}

//	Two's Complement
//	The N-bit representation of -n in binary is: 2**N - n
//		-1 = 2**8 - 1 = 255 = 0xFF
//	Alternatively, flip the bits and add 1.
//	<(The max positive value of an N-bit signed number is 2**(N-1)?)>

//	Big Endian: 		MSB -> LSB
//	Little Endian: 		LSB -> MSB
//	ARM/x86 are (bi) little-endian. TCP/IP uses big-endian.
//	Little-endian allows easy conversion between integer sizes (1st byte of an int becomes only bytes of a short).

//	'MOV' is an alias. 'MOV X0, X1' is implemented as 'ORR X0, XZR, X1'



.global _start

.align 2

_start:

	//	Carry flag: <(set when the result of an integer operation overflows)>
	//	Barrel shifter: allows shifts to be applied to instruction Operand2 (before it is loaded)

	//	Shifting and Rotating:
	//	n left shifts is equivalent to multiplication by 2**n
	//	n right shifts is equivalent to division by 2**n

	//	0000 0011 << 3 = 0001 1000

	//	logical shift left
	//	zeros come in from the right, last bit shifted out becomes the carry flag

	//	logical shift right
	//	zeros come in from the left, last bit shifted out becomes the carry flag

	//	arithmetic shift right
	//	one comes in from the left if the number is negative, zero if it is positive

	//	rotate right
	//	bits that leave on the right reappear on the left

	//	rotate left
	//	<>



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

