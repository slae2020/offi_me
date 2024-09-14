#!/usr/bin/env bash

source configreader.sh

is_test_mode=01

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

read_configuration "${script_[config]}"

# Checking command-number if given & defined
if [[ -n "$cmdNr" ]]; then
    if printf '%s\n' "${id[@]}" | grep -q -w "$cmdNr"; then
        selection=$cmdNr
    else
        message_exit "Error with commandline: Case '$cmdNr' not defined." 66
        exit
    fi
fi

# Loop until a selection is made
while [ -z "$selection" ]; do
    setdisplay 350 450
    selection=$(ask_to_choose "${config_elements[dialog_title]}" "${config_elements[dialog_menue]}" "${config_elements[dialog_column1]}"\
                opti1 "${config_elements[name_stdprg]}" "${config_elements[dialog_config]}")
    if [[ $selection == $is_cancel ]]; then
        message_exit "Dialog canceled by user." 0
        exit
    fi
done
resetdisplay

# Match selectedIndex to selection
for i in "${!opti1[@]}"; do
    if [[ "${opti1[$i]}" == "$selection" ]]; then
        selectedIndex=$i
        break
    fi
    if [ "${id[$i]}" -eq "$selection" >/dev/null 2>&1 ]; then
        selectedIndex=$i
        break
    fi
done

# Check if selectedIndex is set and within bounds (to make sure)
if [[ -n $selectedIndex && selectedIndex -ge 0 && selectedIndex -lt ${#opti1[@]} ]]; then
    selection=${opti1[$selectedIndex]}
fi

[[ $is_test_mode -gt 0 ]] && echo "(t)Selected: $selection"
[[ $is_test_mode -gt 0 ]] && echo "(t)"$selection"+++ "$selectedIndex" +++"${id[$selectedIndex]}"##"${opti2[$selectedIndex]}"<--p3>"${opti3[$selectedIndex]}""
[[ $is_test_mode -gt 0 ]] && echo "(t)##4>"${opti4[$selectedIndex]}"<--5>"${opti5[$selectedIndex]}"<"

# Execution with the selected option
case $selection in
    ${config_elements[std_prog]} | ${config_elements[name_stdprg]})
        command_to_execute="${config_elements[std_prog]}"
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    ${config_elements[dialog_config]})
        command_to_execute="${config_elements[editor_prog]} ${script_[config]}"
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    ${opti1[$selectedIndex]})
        if [[ ${opti5[$selectedIndex]} =~ ".ott" ]]; then
            check_path "${opti4[$selectedIndex]}${opti5[$selectedIndex]}"
        fi
        command_to_execute="${opti2[$selectedIndex]} ${opti3[$selectedIndex]} ${opti4[$selectedIndex]}${opti5[$selectedIndex]}"
        eval $command_to_execute & >/dev/null 2>&1
        ;;
    *)
        message_exit "General error: case '$selection' not defined." 99
        exit
        ;;
esac

exit 0



