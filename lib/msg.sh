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
#
# msg.sh - functions for outputting messages

##		Shell color 

unset bold reset red bred green bgreen yellow byellow blue bblue
bold=$(tput bold)
reset=$(tput sgr0)
red=$(tput setaf 1)
bred=${bold}$(tput setaf 1)
green=$(tput setaf 2)
bgreen=${bold}$(tput setaf 2)
yellow=$(tput setaf 3)
byellow=${bold}$(tput setaf 3)
blue=$(tput setaf 4)
bblue=${bold}$(tput setaf 4)

# new output

out_debug() {
	if (( $DEBUG )); then
		printf "%s" "${FUNCNAME[3]}" >&1
 	fi
}
out() {
	local msg="${1}" color="${2}"
	printf "%s %s\n" "${color}:$(out_debug):${reset}" "$msg" >&1
}
out_void() {
	printf "%s\n" ""
}
out_menu_title() {
	local msg="${1}"
	printf "%s\n" "${bblue}${msg}${reset}" >&1
}
out_menu_list() {
	local msg="${1}"
	printf "%s\n" "${bold}${msg}${reset}" >&1
}
out_action() {
	local msg="${1}"
	out "${msg}" "${bold}"
}
out_valid() {
	local msg="${1}"
	out "${msg}" "${bgreen}"
}
out_notvalid(){
	local msg="${1}"
	out "${msg}" "${byellow}"
}
out_error() {
	local msg="${1}"
	out "${msg}" "${bred}"
}
out_answer() {
	out "Please answer y or n :" "${bblue}"
}
out_info() {
	local msg="${1}"
	out "${msg}" "${bblue}"
}

## keep old function for compatibility reason



echo_bold(){
	local msg=$1; shift 
	printf "${bold}${msg}${reset}\n" "${@}" >&1
}
echo_info(){
	local msg=$1; shift 
	printf "${byellow}==>>${msg} ${reset}\n" "${@}" >&1
}
echo_info_menu(){
	local msg=$1; shift 
	printf "${byellow}${msg} ${reset}\n" "${@}" >&1
}
echo_retry(){
	local msg=$1; shift 
	printf "${bblue}==>>${msg} ${reset}\n" "${@}" >&1
}
echo_valid(){
	local msg=$1; shift 
	printf "${bgreen}    ->${msg} ${reset}\n" "${@}" >&1
}
echo_notvalid(){
	local msg=$1; shift 
	printf "${byellow}    ->${msg} ${reset}\n" "${@}" >&1
}
echo_display(){
	local msg=$1; shift 
	printf "${bold}==>>${msg} ${reset}\n" "${@}" >&1
}
echo_error(){
	local msg=$1; shift 
	printf "${bred}    ->${msg} ${reset}\n" "${@}" >&2
}
answer(){
	echo_retry " Please answer y or n :"
}
