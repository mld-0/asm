#!/usr/bin/env bash
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

path_binary_top_asm_instructions="binary_top_asm_instructions.sh"
path_build_cpp=""
CC=g++
gpp_flags=( --std=c++17 -O0 )
arch_default='arm64'

#	validate path_binary_top_asm_instructions
#	{{{
if [[ ! -f "$path_binary_top_asm_instructions" ]]; then
	echo "error, not found, path_binary_top_asm_instructions=($path_binary_top_asm_instructions)" > /dev/stderr
	exit 2
fi
#	}}}

test_binary_top_asm_instructions() {
	local path_source="$1"
	local arch="${2:-$arch_default}"
	local path_bin=$( echo "$path_source" | sed 's/\.[^.]*$//' )

	#	validate: path_source, path_bin, arch
	#	{{{
	if [[ ! -f "$path_source" ]]; then
		echo "error, not found, path_source=($path_source)" > /dev/stderr
		exit 2
	fi
	if [[ -z "$path_bin" ]]; then
		echo "error, empty path_bin=($path_bin)" > /dev/stderr
		exit 2
	fi
	if [[ "$path_bin" = "$path_source" ]]; then
		echo "error, path_bin=($path_bin) == path_source($path_source)" > /dev/stderr
		exit 2
	fi
	if [[ -z "$arch" ]]; then
		echo "error, empty arch=($arch)" > /dev/stderr
		exit 2
	fi
	#	}}}

	echo "path_source=($path_source)" > /dev/stderr
	echo "path_bin=($path_bin)" > /dev/stderr
	echo "CC=($CC), arch=($arch), gpp_flags=(${gpp_flags[@]})" > /dev/stderr

	$CC ${gpp_flags[@]} -arch "$arch" "$path_source" -o "$path_bin"

	#	validate existance: path_bin
	#	{{{
	if [[ ! -f "$path_bin" ]]; then
		echo "error, not found, path_bin=($path_bin)" > /dev/stderr
		exit 2
	fi
	#	}}}

	$SHELL $path_binary_top_asm_instructions --counts --arch "$arch" "$path_bin"

	echo "" 2> /dev/stderr
}

path_source="heap-vs-stack-array.cpp"

arch="arm64"
test_binary_top_asm_instructions "$path_source" "$arch"

arch="x86_64"
test_binary_top_asm_instructions "$path_source" "$arch"

echo "done" > /dev/stderr

