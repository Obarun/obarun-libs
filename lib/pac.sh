#!/usr/bin/bash
#
# Authors:
# Eric Vidal <eric@obarun.org>
#
# Copyright (C) 2016 Eric Vidal <eric@obarun.org>
#
# This script is under license BEER-WARE
# "THE BEER-WARE LICENSE" (Revision 42):
# <eric@obarun.org> wrote this file.  As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.   Eric Vidal
#
# pac.sh  - functions for deal with package

##		Generate key

# {1} name to populate e.g. "obarun" or a list "archlinux obarun"
# {2} gpg directory to use, can be empty

pac_key(){
	
	local gpg_opts named 
	local -a name_to_populate
	
	name_to_populate=( "$1" )

	if [[ ! -z "$2" ]]; then
		gpg_opts="--gpgdir $2"
	fi
	
	echo_display " Start pacman-key"
	haveged -w 1024
	
	pacman-key --init ${gpg_opts}
	
	for named in ${name_to_populate[@]};do
		echo_notvalid "populate $named"
		eval pacman-key --populate "$named" ${gpg_opts}
	done
	
	#kill all process before existing, this avoid trouble to umount the rootdir
	kill_process "gpg-agent"
	
	unset gpg_opts named name_to_populate
}

# ${1} gpg directory to use, can be empty
check_gpg(){
	
	local gpg_opts named gpg_to_pass
		
	if [[ ! -z "${1}" ]]; then
		gpg_opts="--gpgdir ${1}"
		gpg_to_pass="${1}"
	fi
	
	echo_display " Check if gpg key exist"	
	pacman-key -u ${gpg_opts} &>/dev/null
	
	if (( $? ));then
		echo_notvalid " Gpg doesn't exist, create it..."
		if [[ ! -z ${gpg_opts} ]]; then
			pac_key "archlinux obarun" ${gpg_to_pass}
		else
			pac_key "archlinux obarun"
		fi
	else
		echo_valid " Gpg key exist, Refresh it..."
		pacman-key -u ${gpg_opts}
	fi
	
	unset gpg_opts gpg_to_pass
}


# ${1} key or list of key to add e.g "7B45DAAC" or "7B45DAAC 0375F9B2"
# ${2} gpg directory to use, can be empty
add_gpg(){
	local gpg_opts named 
	local -a key_to_add
	
	key_to_add=( "$1" )
	
	if [[ ! -z "$2" ]]; then
		gpg_opts="--gpgdir $2"
	fi
	
	# pacman-key -r failed without /root/.gnupg
	# create it by dirmngr
	# TODO: find a turn around
	if [[ ! -d /root/.gnupg ]]; then
		dirmngr --daemon &>/dev/null #& kill_process "dirmngr"
	fi
	
	# start haveged to speed up the process
	haveged -w 1024
	
	# add the specified key
	if [[ ! -z ${key_to_add[@]} ]]; then
		for named in ${key_to_add[@]}; do
			echo_display " Check if $named gpg signature exist"
			if ! pacman-key --list-keys "$named" $gpg_opts &>/dev/null; then
				echo_notvalid " Add $named gpg signature, please wait"
				pacman-key -r "$named" $gpg_opts
				pacman-key --lsign-key "$named" $gpg_opts
			else
				echo_valid " $named gpg signature already exist"
			fi
		done
	fi
	
	kill_process "dirmngr gpg-agent"
	
	unset gpg_opts named key_to_add
}

##		Update package automaticaly

# ${1} name of the package to update
# ${2} working directory to store the data
# ${3} address to the git repository

pac_update(){
	
	local status _pkgname build_dir rc work_dir _olpwd _adress
	_pkgname="${1}"
	work_dir="${2}"
	_adress="${3}"
	_oldpwd=$(pwd)
	rc=0
	
	# make build_dir directory
	make_build_dir(){
		if ! [ -d "$work_dir/update_package" ]; then
			echo_notvalid " Create necessary directory"
			mkdir -p -m0755 "$work_dir/update_package"
		fi
		
		build_dir="$work_dir/update_package"
	}
	
	# make package
	make_package(){
		#user_add "usertmp"
		chown -R "${OWNER}":users "$build_dir"
		cd "$build_dir/$_pkgname"
		echo_notvalid " Launch makepkg and install the new version if exist"
		su "${OWNER}" -c "makepkg -Cfi --nosign --noconfirm --needed"
		sleep 2
	}
	
	# check git repositories
	check_update(){
		# check the remote branch
		git fetch origin master || die " Impossible to fetch origin"	
			
		# emtpy status variable means up to date
		status=$(git diff master origin/master)
		
		if [[ -z "${status}" ]]; then
			echo_valid " Git already up to date, nothing to do"
			sleep 2
			return 0
		else
			# local is out of date, update it
			echo_notvalid " Local branch is out-of-date, update it..."
			git reset --hard origin/master || die " Impossible to reset origin/master"	
			git pull origin master || die " Impossible merge origin to master branch"	
			return 1
		fi
	}
	
	# check current version 
	check_version(){
		cd "$build_dir/$_pkgname"
		
		local curr_version git_version
		curr_version=$(pacman -Qi $_pkgname | grep "Version" | awk -F": " '{print $2}' | sed 's:-1::')
		git_version=$(git rev-parse --short HEAD)
		
		check_update #|| die " Impossible to udpdate $_pkgname"
		
		if (( $? )); then
			echo_display " $_pkgname is out of date, updating please wait"
			make_package || die " Impossible to make the package"
			rc=1
		fi
		if ! [[ "$curr_version" == "$git_version" ]]; then
			if [[ $rc == 1 ]]; then
				unset rc
			else
				make_package || die " Impossible to make the package"
			fi
		fi
	}	
		
	make_build_dir
	
	echo_display " Check update for $_pkgname"
	
	if ! [ -d "$build_dir/$_pkgname" ]; then
		cd "$build_dir"
		echo_notvalid " Clone repository form ${green}[$_adress]${reset}"
		git clone "$_adress"
		make_package || die " Impossible to make the package"
	else
		check_version || die " Impossible to check the current version"
	fi	
	
	cd $_oldpwd
	
	unset status _pkgname build_dir rc work_dir _olpwd _adress
}
