#!/usr/bin/env bash

# Define vars for config-file, not changeable
declare -A config_elements
declare -A config_std

################################
# Declarations for Offime only #
################################

# Define filling for config-xml-file <attribution></attribution>
# [nn]='attribution|standard-value'
# '\.' for empty attrib.
declare -a attribution=(
    [0]='space'

    # general
    [1]='version1'
    [2]='version2'
    [3]='lang|de-DE'

    # for dialogues
    [4]='dialog_title'
    [5]='dialog_menue'
    [6]='dialog_column1'
    [7]='dialog_config'
    [8]='\.'
    [9]='\.'

    # progs for setting & main
    [10]='std_prog|soffice'
    [11]='name_stdprg|Office'
    [12]='editor_prog|gedit'
    [13]='\.'
    [14]='\.'

    # directories
    [15]='home_dir|'$HOME
    [16]='std_dir'
    [17]='usb_dir'
    [18]='remote_dir|'
)

# Define parameter of sync-group-elements
declare -a id;

declare -i num_elements=5
declare -a opti1; opti1[0]="name"
declare -a opti2; opti2[0]="prog"
declare -a opti3; opti3[0]="param"
declare -a opti4; opti4[0]="template_path"
declare -a opti5; opti5[0]="template_file"
declare -a opti6; opti6[0]=""
declare -a opti7; opti7[0]=""

# Workparameters
declare -i cmdNr=0 && unset cmdNr
declare selection=""
declare selectedIndex=""

# Init config elements with standard-values
for ((k = 0; k < ${#attribution[@]}; k++)); do
    config_elements[${attribution[k]%%|*}]=""
    # Fill standard-values
    if [[ ${attribution[k]} =~ "|" ]]; then
        config_std[${attribution[k]%%|*}]=${attribution[k]##*|}
        attribution[k]=${attribution[k]%%|*}
    else
        config_std[${attribution[k]%%|*}]=""
    fi
done

return

#declare -p config_elements
#declare -p config_std

exit 0

#### junk
