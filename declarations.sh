#!/usr/bin/env bash

# Define a placeholder space character for use in a configuration file
declare placeholder_space="#x0020"

# Define standardnames
declare config_stdname="config.xml"

# Define general parameters for config-file
declare -A script_=(
    [dir]=$(cd -- "$(dirname -- "$(readlink -f "$0")")" &> /dev/null && pwd)"/"
    [name]=$(basename "$(readlink -f "$0")" .sh)
    [config]="$config_stdname"
)

################################
# Declarations for Offime only #
################################

# Define associative arrays with desired elements & first allocation
declare -A config_elements=(
    [version]=''
    [version_strg]=''
    [lang]='en-GB'
    [title_strg]=''
    [menue_strg]=''
    [config_strg]=''
    [editor_prog]=''
    [prog_strg]=''
    [home_directory]=''
    [storage_location]=''
    [standard_path]=''
    [remote_path]=''
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

#return



#### junk

#declare -A optionKW=(
    #[name]=''
    #[param]=''
    #[dir1]=''
    #[dir2]=''
#)


#declare -a sync_name     #oppti1
#declare -a sync_param
#declare -a sync_dir1    #optti2
#declare -a sync_dir2    #oppti3

declare -a template_name
declare -a template_prog
declare -a template_param
declare -a template_path
declare -a template_file
