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
# filesystem.sh - functions to deal with filesystem

##		check if a directory is a valid mountpoint
# ${1} directory to check
# return rc=0 on success

check_mountpoint(){
	local _directory
	_directory="${1}"
	
	if mountpoint -q "$_directory"; then
		return 0
	else
		return 1
	fi
	
	unset _directory
}

## 		Mount/unmount filesystem
# $1 name of directory to check 
# $2 action to do : mount/umount

mount_umount(){
	local rep action len
	rep="$1"
	action="$2"
	len="${#rep}"
	if [[ "${rep:$len-1:1}" == "/" ]]; then
		rep="${rep%?}"
	fi
	_mount(){
		out_notvalid "Mounting $4"
		mount "$@" 
	}
	
	_umount(){
		out_notvalid "Unmounting $1"
		umount "$@"
	}
			
	if [[ "$action" == "mount" ]]; then
		out_action "Check mounted filesystem on $rep"
		if ! [[ $(mount | grep "$rep"/proc) ]]; then
			_mount -t proc proc "$rep/proc" -o nosuid,noexec,nodev 
		else
			out_valid "$rep/proc already mounted"
		fi
		if ! [[ $(mount | grep "$rep"/sys) ]]; then
			_mount -t sysfs sys "$rep/sys" -o nosuid,noexec,nodev,ro 
		else
			out_valid "$rep/sys already mounted"
		fi
		if ! [[ $(mount | grep "$rep"/dev) ]]; then
			_mount -t devtmpfs dev "$rep/dev" -o mode=0755,nosuid
			_mount -t devpts devpts "$rep/dev/pts" -o mode=0620,gid=5,nosuid,noexec
			_mount -t tmpfs shm "$rep/dev/shm" -o mode=1777,nosuid,nodev
		else
			out_valid "$rep/dev already mounted"
		fi
		if ! [[ $(mount | grep "$rep"/run) ]]; then
			_mount -t tmpfs run "$rep/run" -o nosuid,nodev,mode=0755
		else
			out_valid "$rep/run already mounted"
		fi
		if ! [[ $(mount | grep "$rep"/tmp) ]]; then
			_mount -t tmpfs tmp "$rep/tmp" -o mode=1777,strictatime,nodev,nosuid
		else
			out_valid "$rep/tmp already mounted"
		fi
	fi
	if [[ "$action" == "umount" ]]; then
		out_action "Check mounted filesystem on $rep"
		if [[ $(mount | grep "$rep"/proc) ]]; then
			_umount "$rep/proc"
		else
			out_valid "$rep/proc not mounted"
		fi
		if [[ $(mount | grep "$rep"/sys) ]]; then
			_umount "$rep/sys"
		else
			out_valid "$rep/sys not mounted"
		fi
		if [[ $(mount | grep "$rep"/dev/pts) ]]; then
			_umount "$rep/dev/pts"
		else
			out_valid "$rep/dev/pts not mounted"
		fi
		if [[ $(mount | grep "$rep"/dev/shm) ]]; then
			_umount "$rep/dev/shm"
		else
			out_valid "$rep/dev/shm not mounted"
		fi
		if [[ $(mount | grep "$rep"/run) ]]; then
			_umount "$rep/run"
		else
			out_valid "$rep/run not mounted"
		fi
		if [[ $(mount | grep "$rep"/tmp) ]]; then
			_umount "$rep/tmp"
		else
			out_valid "$rep/tmp not mounted"
		fi
		if [[ $(mount | grep "$rep"/dev) ]]; then	
			_umount "$rep/dev"
		else
			out_valid "$rep/dev not mounted"
		fi
	fi
	unset rep action
}
