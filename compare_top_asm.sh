#!/usr/bin/env bash
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

#	Allow subshell 'exit 2' to terminate script
set -E;
trap '[ "$?" -ne 2 ] || exit 2' ERR

nl=$'\n'
tab=$'\t'

path_test_get_bin_top_asm="test_get_bin_top_asm.sh"
#	validate existance: path_test_get_bin_top_asm
#	{{{
if [[ ! -f "$path_test_get_bin_top_asm" ]]; then
	echo "error, not found, path_test_get_bin_top_asm=($path_test_get_bin_top_asm)" > /dev/stderr
	exit 2
fi
#	}}}
source "$path_test_get_bin_top_asm"

CC=g++
gpp_flags=( --std=c++17 -O0 )
arch_default='arm64'
flag_debug=0
arch=$arch_default

paths_source=(
do-nothing.cpp
hello-world.cpp
heap-vs-stack-array.cpp
)

main() {
	echo "gpp_flags=(${gpp_flags[@]})"
	echo "arch=($arch)"
	for loop_source in "${paths_source[@]}"; do
		loop_source="src/$loop_source"
		echo "$loop_source"
		test_binary_top_asm_instructions "$loop_source" "$arch"
		echo ""
	done
}

check_sourced=1
#	{{{
if [[ -n "${ZSH_VERSION:-}" ]]; then 
	if [[ ! -n ${(M)zsh_eval_context:#file} ]]; then
		check_sourced=0
	fi
elif [[ -n "${BASH_VERSION:-}" ]]; then
	(return 0 2>/dev/null) && check_sourced=1 || check_sourced=0
else
	echo "error, check_sourced, non-zsh/bash" > /dev/stderr
	exit 2
fi
#	}}}
if [[ "$check_sourced" -eq 0 ]]; then
	main
fi

