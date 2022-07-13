loading-and-adding.out: loading-and-adding.o
	ld -o loading-and-adding loading-and-adding.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64 

loading-and-adding.o: loading-and-adding.s
	as -arch arm64 -o loading-and-adding.o loading-and-adding.s

