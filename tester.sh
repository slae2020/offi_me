#!/usr/bin/env bash

declare -i is_test_mode=0  # 1 for test mode, 0 for normal operation

# Display options for selection
display_options () {
    local select=$1
    echo .
    echo "(t) Display varis for debugging info ($select): "

    case $select in
        1) echo $cmdNr ;;
        2)
        for i in "${!script_[@]}"; do
            echo -n "$i -->"
            echo ${script_[$i]}
        done
        ;;
        3)
        echo .
        echo "Extracted IDs: ${id[@]}"
        declare -p opti1
        ;;
        4)
        for i in "${!config_elements[@]}"; do
            echo -n "$i -->"
            echo "${config_elements[$i]}""<"
        done
        ;;
        5)
        
        ;;
        6)
        echo .
        echo "Extracted IDs: ${id[@]}"
        echo ${#opti1[@]}"<-->" 
        echo ${#opti2[@]}"<-->"
        echo ${#opti3[@]}"<-->"
        echo ${#opti4[@]}"<-->"
        echo ${#opti5[@]}"<-->"
        echo ${#opti6[@]}"<-->"
        declare -p opti1 
        declare -p opti2 
        declare -p opti3 
        declare -p opti4
        declare -p opti5
        declare -p opti6
        ;;
    esac
    echo .
    echo "(t) Wahl: >$selection""<- cmdNr->"$cmdNr"<"
}

# Routine zum exit mit
teststop() {
    echo "(t) teststop "$1
    message_exit "Teststopp hier. $1" 0
}
