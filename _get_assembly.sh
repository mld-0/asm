
path_file="src/heap-vs-stack-array.cpp"
path_bin="bin/heap-vs-stack-array"

g++ -std=c++17 "$path_file" -o "$path_bin"

otool "$path_bin" -tV -X

