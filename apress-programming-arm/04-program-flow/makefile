
program-flow.out: program-flow.o
	ld -o program-flow.out program-flow.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64 

%.o : %.s
	as -arch arm64 -o $@ $<

