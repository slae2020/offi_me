#!/usr/bin/env bash

source declarations.sh
source checker.sh
source tester.sh

# Define standardnames
declare config_stdname="config.xml"

# Define general parameters for config-file
declare -A script_=(
    [dir]=$(cd -- "$(dirname -- "$(readlink -f "$0")")" &> /dev/null && pwd)"/"
    [name]=$(basename "$(readlink -f "$0")" .sh)
    [config]="$config_stdname"
)

#init_messenger
messenger_top_text=${script_[name]^^*}

# Function to extract configuration single values one by one
extract_config_values() {
    local -n config_ref=$1
    local -n config_def=$2

    for name_element in "${!config_ref[@]}"; do
        # Get only values from conf-file when empty
        if [[ -z ${config_ref["$name_element"]} ]]; then
            config_ref["$name_element"]=$(xml_grep "$name_element" "${script_[config]}" --text_only 2>/dev/null)
        fi
        # Check if still empty use std-value
        if [[ -z ${config_ref["$name_element"]} ]];  then
            config_ref["$name_element"]="${config_def["$name_element"]}"
        fi
        # Warn if xml-tag is missing or empty
        if [[ -z "${config_ref[$name_element]}" && ! $name_element =~ "\." ]]; then
            [[ $is_test_mode -gt 0 ]] && echo "(t) Warning (8) for '$name_element': no value from config file \n${script_[config]}" || \
            message_exit "Warning for '$name_element': no value from config file \n${script_[config]}" 8
            unset ${config_ref[$name_element]}
        fi
    done
}

# Function to replace all occurrencies
replace_all_strings() {
    local fullstring=$1
    local old_substrg=$2
    local new_substrg=$3
    if [[ $fullstring =~ [$old_substrg] ]]; then
        fullstring=$(echo "$fullstring" | sed "s|$old_substrg|$new_substrg|g")
    fi
    echo $fullstring
}

