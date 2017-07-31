#!/usr/bin/bash
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
