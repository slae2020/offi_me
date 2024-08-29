#!/usr/bin/env bash

source messenge.sh

declare -i is_test_mode=1  # 1 for test mode, 0 for normal operation

# Define a placeholder space character for use in a configuration file
declare -r placeholder_space="#x0020"

# Define associative arrays with desired elements & first allocation
declare -A script_=(
    [dir]=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"/"
    [name]=$(basename "${BASH_SOURCE[0]}")
    [config]='config.xml'
)
declare -A config_elements=(
    [version]=''
    [version_strg]=''
    [lang]=''
    [title_strg]=''
    [menue_strg]=''
    [config_strg]=''
    [editor_prog]=''
    [prog_strg]=''
    [home_directory]=''
    [storage_location]=''
    [standard_path]=''
)
# Define parameter of template-group-elements
declare -a id
declare -a template_name
declare -a template_prog
declare -a template_param
declare -a template_path
declare -a template_file
declare -i num_template_elements=5

# Workparameters
declare -i cmdNr=0 && unset cmdNr
declare selection=""

# Function to extract configuration single values from XML
extract_config_values() {
    local -n config_ref=$1

    for element in "${!config_ref[@]}"; do
        # Get only values from conf-file when empty
        if [[ -z ${config_ref["$element"]} ]]; then
            config_ref["$element"]=$(xml_grep "$element" "${script_[config]}" --text_only 2>/dev/null)
        fi
        # Warn if xml-tag is missing or empty
        if [[ -z "${config_ref[$element]}" ]]; then
            [[ $is_test_mode -gt 0 ]] && echo "Warning (8) for '$element': no value found in config file ${script_[config]}" || \
            message_exit "Warning for '$element': no value in config file ${script_[config]}" 8
            unset ${config_ref[$element]}
        fi
    done
}

# Function to extract configuration arrays from XML
extract_options_values() {
    local element="$1"
    xml_grep $element "${script_[config]}" --text_only
}

# Function to replace defined placeholder from config-file into string
replace_placeholder_strg() {
    local input=$1
    local placeholder=$2
    local replacement=$3
    if [[ $input =~ [$placeholder] ]]; then
        input=$(echo "$input" | sed "s|$placeholder|$replacement|g")
    fi
    echo $input
}

# Function to replace specific placeholders after reading
replace_placeholders() {
    local -n ref=$1
    for ((k = 0; k < ${#id[@]}; k++)); do
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "~" "${config_elements[home_directory]}")
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "\$homeVerz" "${config_elements[home_directory]}")
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "\$officeprog" "${config_elements[prog_strg]}")
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "\$stdpath" "${config_elements[standard_path]}")
        ref[k]=$(replace_placeholder_strg "${ref[k]}" "$placeholder_space" " ")
    done
}

# Error-window & exit with error number; default-value 1 when missing; wait for response except for err==0
message_exit() {
    local txt=$1
    local err=$2
    err="${err:-1}"
    if [[ $err -gt 0 ]]; then
        zenity --error --width "250" --title ${script_[name]} --text="$txt ($err)"
    fi
    echo $err
}

# Function to check if a path is readable
check_path() {
    local path=$1
    local name=$2

    if [[ $path =~ "/media/" ]]; then
        check_stick "$path" "$name"
    fi
    if [[ $path =~ "mnt/" ]]; then
        check_mount "$path"
    fi
    if [[ !  -r "$path" ]]; then
        path="${path:-   }"
        message_exit "Config-Error: Path \n'$path'\n is not readable." 23
        exit
    fi
}
# Function to check availibility of a program
check_prog() {
    local prog_name=$1

    if [[ ! -x "$(command -v $prog_name)" ]]; then
        message_exit "Config-Error: program '$prog_name' not found." 24
        exit
    fi
}

# Display options for selection
display_options () {
    echo .
echo $cmdNr

#for i in "${!config_elements[@]}"; do
    #echo -n "$i -->"
    #echo ${config_elements[$i]}
#done

echo .
# Debugging output
#echo "Extracted IDs: ${id[@]}"
#echo "Extracted Names: ${template_name[@]}"
#echo "Extracted progs: ${template_prog[@]}|"
#echo "Extracted param: ${template_param[@]}"
#echo "Extracted template_paths: ${template_path[@]}"
#echo "Extracted template_file: ${template_file[@]}"
echo "Wahl: $selection""<- cmdNr->"$cmdNr"<"
}

# Start of script execution; # Reading arguments from commandline # -c "$cfile" -e geany -n automatisch# -v verbose -h help
while getopts ':c:e:n:vh' OPTION; do
    case "$OPTION" in
        c) script_[config]=${OPTARG} ;;
        e) config_elements[editor_prog]=${OPTARG} ;;
        n) cmdNr=${OPTARG} ;;
        v) is_test_mode=0 ;;
        ?|h) message_exit "Usage: $(basename $0) [-c Konfiguration.xml] [-e Editor] [-n id] [-v] [-h] \n" 11; exit ;;
    esac
