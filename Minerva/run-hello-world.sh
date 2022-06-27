
[ -f "hello-world.o" ] && rm "hello-world.o"
[ -f "hello-world" ] && rm "hello-world"

#	TODO: 2022-06-24T01:51:54AEST asm/Minerva/run-hello-world, clang, assembly, source -> executable in one command (without creating .o file)

clang -o "hello-world.o" -c "hello-world.s" 
clang -o "hello-world" "hello-world.o" -e _start

#	or: (produces identical binary)
#as "hello-world.s" -o "hello-world.o" 
#ld "hello-world.o" -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64 -o "hello-world"

./hello-world

