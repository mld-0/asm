//	vim: set tabstop=4 modeline modelines=10:
//	vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
//	{{{2
//	Ongoings:
//	{{{
//	Ongoing: 2022-07-13T19:19:43AEST compare/contrast with Linux (book) version
//	Ongoing: 2022-07-15T01:35:49AEST why is book using '0' for syscalls, but HelloSilicon is using '0x80'?
//	Ongoing: 2022-07-15T02:12:48AEST check/get 'equ' constants from C-imports
//	}}}

//	Book uses (for Linux):
//#include <asm/unistd.h>

//	<(macOS specific?)>
#include <sys/syscall.h>

//	Usage:
//		'fd' file-descriptor (integer), must be a register
//		'fileName' is a string variable <label?>
//		'flags' <(is a constant?)>
//		'buffer' is a variable <label?> we can write our string into
//		'length' gives the size of the buffer (can be either register/label)


//	macOS Specific file-io constants:
.equ 	S_RDWR,		0666
.equ 	AT_FDCWD,	-2

//	Returns x0 = file descriptor
.macro 	openFileRW		fileName, flags
	mov x0, 	#AT_FDCWD				//	open <path/name?> relative to current dir
	adrp	x1, \fileName@PAGE			//	file <path/name?>
	add x1, x1, \fileName@PAGEOFF
	mov x2, 	#\flags					//	flags
	mov x3, 	#S_RDWR					//	RW mode
	mov x16, 	#SYS_openat				//	openat syscall
	svc #0x80
.endm

//	Returns x0 = <(number of characters/bytes read)> 
.macro 	readFile 		fd, buffer, length
	mov x0,		\fd						//	file descriptor
	adrp 	x1, \buffer@PAGE			//	&buffer
	add x1, x1, \buffer@PAGEOFF
	mov x2, 	\length					//	len(buffer)
	mov x16,	#SYS_read				//	read syscall
	svc  #0x80
.endm

//	Returns <?>
.macro 	writeFile		fd, buffer, length
	mov x0, 	\fd						//	file descriptor
	adrp 	x1, \buffer@PAGE			//	&buffer
	add x1, x1, \buffer@PAGEOFF
	mov x2, 	\length					//	len(buffer)
	mov x16,	#SYS_write				//	write syscall
	svc #0x80
.endm

//	Returns <?>
.macro 	closeFile 		fd
	mov x0, 	\fd						//	file descriptor
	mov x16, 	#SYS_fsync				//	fsync syscall
	svc #0x80
	mov x0, 	\fd						//	file descriptor
	mov x16,	#SYS_close				//	close syscall
	svc #0x80
.endm

