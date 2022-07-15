//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-15T01:15:18AEST Reason for use of 'BUFFERLEN + 1' for buffer size? (is it the null byte (and why)?)
//	Ongoing: 2022-07-15T02:15:45AEST (the 'asm/' obviously refers to assembly (not a dir)) why not just 'unistd.h'?
//	Ongoing: 2022-07-15T02:17:29AEST book uses 'align 4' for instructions (align 4 *is* (also) align 2?)
//	Ongoing: 2022-07-15T02:20:31AEST HelloSilicon use of '.word .-ascizvar'?
//	Ongoing: 2022-07-15T02:51:41AEST binary file IO?
//	Ongoing: 2022-07-15T23:07:35AEST is it necessary to put -1 in x0 before calling openFileRW?
//	}}}

//	Use of capital '.S' extension allows use of C include files
//	Note: makefile uses 'clang -c' and not 'as' for building '.S' files

//	Making system calls:
//		x0-x7		parameters / return code
//		x8			system call number (Linux)
//		x16			system call number (macOS)

//	Linux system calls will preserve all registers not used as parameters
//	<(Presumedly macOS too?)>

//	Linux system call numbers (consult): /usr/include/asm-generic/unistd.h
//	Return codes (consult): /usr/include/errno.h
//	<(macOS equivalents?)>

//	The C-struct 'timespec' (see below) is equivalent to two longs:
//			struct timespec {
//				time_t 	tv_sec;
//				long 	tv_nsec;
//			};
//	That is:
//			timespecsec:	.dword	0
//			timesepcnano:	.dword 	100000000
//	And to call:
//			int nanosleep(const struct timespec*, struct timespec*)
//	We use:
//			ldr x0, =timespec
//			ldr x1, =timespec

//	When process closes, Unix <(should?)> release any resources it owns (including file descriptors)

//	Book uses (for Linux): 
//#include <asm/unistd.h>

#include "fileio.S"

//	Registers:
//		x11 = input file descriptor
//		x9 = output file descriptor
//		x10 = number of characters read


//	macOS Specific file-io constants:
.equ 		O_RDONLY, 	0
.equ 		O_WRONLY, 	1
.equ 		O_CREAT, 	0x00000200

.equ 		BUFFERLEN, 1024

.global _start 

.align 2

_start:
	bl 	print_filename_in
	bl 	print_filename_out

openfiles:
	//	Open input file:
	//mov x0, #-1
	openFileRW 		filename_in, O_RDONLY
	mov x11, x0 							//	x11 = input file descriptor (or error)
	b.cs 	error_open_in					//	if file not opened successfully

	//	Open output file:
	openFileRW 		path_out, O_CREAT+O_WRONLY
	mov x9, x0								//	x9 = output file descriptor (or error)
	b.cs 	error_open_out

L1:
	//	Read input file:
	readFile 		x11, buffer, BUFFERLEN-1	//	leave space for null-terminator
	mov x10, x0 							//	x10 = number of characters read

	//	Call 'toupper()'
	adrp 	x0, buffer@PAGE
	add x0, x0, buffer@PAGEOFF
	mov x1, #0								//	null terminator
	strb w1, [x0, x10]						//	put null-terminator at end of string
	adrp 	x1, outBuffer@PAGE
	add x1, x1, outBuffer@PAGEOFF
	mov x2, #BUFFERLEN
	bl 		toupper

	//	Write to output file:
	writeFile 		x9, outBuffer, x10

	cmp x10, #BUFFERLEN-1					//	loop (L1) if we read BUFFERLEN-1 bytes
	b.eq 	L1


closefiles:
	//	Close input/output files:
	closeFile		x11
	closeFile 		x9

done:
	//	Write 'donemsg'
	mov x0, #1								//	1 = stdout
	adrp 	x1, donemsg@PAGE
	add x1, x1, donemsg@PAGEOFF
	adrp 	x2, donemsg_len@PAGE			//	len(donemsg)
	add x2, x2, donemsg_len@PAGEOFF
	ldr w2, [x2]
	mov x16, #4								//	4 = write syscall
	svc 0
	//	macOS 'exit' syscall, return x0
	mov x0, #0
	mov x16, #1
	svc 0


error_open_in:
	//	Failed to open input file
	mov x0, #2								//	2 = stderr
	adrp 	x1, input_error@PAGE			//	x1 = &input_error
	add x1, x1, input_error@PAGEOFF
	adrp 	x2, input_error_len@PAGE		//	len(input_error)
	add x2, x2, input_error_len@PAGEOFF
	ldr w2, [x2]
	mov x16, #4								//	write syscall
	svc #0x80
	b 	exit_error

error_open_out:
	//	Failed to open output file
	mov x0, #2
	adrp 	x1, output_error@PAGE
	add x1, x1, output_error@PAGEOFF
	adrp 	x2, output_error_len@PAGE		//	len(output_error)
	add x2, x2, output_error_len@PAGEOFF
	ldr w2, [x2]
	mov x16, #4
	svc #0x80
	b 	exit_error

exit_error:
	//	return x0 and exit
	mov x16, #1
	svc #0x80

print_filename_in:
	mov x0, #1								//	1 = stdout
	adrp 	x1, filename_in@PAGE
	add x1, x1, filename_in@PAGEOFF
	adrp 	x2, filename_in_len@PAGE
	add x2, x2, filename_in_len@PAGEOFF
	ldr w2, [x2]
	mov x16, #4								//	4 = write syscall
	svc 0
	mov x0, #1
	adrp 	x1, nl@PAGE
	add x1, x1, nl@PAGEOFF
	mov x2, #1
	mov x16, #4
	svc 0
	ret

print_filename_out:
	mov x0, #1								//	1 = stdout
	adrp 	x1, path_out@PAGE
	add x1, x1, path_out@PAGEOFF
	adrp 	x2, path_out_len@PAGE
	add x2, x2, path_out_len@PAGEOFF
	ldr w2, [x2]
	mov x16, #4								//	4 = write syscall
	svc 0
	mov x0, #1
	adrp 	x1, nl@PAGE
	add x1, x1, nl@PAGEOFF
	mov x2, #1
	mov x16, #4
	svc 0
	ret

.data
	.align 4
	donemsg: .asciz "Done\n"
	.align 4
	donemsg_len: .word .-donemsg

	.align 4
	nl: .asciz "\n"

	.align 4
	filename_in: .asciz "toupper.s"
	.align 4
	filename_in_len: .word .-filename_in

	.align 4
	path_out: .asciz "/tmp/output-toupper.s"
	.align 4
	path_out_len: .word .-path_out

	.align 4
	buffer: .fill BUFFERLEN, 1, 0

	.align 4
	outBuffer: .fill BUFFERLEN, 1, 0

	.align 4
	input_error: .asciz "Failed to open input\n"
	.align 4
	input_error_len: .word .-input_error

	.align 4
	output_error: .asciz "Failed to open output\n"
	.align 4
	output_error_len: .word .-output_error


