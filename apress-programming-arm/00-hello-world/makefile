hello-world.out: hello-world.o
	ld -o hello-world.out hello-world.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64 

hello-world.o: hello-world.s
	as -arch arm64 -o hello-world.o hello-world.s


