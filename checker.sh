#!/usr/bin/env bash

source dialog.sh

declare dir_usb="media/"
declare dir_mnt="mnt/"

# Function to check if a path is readable
check_path() {
    local path=$1
    local name=$2

    if [[ $path =~ $dir_usb ]]; then
        check_usb "$path" "$name"
    fi
    if [[ $path =~ $dir_mnt ]]; then
        check_mount "$path"
    fi
    if [[ ! -r "$path" ]]; then

        path="${path:-   }"
        #message_exit "Config-Error: Path \n'$path'\n is missing or not readable." 21
        #exit
    fi
    #echo "felix"
}

# Function to check if a USB stick is present
check_usb() {
    local stick_path=$1
    local stick_name=$2
    while true; do
        if ls -A "$stick_path" >/dev/null 2>&1; then
            break
        else
            ask_to_continue "'$stick_name' is missing: [  '$stick_path' not found  ]\n\nDo you want to try again?" 22
        fi
    done
}

# Function to check if a network drive is mounted, and attempt to mount it if not
check_mount() {
    local mounted_path=$1
    local test_subdir=$mounted_path"/."
echo $test_subdir

    # Check if the mount-directory is accessible
    if [[ ! -r "$test_subdir" ]]; then
    echo "Jaa"
        # Attempt to mount the directory
        mnt_resp=$(/home/stefan/prog/bakki/mounti/mounter.sh "$mounted_path" )
        if [[ ! "$mnt_resp" == 0 ]]; then
            message_exit "Error: $mnt_resp" 23
            exit
        fi
    fi
}

# Function to check availibility of a program
check_prog() {
    local prog_name=$1

    if [[ ! -x "$(command -v $prog_name)" ]]; then
        message_exit "Config-Error: program '$prog_name' not found." 24
    fi
}

return

#check_usb "/media/slaekim" "SLAE77"

check_mount "/mnt/iserv_laettig/Files"