# Function to replace specific placeholders after reading
replace_placeholders() {
    local -n ref=$1
    for ((k = 0; k < ${#id[@]}; k++)); do
        for ((j = ${#attribution[@]} - 1; j >= 0; j--)); do
            ref[k]=$(replace_all_strings "${ref[k]}" "\$${attribution[j]}" "${config_elements[${attribution[j]}]}")
            if [[ ${ref[k]} =~ "\\." ]]; then
                unset ref[k]
            fi
        done
    done
}

# Functions to start
# Extract IDs
read_identifier(){
    local -n option_ref=$1

    option_ref=($(xml_grep "id" "${script_[config]}" --text_only))

    # Check if found entries are integers
    for element in "${option_ref[@]}"; do
        if ! [[ "$element" =~ ^[0-9]+$ ]]; then
            message_exit "Config-Error: entry '$element' in config-file has to be an integer!" 32
            exit
        fi
    done
}

# Extract options like names, paths etc.
read_alloptions() {
    local cfg_name=$1
    local -i num_options=0

    # Subfunction for single optis
    read_options() {
        local -n option_ref=$1
        if [ -z "${option_ref[0]}" ]; then
            unset option_ref[0]
        else
            option_ref=($(xml_grep "${option_ref[0]}" "${script_[config]}" --text_only))
            replace_placeholders option_ref
        fi
        num_options=$(( $num_options + ${#option_ref[@]} ))
    }

    # start read all options
    read_identifier id
    num_ids=${#id[@]}
    if [[ $num_ids -eq 0 ]]; then
        message_test_exit 1 "Missing data: Config-file '$cfg_name' has no item." 44
    fi

    read_options opti1
    read_options opti2
    read_options opti3
    read_options opti4
    read_options opti5
    read_options opti6
    read_options opti7

    message_test_exit "$(( $num_options % $num_elements ))" \
                      "Missing data: Config-file '$cfg_name' with '$num_options MOD $num_elements' item(s) is not well-filled." 45
}

# Reading configuration completed
done_configuration() {
[[ $is_test_mode -gt 0 ]] && echo "(t) File "$1" cmdNr-->$cmdNr<\n"
[[ $is_test_mode -gt 0 ]] && display_options 3

    message_notification "Reading configuration file done!" 1
}

# Reading configuration file
read_configuration() {
    check_scriptpath_is_set ${1:-$config_stdname} script_

    # Start
    message_notification "Reading configuration file \n\n${script_[config]}." 1

    # Get general config values
    extract_config_values config_elements config_std

    ## Replace placeholders from config & Ensure the progs ares set
    for ((i = 0; i < ${#attribution[@]}; i++)); do
        if [[ ${attribution[i]} =~ "dialog_" ]]; then
            config_elements[${attribution[i]}]=$(replace_all_strings "${config_elements[${attribution[i]}]}" "\$version1" "${config_elements[version1]}")
            config_elements[${attribution[i]}]=$(replace_all_strings "${config_elements[${attribution[i]}]}" "\$version2" "${config_elements[version2]}")
        fi
        if [[ ${attribution[i]} =~ "_prog" ]]; then
            check_prog "${config_elements[${attribution[i]}]}"
        fi
    done

    # Get special config values
    read_alloptions ${script_[config]}

    # End
    done_configuration ${script_[config]}
}

[[ $is_test_mode -gt 0 ]] && echo "(t) start"

# Necessary check
if [[ -z "$config_stdname" ]]; then
        message_exit "Error: Standard path is not set." 1
        exit
fi

return

# exex test
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
is_test_mode=1

read_configuration "/home/stefan/perl/Bakki-the-stickv1.2beta/config_2408.xml"

exit 0


## junk
read_options2() {
    local -n option_ref=$1

    local num=$2

    if [ -z "${option_ref[0]}" ]; then
        unset option_ref[0]
    else
        option_ref=($(xml_grep "${option_ref[0]}" "${script_[config]}" --text_only))
        replace_placeholders option_ref
    fi

    #return new number of items
    echo $(( $num + ${#option_ref[@]} ))
    #num=$(( $num + ${#option_ref[@]} ))
}

echo .
echo $num_options
    #read_options opti2 $num_options && echo $?
    #num_options=$(read_options opti3 $num_options)
    #num_options=$(read_options opti4 $num_options)
    #num_options=$(read_options opti5 $num_options)
    #num_options=$(read_options opti6 $num_options)
    #num_options=$(read_options opti7 $num_options)

    #num_options=$(( $(count_options opti1 $num_options) ))
    #num_options=$(( $num_options + ${#opti1[@]} ))
    #read_options opti2
    #num_options=$(( $(count_options opti2 $num_options) ))
    #read_options opti3
    #num_options=$(( $(count_options opti3 $num_options) ))
    #read_options opti4
    #num_options=$(( $(count_options opti4 $num_options) ))
    #read_options opti5
    #num_options=$(( $(count_options opti5 $num_options) ))
    #read_options opti6
    #num_options=$(( $(count_options opti6 $num_options) ))
    #read_options opti7
    #num_options=$(( $(count_options opti7 $num_options) ))

# Validate and modify a path based on certain conditions
check_scriptpath_is_set2() {
    local local_cust_path=$1          # The custom path to use if provided
    local -n local_script=${2:-nil}   # The array where scriptpath is stored
    local local_dir=$(cd -- "$(dirname -- "$(readlink -f "$0")")" &> /dev/null && pwd)"/"

    # Modify local_cust_path if its directory is the current directory
    if [[ "$(dirname "$local_cust_path")" == "." ]]; then
        local_cust_path="$local_dir$local_cust_path"
    fi

    check_path "$local_cust_path"
    #return:
    local_script[config]="$local_cust_path"
}

    if [[ -z "$(cd -- "$(dirname -- "$(readlink -f "${script_[config]}")")" &> /dev/null && pwd)" ]]; then
        xfile="${script_[dir]}${script_[config]}"
    else
        xfile="${script_[config]}"
    fi

[[ $is_test_mode -gt 0 ]] && echo "(t)"${script_[config]}
