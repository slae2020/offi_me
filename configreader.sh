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

# Validate and modify a path based on certain conditions
check_scriptpath_is_set() {
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
            if [[ -z ${ref[k]} ]]; then
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
read_options() {
    local -n option_ref=$1

    if [[ -n ${option_ref[0]} ]]; then
        option_ref=($(xml_grep "${option_ref[0]}" "${script_[config]}" --text_only))
        replace_placeholders option_ref
    fi
}

# Extract elements <>''
count_options() {
    local -n option_ref=$1
    count=$2

    if [[ -n ${option_ref[0]} ]]; then
        count=$(( $count + ${#option_ref[@]} ))
    fi
    echo $count
}

# Extract id, names, paths etc.
read_alloptions() {
    local -i num_options=0
    rate=0

    read_identifier id
    rate=$(( $(count_options id 0) ))
    if [ $rate -eq 0 ]; then
        message_exit "Missing data: Config-file '$1' has no item." 44
    fi

    read_options opti1
    num_options=$(( $(count_options opti1 $num_options) ))
    read_options opti2
    num_options=$(( $(count_options opti2 $num_options) ))
    read_options opti3
    num_options=$(( $(count_options opti3 $num_options) ))
    read_options opti4
    num_options=$(( $(count_options opti4 $num_options) ))
    read_options opti5
    num_options=$(( $(count_options opti5 $num_options) ))
    read_options opti6
    num_options=$(( $(count_options opti6 $num_options) ))
    read_options opti7
    num_options=$(( $(count_options opti7 $num_options) ))

    # Check correct count of options
    rate=$(( $num_options % $num_elements ))
    if [ $rate -ne 0 ]; then
        message_exit "Missing data: Config-file '$1' with '$num_options MOD $num_elements' item(s) is not well-filled." 45 #???
    fi
}

# Reading configuration completed
done_configuration() {
[[ $is_test_mode -gt 0 ]] && echo "(t)Konfiguration eingelesen! >$cmdNr<\n"
[[ $is_test_mode -gt 0 ]] && echo "(t)Starte....${script_[name]} (Testversion) ......\n"
[[ $is_test_mode -gt 0 ]] && display_options 4
[[ $is_test_mode -gt 0 ]] && message_notification "(t)Configuration \n'$1'\nloaded!.      >$cmdNr<\n" 1 &
}

# Reading configuration file
read_configuration() {
    # Exit if local_std_path is empty
    if [[ -z "$config_stdname" ]]; then
        echo "Error: Standard path is not set." >&2
        exit 1
    else
        check_scriptpath_is_set ${1:-$config_stdname} script_
    fi

    if [[ -z "$(cd -- "$(dirname -- "$(readlink -f "${script_[config]}")")" &> /dev/null && pwd)" ]]; then
        xfile="${script_[dir]}${script_[config]}"
    else
        xfile="${script_[config]}"
    fi

    [[ $is_test_mode -gt 0 ]] && message_notification "Reading configuration file \n\n${script_[config]}." 1 && echo "(t) start"

    # Call function to extract values
    extract_config_values config_elements config_std

    ## Replace placeholders from config & Ensure the progs ares set
    for ((i = 0; i < ${#attribution[@]}; i++)); do
        if [[ ${attribution[i]} =~ "dialog_" ]]; then
            config_elements[${attribution[i]}]=$(replace_all_strings "${config_elements[${attribution[i]}]}" "\$version1" "${config_elements[version1]}") #????
            config_elements[${attribution[i]}]=$(replace_all_strings "${config_elements[${attribution[i]}]}" "\$version2" "${config_elements[version2]}")
        fi
        if [[ ${attribution[i]} =~ "_prog" ]]; then
            check_prog "${config_elements[${attribution[i]}]}"
        fi
    done

    read_alloptions ${script_[config]}

    done_configuration ${script_[config]}

    [[ $is_test_mode -gt 0 ]] && echo "(t)"${script_[config]}
}

return

# exex test
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
is_test_mode=1

 for ((jj = ${#attribution[@]}; jj >= 0; jj--)); do
            echo $jj
        done


read_configuration "/home/stefan/perl/Bakki-the-stickv1.2beta/config_2408.xml"

exit 0
