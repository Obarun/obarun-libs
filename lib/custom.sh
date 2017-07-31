#!/usr/bin/bash
# This script is under license BEER-WARE
# "THE BEER-WARE LICENSE" (Revision 42):
# <eric@obarun.org> wrote this file.  As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.   Eric Vidal
#
# custom.sh - function for divers customization

##		Generate fstab
# ${1} mountpoint directory

gen_fstab(){
	local _directory
	_directory="${1}"
	
	echo_display " Generate fstab"
	genfstab -p "$_directory" > "$_directory/etc/fstab" || die " Impossible to generate fstab"

	unset _directory
}

#		Edit a file
# ${1} name of the file to edit
# ${2} path to the named file
# ${3} name of the editor program

edit_file(){
	local _path _file _editor
	_file="${1}"
	_path="${2}"
	_editor="${3}"
	
	"$_editor" "$_path"/"$_file"

	unset _path _file _editor
}

## 		Create temporary users
# ${1} user name to create

user_add(){
	
	local named
	named="${1}"
	
	if ! [[ $(awk -F':' '{ print $1}' /etc/passwd | grep ${named}) ]]; then
		echo_display " Create the ${named} user"
		useradd -m -g users -G "wheel,disk,storage,optical,floppy,network" -s /bin/bash "${named}"
	fi
	
	unset named
}

# ${1} user name to delete

user_del(){
	
	local named
	named="${1}"
	
	echo_display " Removing user : ${named}"
	userdel -r ${named} 
		
	unset named
}
