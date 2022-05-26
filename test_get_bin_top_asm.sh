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

flag_debug=1
log_debug() {
	#	{{{
	if [[ $flag_debug -ne 0 ]]; then
		echo "$@" > /dev/stderr
	fi
}
#	}}}

path_get_bin_top_asm="get_bin_top_asm.sh"
CC=g++
gpp_flags=( --std=c++17 -O0 )
arch_default='arm64'
#	validate existance: path_get_bin_top_asm
#	{{{
if [[ ! -f "$path_get_bin_top_asm" ]]; then
	echo "error, not found, path_get_bin_top_asm=($path_get_bin_top_asm)" > /dev/stderr
	exit 2
fi
#	}}}

test_binary_top_asm_instructions() {
	#	{{{
	local func_name=""
	if [[ -n "${ZSH_VERSION:-}" ]]; then 
		func_name=${funcstack[1]:-}
	elif [[ -n "${BASH_VERSION:-}" ]]; then
		func_name="${FUNCNAME[0]:-}"
	else
		printf "%s\n" "warning, func_name unset, non zsh/bash shell" > /dev/stderr
	fi
	#	}}}
	local path_source="$1"
	local arch="${2:-$arch_default}"
	local path_bin=$( dirname "$path_source" )"/bin/"$( echo "$path_source" | sed 's/\.[^.]*$//' )
	#	validate: path_source, path_bin, arch
	#	{{{
	if [[ ! -d `dirname $path_bin` ]]; then
		log_debug "$func_name, mkdir `dirname $path_bin`"
		mkdir `dirname $path_bin`
	fi
	if [[ ! -f "$path_source" ]]; then
		log_debug "$func_name, error, not found, path_source=($path_source)"
		exit 2
	fi
	if [[ -z "`basename $path_bin`" ]]; then
		log_debug "$func_name, error, empty (basename path_bin=($path_bin))"
		exit 2
	fi
	if [[ "`basename $path_bin`" = "$path_source" ]]; then
		log_debug "$func_name, error, (basename path_bin=($path_bin)) == path_source($path_source)"
		exit 2
	fi
	if [[ -z "$arch" ]]; then
		log_debug "$func_name, error, empty arch=($arch)"
		exit 2
	fi
	#	}}}
	build_cpp "$path_source" "$path_bin" "$arch" 
	get_top_asm_commands "$path_bin" "$arch"
}

build_cpp() {
	#	{{{
	local func_name=""
	if [[ -n "${ZSH_VERSION:-}" ]]; then 
		func_name=${funcstack[1]:-}
	elif [[ -n "${BASH_VERSION:-}" ]]; then
		func_name="${FUNCNAME[0]:-}"
	else
		printf "%s\n" "warning, func_name unset, non zsh/bash shell" > /dev/stderr
	fi
	#	}}}
	local path_source="$1"
	local path_bin="$2"
	local arch="$3"
	log_debug "$func_name, path_source=($path_source)"
	log_debug "$func_name, path_bin=($path_bin)"
	build_cmd=( $CC ${gpp_flags[@]} -arch "$arch" "$path_source" -o "$path_bin" )
	log_debug "$func_name, build_cmd=(${build_cmd[@]})"
	${build_cmd[@]}
	#	validate existance: path_bin
	#	{{{
	if [[ ! -f "$path_bin" ]]; then
		log_debug "$func_name, error, not found, path_bin=($path_bin)"
		exit 2
	fi
	#	}}}
}

get_top_asm_commands() {
	local path_bin="$1"
	local arch="$2"
	top_asm_command=( $SHELL $path_get_bin_top_asm --counts --arch "$arch" "$path_bin" )
	log_debug "$func_name, top_asm_command=(${top_asm_command[@]})"
	${top_asm_command[@]}
}

main() {
	local path_source="heap-vs-stack-array.cpp"
	local arch="arm64"
	test_binary_top_asm_instructions "$path_source" "$arch"
	arch="x86_64"
	test_binary_top_asm_instructions "$path_source" "$arch"
	echo "done" > /dev/stderr
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