done

# Reading configuration file

# Ensure the configuration file is set, defaulting to "config.xml" if not provided
[[ -z "${script_[config]}" ]] && script_[config]="${script_[config]:-config.xml}"
check_path "${script_[dir]}${script_[config]}"

# Call function to extract values
extract_config_values config_elements

# Replace placeholders from config
config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$version" "${config_elements[version]}")
config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$verstxt" "${config_elements[version_strg]}")

# Ensure the editor-prog is set, defaulting to "gedit" if not provided & checking existence
[[ -z "${config_elements[editor_prog]}" ]] && config_elements[editor_prog]="${config_elements[editor_prog]:-gedit}"
check_prog "${config_elements[editor_prog]}"
check_prog "${config_elements[prog_strg]}" 

# Extract IDs, names, paths etc.
id=($(extract_options_values 'id'))

# Check if id are integers
for element in "${id[@]}"; do
    if ! [[ "$element" =~ ^[0-9]+$ ]]; then
        message_exit "Config-Error: identifier '$element' in config-file has to be an integer!" 32
        exit
    fi
done

template_name=($(extract_options_values 'name')) && replace_placeholders template_name
template_prog=($(extract_options_values 'prog')) && replace_placeholders template_prog
template_param=($(extract_options_values 'param')) && replace_placeholders template_param
template_path=($(extract_options_values 'template_path')) && replace_placeholders template_path
template_file=($(extract_options_values 'template_file')) && replace_placeholders template_file

# Check if the number of templates matches the number of IDs
if [ $(($((${#template_name[@]} + ${#template_prog[@]} + ${#template_param[@]} + ${#template_path[@]} + ${#template_file[@]})) / num_template_elements)) -ne ${#id[@]} ]; then
    message_exit "Missing data: Config-file is not well-filled." 45
    exit
fi

[[ $is_test_mode -gt 0 ]] && echo "Konfiguration eingelesen! >$cmdNr<\n"
[[ $is_test_mode -gt 0 ]] && echo "Starte....(Testversion) ......\n"
[[ $is_test_mode -gt 0 ]] && display_options

# Checking command-number if given
if [[ -n "$cmdNr" ]]; then
    if [[ ${id[@]} =~ "$cmdNr" ]]; then
        selection=$cmdNr
    else
        message_exit "Error with commandline: Case '$cmdNr' not defined." 66
        exit
    fi
fi

# Loop until a selection is made
while [ -z "$selection" ]; do
    selection=$(zenity --height "510" --width "450" \
        --title "${config_elements[title_strg]}" --text "${config_elements[menue_strg]}" \
        --list --column="Eintraege" "${template_name[@]}" "${config_elements[config_strg]}")
    if [ $? -ne 0 ]; then
        message_exit "Dialog canceled by user." 0
        exit
    fi
done

# Match foundIndex to selection
for i in "${!template_name[@]}"; do
    if [[ "${template_name[$i]}" == "$selection" ]]; then
        foundIndex=$i
        break
    fi
    if [ "${id[$i]}" -eq "$selection" >/dev/null 2>&1 ]; then
        foundIndex=$i
        break
    fi
done

# Check if foundIndex is set and within bounds (to make sure)
if [[ -n $foundIndex && foundIndex -ge 0 && foundIndex -lt ${#template_name[@]} ]]; then
    selection=${template_name[$foundIndex]}
fi

[[ $is_test_mode -gt 0 ]] && echo "Selected: $selection" # Testversion
[[ $is_test_mode -gt 0 ]] && echo $selection"+++ "$foundIndex" +++"${id[$foundIndex]}"##"${template_prog[$foundIndex]}"<>""${template_path[$foundIndex]}${template_file[$foundIndex]}" #Testoption

# Execution with the selected option
case $selection in
    ${config_elements[prog_strg]})
        command_to_execute="${config_elements[prog_strg]}" #&& check_prog "$command_to_execute"
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    ${config_elements[config_strg]})
        xfile="${script_[dir]}${script_[config]}"
        check_path "$xfile" "nil"
        command_to_execute="${config_elements[editor_prog]} $xfile"
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    ${template_name[$foundIndex]})
        if [[ ${template_file[$foundIndex]} =~ ".ott" ]]; then
            check_path "${template_path[$foundIndex]}${template_file[$foundIndex]}" "nil"
        fi
        command_to_execute="${template_prog[$foundIndex]} ${template_path[$foundIndex]}${template_file[$foundIndex]}"
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    *)
        message_exit "General error: case '$selection' not defined." 99
        exit
        ;;
esac

exit 0

## ab hier junk

#echo "scrpt_dir is:"${script_[dir]}
#echo "scrpt_name is:"${script_[name]}
#echo "cofg_file is:"${script_[config]}

#echo .
#echo ${script_[dir]}${script_[name]}
#echo ${script_[dir]}${script_[config]}
#echo .

