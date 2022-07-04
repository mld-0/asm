
[ -f "debug-tools.o" ] && rm "debug-tools.o"
[ -f "debug-tools" ] && rm "debug-tools"


#	debug flag: -g <( '-glldb' ?)>

clang -g ${debug_flags[@]} -o "debug-tools.o" -c "debug-tools.s" 
clang -g -o "debug-tools" "debug-tools.o" -e _start


#	view debug info for executable/object file
#		dwarfdump --debug-line <file>

#	load lldb:
#		lldb debug-tools

#	set breakpoint at start
#		b start
#	run
#		r
#	list registers value
#		register read
#	next source instruction:
#		n
#	next instruction
#		ni
#	<(print stack?)>
#		x/10w -l 1 $sp

#	using qemu:
#	<>

