#!@BINDIR@/bash
# Copyright (c) 2015-2018 Eric Vidal <eric@obarun.org>
# All rights reserved.
# 
# This file is part of Obarun. It is subject to the license terms in
# the LICENSE file found in the top-level directory of this
# distribution and at https://github.com/Obarun/obarun-libs/LICENSE
# This file may not be copied, modified, propagated, or distributed
# except according to the terms contained in the LICENSE file.
#
# search.sh - functions for searching

## 		Check list option

check_elements(){
	for e in "${@:2}"; do [[ $e == $1 ]] && return 0; done; return 1;
}

# ${1} name of the directory
# return 0 on success, 1 for fail
check_dir(){
	local dir
	dir="${1}"
	
	if [[ -d "${dir}" ]]; then
		return 0
	else
		return 1
	fi
	
	unset dir
}

# ${1} path directories
# ${2} name of directory
# ${3} searched files
# return 0 success, 1 fail
search_in_dir(){
	local path_dir search named here rc
	local -a list 
	path_dir="${1}"
	named="${2}"
	search="${3}"
	
	mapfile -t list < <(ls --group-directories-first ${path_dir}/${named})
	
	for here in "${list[@]}"; do
		case $here in
				$search) rc=0 && break ;;
				*) rc=1 ;;
			esac
		
	done
	if [[ $rc == 0  ]]; then
		unset rc
		return 0
	else
		unset rc
		return 1
	fi
	
	unset path_dir search named sub_dir list here rc
}

# ${1} path to the file
# ${2} name of the file
# ${3} searched on to the file
# return 0 on success, 1 on fail
search_in_file(){
	local path_file named search line_ in_file
	path_file="${1}"
	named="${2}"
	search="${3}"
	in_file="${path_file}/${named}"
	
	while read line_;do
		case $line_ in
			$search) rc=0 && break ;;
			*) rc=1 ;;
		esac
	done < "${in_file}"
	
	if [[ $rc == 0  ]]; then
		unset rc
		return 0
	else
		unset rc
		return 1
	fi
	
	unset path_file named search line_ in_file
}

# ${1} path to the file
# ${2} name of the file
# ${3} searched on to the file
# return 0 on success, 1 on fail
search_in_file(){
	local path_file named search line_ in_file
	path_file="${1}"
	named="${2}"
	search="${3}"
	in_file="${path_file}/${named}"
	
	while read line_;do
		case $line_ in
			$search) rc=0 && break ;;
			*) rc=1 ;;
		esac
	done < "${in_file}"
	if [[ $rc == 0  ]]; then
		unset rc
		return 0
	else
		unset rc
		return 1
	fi 
	unset path_file named search line_ in_file
}
