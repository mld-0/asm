#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

CC=g++
path_script="binary_top_asm_instructions.sh"
gpp_flags=( --std=c++17 -O0 )

test_binary_top_asm_instructions() {
	local path_source="$1"
	local arch="$2"
	local path_bin=$( echo "$path_source" | sed 's/\.[^.]*$//' )

	echo "path_source=($path_source)" 2> /dev/stderr
	echo "arch=($arch)" 2> /dev/stderr
	echo "path_bin=($path_bin)" 2> /dev/stderr

	if [[ ! -f "$path_source" ]]; then
		echo "error, not found, path_source=($path_source)" > /dev/stderr
		exit 2
	fi
	if [[ "$path_bin" = "$path_source" ]]; then
		echo "error, path_bin=($path_bin) == path_source($path_source)" > /dev/stderr
		exit 2
	fi

	echo "arch=($arch)" > /dev/stderr
	$CC ${gpp_flags[@]} -arch "$arch" "$path_source" -o "$path_bin"

	if [[ ! -f "$path_bin" ]]; then
		echo "error, not found, path_bin=($path_bin)" > /dev/stderr
		exit 2
	fi

	$SHELL $path_script --counts --arch "$arch" "$path_bin"
	echo "" 2> /dev/stderr

}

path_source="heap-vs-stack-array.cpp"

arch="arm64"
test_binary_top_asm_instructions "$path_source" "$arch"

arch="x86_64"
test_binary_top_asm_instructions "$path_source" "$arch"

echo "done" > /dev/stderr

