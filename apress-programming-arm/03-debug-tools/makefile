debug-tools.out: debug-tools.o
	ld -o debug-tools.out debug-tools.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64 

debug-tools.o: debug-tools.s
	as -arch arm64 -o debug-tools.o debug-tools.s


