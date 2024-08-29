#!/usr/bin/env bash

#source declarations.sh

# Display options for selection
display_options () {
    local select=$1
    echo .
    echo "Testmodus: Display varis for debugging info ($select): "

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
            echo ${config_elements[$i]}
        done
        ;;
        5)
        echo "Extracted IDs: ${id[@]}"
        echo "Extracted Names: ${opti1[@]}"
        ;;
        6)
        echo .
        echo "Extracted IDs: ${id[@]}"
        declare -p opti1 #echo "Extracted Names: ${opti1[@]}"
        declare -p opti2 #echo "Extracted 1    : ${opti2[@]}"
        declare -p opti3  #echo "Extracted 2   s: ${opti3[@]}"
        ;;
    esac
    echo .
    echo "Wahl: $selection""<- cmdNr->"$cmdNr"<"
}

# Routine zum exit mit
teststop() {
    echo "teststop "$1
    message_exit "Teststopp hier. $1" 0

}
