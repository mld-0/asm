
path_file="src/heap-vs-stack-array.cpp"
path_bin="bin/heap-vs-stack-array"

clang -std=c++17 -S "$path_file" -o /dev/stdout

