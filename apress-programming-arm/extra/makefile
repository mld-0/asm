print-register-values: print-register-values.o
	ld -o print-register-values print-register-values.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64 

print-register-values.o: print-register-values.s
	as -arch arm64 -o print-register-values.o print-register-values.s


