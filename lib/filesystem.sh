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
	local rep action
	rep="$1"
	action="$2"
	
	_mount(){
		echo_notvalid " Mounting $4"
		mount "$@" 
	}
	
	_umount(){
		echo_notvalid " Unmounting $1"
		umount "$@"
	}
			
	if [[ "$action" == "mount" ]]; then
		echo_display " Check mounted filesystem on $rep"
		if ! [[ $(mount | grep "$rep"/proc) ]]; then
			_mount -t proc proc "$rep/proc" -o nosuid,noexec,nodev 
			_mount -t sysfs sys "$rep/sys" -o nosuid,noexec,nodev,ro 
			_mount -t devtmpfs dev "$rep/dev" -o mode=0755,nosuid
			_mount -t devpts devpts "$rep/dev/pts" -o mode=0620,gid=5,nosuid,noexec
			_mount -t tmpfs shm "$rep/dev/shm" -o mode=1777,nosuid,nodev
			_mount -t tmpfs run "$rep/run" -o nosuid,nodev,mode=0755
			_mount -t tmpfs tmp "$rep/tmp" -o mode=1777,strictatime,nodev,nosuid
		else
			echo_valid " Filesystem already mounted in ${rep}"
		fi
	fi
	if [[ "$action" == "umount" ]]; then
		echo_display " Check mounted filesystem"
		if [[ $(mount | grep "$rep"/proc) ]]; then
			_umount "$rep/proc"
			_umount "$rep/sys"
			_umount "$rep/dev/pts"
			_umount "$rep/dev/shm"
			_umount "$rep/run"
			_umount "$rep/tmp"
			_umount "$rep/dev"
		else
			echo_valid " Filesystem not mounted in ${rep}"
		fi
	fi
	unset rep action
}
