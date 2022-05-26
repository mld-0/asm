#!/usr/bin/env bash
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
nl=$'\n'
tab=$'\t'
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

#	Allow subshell 'exit 2' to terminate script
set -E;
trap '[ "$?" -ne 2 ] || exit 2' ERR

flag_debug=0

asm_arch_default='x86_64'
asm_arch_default='arm64e'
asm_arch_default='arm64'

bin_otool=otool

log_debug() {
	#	{{{
	if [[ $flag_debug -ne 0 ]]; then
		echo "$@" > /dev/stderr
	fi
}
#	}}}

top_asm_instructions() {
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
	local asm_arch="$asm_arch_default"
	local flag_counts=0
	local func_about="about"
	local func_help="""$func_name, $func_about
		\$1					path_binary
		--counts			include number of uses of each instruction
		-a | --arch 		asm_arch, default=($asm_arch_default)
		-v | --debug
		-h | --help
	"""
	#	{{{
	if echo "${1:-}" | perl -wne '/^\s*-h|--help\s*$/ or exit 1'; then
		echo "$func_help"
		return 2
	fi
	for arg in "$@"; do
		case $arg in
			-h|--help)
				echo "$func_help"
				return 2
				shift
				;;
			-v|--debug)
				flag_debug=1
				shift
				;;
			-a|--arch)
				asm_arch=$2
				shift
				shift
				;;
			--counts)
				flag_counts=1
				shift
				;;
		esac
	done
	#	}}}
	local path_binary="${1:-}"
	#	verify existance: path_binary
	#	{{{
	if [[ ! -f "$path_binary" ]]; then
		echo "$func_name, error, not found, path_binary=($path_binary)" > /dev/stderr
		exit 2
	fi
	#	}}}

	log_debug "path_binary=($path_binary)"
	log_debug "asm_arch=($asm_arch)"
	log_debug "flag_counts=($flag_counts)"

	is_binary_type_arch "$path_binary" "$asm_arch"

	binary_asm=$( $bin_otool -arch $asm_arch -tV -X "$path_binary" )
	binary_asm_lines=$( echo "$binary_asm" | wc -l )
	log_debug "binary_asm_lines=($binary_asm_lines)"

	binary_asm_instructions=$( get_instructions_list_from_otool_output "$binary_asm" ) 
	binary_asm_instructions_counted=$( echo "$binary_asm_instructions" | sort | uniq -c | sort -r )
	binary_asm_instructions_lines=$( echo "$binary_asm_instructions" | wc -l )
	log_debug "binary_asm_instructions_lines=($binary_asm_instructions_lines)"

	top_instructions_counts=$( echo "$binary_asm_instructions_counted" | perl -lane 'print @F[0]' )
	top_instructions=$( echo "$binary_asm_instructions_counted" | perl -lane 'print @F[1]' )

	if [[ $flag_counts -ne 0 ]]; then
		echo "$binary_asm_instructions_counted" | sed 's/^\s*//'
		echo "total: $binary_asm_instructions_lines"
	else
		echo "$top_instructions" 
	fi
}

is_binary_type_arch() {
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
	local path_binary="$1"
	local asm_arch="$2"
	#	validate: path_binary, asm_arch
	#	{{{
	if [[ ! -e "$path_binary" ]]; then
		echo "$func_name, error, not found, path_binary=($path_binary)" > /dev/stderr
		exit 2
	fi
	if [[ -z "$asm_arch" ]]; then
		echo "$func_name, error, empty asm_arch=($asm_arch)" > /dev/stderr
		exit 2
	fi
	#	}}}
	file_report_str=$( file "$path_binary" )
	if [[ -z `echo "$file_report_str" | grep "\bexecutable\b"` ]]; then
		echo "$func_name, error, file is not type 'executable'$nl$file_report_str" > /dev/stderr
		exit 2
	fi
	if [[ -z `echo "$file_report_str" | grep "\b$asm_arch\b"` ]]; then
		echo "$func_name, error, file is not type '$asm_arch'$nl$file_report_str" > /dev/stderr
		exit 2
	fi
}

get_instructions_list_from_otool_output() {
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
	local binary_asm="${1:-}"
	binary_asm=$( echo "$binary_asm" | grep "^$tab" | sed "s/^\s*\(\S*\).*/\1/g" )
	echo "$binary_asm"
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
	top_asm_instructions "$@"
fi

