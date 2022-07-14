//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-15T01:15:18AEST Reason for use of 'BUFFERLEN + 1' for buffer size? (is it the null byte (and why)?)
//	Ongoing: 2022-07-15T02:15:45AEST (the 'asm/' obviously refers to assembly (not a dir)) why not just 'unistd.h'?
//	Ongoing: 2022-07-15T02:17:29AEST book uses 'align 4' for instructions (align 4 *is* (also) align 2?)
//	Ongoing: 2022-07-15T02:20:31AEST HelloSilicon use of '.word .-ascizvar'?
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

	//	Open input file:
	mov x0, #-1
	openFileRW 		filename_in, O_RDONLY
	mov x11, x0 							//	x11 = input file descriptor (or error)
	b.cc 	L1								//	if file opened successfully

	//	Failed to open input file
	mov x0, #2								//	2 = stderr
	adrp 	x1, input_error@PAGE			//	x1 = &input_error
	add x1, x1, input_error@PAGEOFF
	mov x2, #21								//	len(input_error)
	mov x16, #4								//	write syscall
	svc #0x80
	b 	exit_error

	//	Ongoing: 2022-07-15T02:23:46AEST use branch-if-not-successful instead(?)
L1:
	//	Open output file:
	openFileRW 		path_out, O_CREAT+O_WRONLY
	mov x9, x0								//	x9 = output file descriptor (or error)
	b.cc 	L2

	//	Failed to open output file
	mov x0, #2
	adrp 	x1, output_error@PAGE
	add x1, x1, output_error@PAGEOFF
	mov x2, #22
	mov x16, #4
	svc #0x80
	b 	exit_error

L2:
	//	Continue: 2022-07-15T02:50:04AEST readFile/writeFile usage


L3:
	//	Close input/output files:
	closeFile		x11
	closeFile 		x9


	//	Write 'donemsg'
	mov x0, #1								//	1 = stdout
	adrp 	x1, donemsg@PAGE
	add x1, x1, donemsg@PAGEOFF
	mov x2, #5								//	5 = len(donemsg)
	mov x16, #4								//	4 = write syscall
	svc 0
	//	macOS 'exit' syscall, return x0
	mov x0, #0
	mov x16, #1
	svc 0

exit_error:
	mov x0, #2								//	return 2 and exit
	mov x16, #1
	svc #0x80

.data
	.align 4
	donemsg: .asciz "Done\n"

	.align 4
	filename_in: .asciz "toupper.s"

	.align 4
	path_out: .asciz "/tmp/output-toupper.txt"

	.align 4
	buffer: .fill BUFFERLEN, 1, 0

	.align 4
	outBuffer: .fill BUFFERLEN, 1, 0

	.align 4
	input_error: .asciz "Failed to open input\n"

	.align 4
	output_error: .asciz "Failed to open output\n"


