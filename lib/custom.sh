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
# custom.sh - function for divers customization

##		Generate fstab
# ${1} mountpoint directory

gen_fstab(){
	local _directory
	_directory="${1}"
	
	out_action "Generate fstab"
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
		out_action "Create the ${named} user"
		useradd -m -g users -G "wheel,disk,storage,optical,floppy,network" -s /bin/bash "${named}"
	fi
	
	unset named
}

# ${1} user name to delete

user_del(){
	
	local named
	named="${1}"
	
	out_action "Removing user : ${named}"
	userdel -r ${named} 
		
	unset named
}
