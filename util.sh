#!/usr/bin/bash
#
# Authors:
# Eric Vidal <eric@obarun.org>
#
# Copyright (C) 2015-2017 Eric Vidal <eric@obarun.org>
#
# This script is under license BEER-WARE
# "THE BEER-WARE LICENSE" (Revision 42):
# <eric@obarun.org> wrote this file.  As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.   Eric Vidal

# common functions file for obarun packages

LIBRARY=${LIBRARY:-'/usr/lib/obarun'}
OWNER="${SUDO_USER:-$USER}"

sourcing(){
	
	local list
	
	for list in ${LIBRARY}/lib/*; do
		source "${list}"
	done
	
	unset list
}
sourcing

## 		Exit
# {1} message to display
# {2} trap functions to call before exit
die (){
	local message _trap
	message="${1}"
	_trap="${2}"
		
	if [[ -n "${message}" ]] ; then
		out_error "${message}"
	else
		out_error "Script can not continue"
	fi
	
	${_trap}
	
	exit 1
}

##		Reply functions
## return 0 for yes
## return 1 for no
reply_answer(){
	local reply
	read reply
	while [[ ! "$reply" = @(y|n) ]]; do
		answer
		read reply
	done
	if [ "$reply" == "y" ]; then
		return 0
	else
		return 1
	fi	
}

# {1} process e.g. "haveged" or list of process to kill e.g. "haveged dirmngr" 
kill_process(){
	local named
	local -a list_of_process
	list_of_process=( "$1" )
	
	for named in ${list_of_process[@]}; do
		killall -r $named 2>/dev/null
	done
	
	unset named list_of_process
}

# ${1} option to pass
# ${2} target 
# ${3} where to create it
# ${4} name of the symlinks
make_symlinks(){
	local opt target where named
	opt="${1}"
	target="${2}"
	where="${3}"
	named="${4}"

	ln "${opt}" "${target}" "${where}/${named}"

	unset opt target where named
}


# ${1} opts to pass for the shell
# ${2} pass 0 to set, 1 to unset
shellopts_set_unset(){
	
	local _opts set_unset 
	
	_opts="${1}"
	set_unset="${2}"

	if (( ! $set_unset )); then
		shopt -s "${_opts}"
	else
		shopt -u "${_opts}"
	fi	
}

# save your shell options
shellopts_save(){
	declare -rg SHELL_OPTS=$(shopt -p) &>/dev/null
}

# restore your shell options
shellopts_restore(){
	eval "$SHELL_OPTS"
}
