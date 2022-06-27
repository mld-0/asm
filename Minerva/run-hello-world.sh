
[ -f "hello-world.o" ] && rm "hello-world.o"
[ -f "hello-world" ] && rm "hello-world"

#	TODO: 2022-06-24T01:51:54AEST asm/Minerva/run-hello-world, clang, assembly, source -> executable in one command (without creating .o file)

clang -c "hello-world.s" -o "hello-world.o"
clang "hello-world.o" -o "hello-world"

#	or:
#as "hello-world.s" -o "hello-world.o" 
#ld "hello-world.o" -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -arch arm64 -o "hello-world"

./hello-world

