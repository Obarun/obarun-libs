#!@BINDIR@/bash
# Copyright (c) 2015-2017 Eric Vidal <eric@obarun.org>
# All rights reserved.
# 
# This file is part of Obarun. It is subject to the license terms in
# the LICENSE file found in the top-level directory of this
# distribution and at https://github.com/Obarun/obarun-libs/LICENSE
# This file may not be copied, modified, propagated, or distributed
# except according to the terms contained in the LICENSE file.
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
	
	out_action "Start pacman-key"
	haveged -w 1024
	
	pacman-key --init ${gpg_opts}
	
	for named in ${name_to_populate[@]};do
		out_notvalid "populate $named"
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
	
	out_action "Check if gpg key exist"	
	pacman-key -u ${gpg_opts} &>/dev/null
	
	if (( $? ));then
		out_notvalid "Gpg doesn't exist, create it..."
		if [[ ! -z ${gpg_opts} ]]; then
			pac_key "archlinux obarun" ${gpg_to_pass}
		else
			pac_key "archlinux obarun"
		fi
	else
		out_action "Gpg key exist, Refresh it..."
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
			out_action "Check if $named gpg signature exist"
			if ! pacman-key --list-keys "$named" $gpg_opts &>/dev/null; then
				out_notvalid "Add $named gpg signature, please wait"
				pacman-key -r "$named" $gpg_opts
				pacman-key --lsign-key "$named" $gpg_opts
			else
				out_action "$named gpg signature already exist"
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
			out_notvalid "Create necessary directory"
			mkdir -p -m0755 "$work_dir/update_package"
		fi
		
		build_dir="$work_dir/update_package"
	}
	
	# make package
	make_package(){
		#user_add "usertmp"
		chown -R "${OWNER}":users "$build_dir"
		cd "$build_dir/$_pkgname"
		out_notvalid "Launch makepkg and install the new version if exist"
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
			out_valid "Git already up to date, nothing to do"
			sleep 2
			return 0
		else
			# local is out of date, update it
			out_notvalid "Local branch is out-of-date, update it..."
			git reset --hard origin/master || die " Impossible to reset origin/master"	
			git pull origin master || die " Impossible merge origin to master branch"	
			return 1
		fi
	}
	
	# check current version 
	check_version(){
		cd "$build_dir/$_pkgname"
		
		local rc curr_version git_version curr_tag git_tag curr_commit git_commit
		
		curr_version=$(pacman -Qi $_pkgname | grep "Version" | awk -F": " '{print $2}' | sed 's:-1::')
		git_version=$(git describe --tags | sed -e 's/-/+/g;s/^v//')
		curr_tag="${curr_version%%+g*}"
		git_tag="${git_version%%+g*}"
		curr_commit="${curr_version##*+g}"
		git_commit="${git_version##*+g}"
		
		check_update #|| die " Impossible to udpdate $_pkgname"
		
		if (( $? )); then
			out_action "$_pkgname is out of date, updating please wait"
			make_package || die " Impossible to make the package"
			rc=1
		fi
		if [[ $rc != 1 ]]; then			
			rc=""
			if [[ "${curr_tag}" < "${git_tag}" ]] ; then
				make_package || die " Impossible to make the package"
				rc=1
			elif [[ $rc != 1 ]]; then
				if [[ "${curr_commit}" != "${git_commit}" ]];then
					make_package || die " Impossible to make the package"
				fi
			fi
		fi
		
		unset rc curr_version git_version curr_tag git_tag curr_commit git_commit
	}
		
	make_build_dir
	
	out_action "Check update for $_pkgname"
	
	if ! [ -d "$build_dir/$_pkgname" ]; then
		cd "$build_dir"
		out_notvalid "Clone repository form ${green}[$_adress]${reset}"
		git clone "$_adress"
		make_package || die " Impossible to make the package"
	else
		check_version || die " Impossible to check the current version"
	fi	
	
	cd $_oldpwd
	
	unset status _pkgname build_dir rc work_dir _olpwd _adress
}
