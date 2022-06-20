
path_file="src/heap-vs-stack-array.cpp"
path_asm="heap-vs-stack-array.s"
path_asm_bin="bin/heap-vs-stack-array"

#	C++ -> asm
g++ -std=c++17 "$path_file" -S -o "$path_asm"
g++ "$path_asm" -o "$path_asm_bin"



