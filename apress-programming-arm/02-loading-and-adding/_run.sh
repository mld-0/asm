#!/usr/bin/env sh
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#	{{{2
#	Ongoings:
#	{{{
#	Ongoing: 2022-06-28T04:10:02AEST apress-programming-arm/02-loading-and-adding, making (compile asm '_run.sh') script PWD independent (causes more problems (and in any case we can just cd as needed)?) [...] how to add './' to only if needed / otherwise execute 'path_bin' whether it is an absolute/relative path(?)
#	}}}

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

#path_dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
#path_src="$path_dir/loading-and-adding.s"
path_src="loading-and-adding.s"
#	validate: path_src
#	{{{
if [[ ! -f "$path_src" ]]; then
	echo "error, no file: path_src=($path_src)" > /dev/stderr
	exit 2
fi
#	}}}

path_obj=${path_src%.*}.o
path_bin=${path_src%.*}

#	validate: path_obj, path_bin
#	{{{
if [[ -z "$path_obj" ]]; then
	echo "error, empty str path_obj=($path_obj)" > /dev/stderr
	exit 2
fi
if [[ -z "$path_bin" ]]; then
	echo "error, empty str path_bin=($path_bin)" > /dev/stderr
	exit 2
fi
#	}}}
#	delete-existing: path_obj, path_bin
#	{{{
[ -f "$path_obj" ] && rm "$path_obj"
[ -f "$path_bin" ] && rm "$path_bin"
#	}}}

clang -c "$path_src" -o "$path_obj"
clang "$path_obj" -o "$path_bin" -e _start

#	validate: path_bin
#	{{{
if [[ ! -x "$path_bin" ]]; then
	echo "error, no bin: path_bin=($path_bin)" > /dev/stderr
	exit 2
fi
#	}}}

#$path_bin
./$path_bin

