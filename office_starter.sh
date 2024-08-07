#!/bin/bash
declare -ri test=01 #0 für kein test
[[ $test -gt 0 ]] && echo $test"->Testversion!" # Testversion

{
# Define a placeholder space character for use in a configuration file
declare -r placeholder_space="#x0020"

# Define associative arrays with desired elements & first allocation
declare -A script_=(
	[dir]=$( cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd )"/"
	[name]=$( basename "${BASH_SOURCE[0]}" )
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
    [office_prog]=''
    
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

# Workparameters
declare selection=""
}

# Function #1 to extract configuration single values from XML
extract_config_values() {
    local -n ref=$1  # Use nameref for indirect variable assignment

    for element in "${!ref[@]}"; do
		# get only values from conf-file when empty 
        if [[ -z ${ref["$element"]} ]]; then 
			ref["$element"]=$(xml_grep "$element" "${script_[config]}" --text_only 2>/dev/null)
		fi
        # warn if xml-tag is missing or empty
		if [[ -z "${ref[$element]}" ]]; then
			[[ $test -gt 0 ]] && echo "Warning (8) for '$element': no value found in config file ${script_[config]}" || \
			message_exit "Warning for '$element': no value in config file ${script_[config]}" 8
			unset ${ref[$element]}  
		fi
	done
}

# Function #2 to extract configuration arrays from XML
extract_options_values() {
    local element="$1"    
    xml_grep $element "${script_[config]}" --text_only   
}

# Function to replace placeholder in strg
replace_placeholder_strg () {
	local a=$1
	local b=$2
	local c=$3
    if [[ $a =~ [$b] ]]; then
		# replace defined placeholder from config-file
		a=$(echo "$a" | sed "s|$2|$3|g")
	fi
	echo $a
}

# Function to replace specific placeholders after reading
replace_placeholders () {
	local -n ref=$1
	for ((k = 0 ; k < ${#id[@]} ; k++)); do
		ref[k]=$(replace_placeholder_strg "${ref[k]}" "~"            "${config_elements[home_directory]}")
		ref[k]=$(replace_placeholder_strg "${ref[k]}" "\$homeVerz"   "${config_elements[home_directory]}")
		ref[k]=$(replace_placeholder_strg "${ref[k]}" "\$officeprog" "${config_elements[office_prog]}")
		ref[k]=$(replace_placeholder_strg "${ref[k]}" "\$stdpath"    "${config_elements[standard_path]}")
		# finally replace ph für spaces!
		ref[k]=$(replace_placeholder_strg "${ref[k]}" "$placeholder_space" " ")
	done
}

# error-window & exit with errornummer
message_exit () {
	local txt=$1
	local err=$2
	# default-value 1 when missing
	err="${err:-1}"
	if [[ $err -gt 0 ]]; then
		# show window and wait for response except for err==0
		zenity --error --title ${script_[name]} --text="$txt ($err)"
	fi
	# return given or resulting error-nummer
	return $err
}

ZeigeOptionen () { #fct alle Optionen zur Auswahl anzeigen/ Testoption

	echo .
#	echo $(xml_grep 'version' "${script_[config]}" --text_only)

#echo "scrpt_dir is:"${script_[dir]} 
#echo "scrpt_name is:"${script_[name]} 
#echo "cofg_file is:"${script_[config]} 

#echo .
#echo ${script_[dir]}${script_[name]} 
#echo ${script_[dir]}${script_[config]}
#echo .



#for i in "${!config_elements[@]}"; do
    #echo -n "$i -->"
    #echo ${config_elements[$i]}
#done

echo .
## Debugging output
##echo "Extracted IDs: ${id[@]}"
##echo "Extracted Names: ${template_name[@]}"
#echo "Extracted progs: ${template_prog[@]}|"
#echo "Extracted param: ${template_param[@]}"
#echo "Extracted template_paths: ${template_path[@]}"
##echo "Extracted template_file: ${template_file[@]}"

#echo "Wahl: $selection""<-"

	echo .
}

# start #
# Reading arguments from commandline
while getopts ':c:e:n:h' OPTION;  do # -c "$cfile" -e geany -n automatisch# -h help
	case "$OPTION" in
		c)
		script_[config]=${OPTARG}
		;;
		e)
 		config_elements[editor_prog]=${OPTARG}
		;;
		n)
		cmdNr=${OPTARG} || unset cmdNr # wenn keine Zahl dann leeren
		;;
		?|h)
		message_exit "Usage: $(basename $0) [-c Konfiguration.xml] [-e Editor] [-n id] [-h] \n   " 11
		exit $?
		;;
	esac
done

# Reading configuration file 
{
# Ensure the configuration file is set, defaulting to "config.xml" if not provided
[[ -z "${script_[config]}" ]] && script_[config]="${script_[config]:-config.xml}"   

# Ensure the configuration file exists and is readable
if [ ! -r "${script_[dir]}${script_[config]}" ]; then
	message_exit "Config-Error: Configuration file '${script_[dir]}${script_[config]}' is not readable." 23
	exit $?
fi

# Call function to extract values
extract_config_values config_elements

## Replace placeholders from config 
config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$version" "${config_elements[version]}")
config_elements[menue_strg]=$(replace_placeholder_strg "${config_elements[menue_strg]}" "\$verstxt" "${config_elements[version_strg]}")

# Ensure the editor-prog is set, defaulting to "gedit" if not provided & checking existence
[[ -z "${config_elements[editor_prog]}" ]] && config_elements[editor_prog]="${config_elements[editor_prog]:-gedit}"  
if [[ ! -x "$( command -v ${config_elements[editor_prog]})" ]]; then
	message_exit "Config-Error: program '${config_elements[editor_prog]}' not found." 31
	exit $?
fi

# Extract IDs, names, paths etc. for templates
id=($(extract_options_values 'id'))
template_name=($(extract_options_values 'name' )) 			&& replace_placeholders template_name
template_prog=($(extract_options_values 'prog'))  			&& replace_placeholders template_prog
template_param=($(extract_options_values 'param')) 			&& replace_placeholders template_param
template_path=($(extract_options_values 'template_path')) 	&& replace_placeholders template_path
template_file=($(extract_options_values 'template_file')) 	&& replace_placeholders template_file

#[[ $cmdNr -lt ${#id[@]} ]]  || unset cmdNr # wenn cmdNr nicht auf Liste loeschen ??? erst comamnd einlesen machen

# Check the total number of template elements
	# (Calculate the number of templates by dividing the total by the number of template types)
	total_template_elements=$((${#template_name[@]} + ${#template_prog[@]} + ${#template_param[@]} + ${#template_path[@]} + ${#template_file[@]}))
	num_templates=$((total_template_elements / 5))

	# Check if the number of templates matches the number of IDs
	if [[ $num_templates -ne ${#id[@]} ]]; then
		message_exit "Error: Parameter file is not well-filled." 45
		exit $?
	fi
[[ $test -gt 0 ]] && echo -e "Konfiguration eingelesen! >$cmdNr<\n" # Testoption

[[ $test -gt 0 ]] && ZeigeOptionen # Testoption
} ## reading config done

# Checking command-number if given
if [[ -n "$cmdNr" ]]; then
	if [[ ${id[@]} =~ "$cmdNr"  ]]; then
		selection=$cmdNr
	else
		message_exit "Case '$cmdNr' not defined." 66
		exit $?
	fi
fi

# Loop until a selection is made
while [ -z "$selection" ]; do
    # Display the zenity list dialog
    selection=`zenity --height "510" --width "450" \
        --title "${config_elements[title_strg]}" --text "${config_elements[menue_strg]}" \
        --list --column="Eintraege" "${template_name[@]}" "${config_elements[config_strg]}"`
    # Check if the user canceled the dialog
    if [ $? -ne 0 ]; then
        message_exit "Dialog canceled by user." 0
        exit $?
    fi
done

# Match foundIndex to selection
for i in "${!template_name[@]}"; do
	if [[ "${template_name[$i]}" == "$selection" ]]; then
		foundIndex=$i
		break  # Exit the loop early once the foundIndex is found
	fi
	if [[ "${id[$i]}" == "$selection" ]]; then
		foundIndex=$i
		break  # Exit the loop early once the foundIndex is found
	fi
done

# Check if foundIndex is set and within bounds (to make sure)
if [[ -n $foundIndex && foundIndex -ge 0 && foundIndex -lt ${#template_name[@]} ]]; then
	selection=${template_name[$foundIndex]}
fi

[[ $test -gt 0 ]] && echo "Selected: $selection" # Testversion
[[ $test -gt 0 ]] && echo $selection"+++ "$foundIndex" +++"${id[$foundIndex]}"##"${template_prog[$foundIndex]}"<>""${template_path[$foundIndex]}${template_file[$foundIndex]}" #Testoption

# Execution with the selected option
case $selection in
	${config_elements[config_strg]})  	# config ändern ändern)
		# Construct the command to execute
		xfile="${script_[dir]}${script_[config]}"
		command_to_execute="${config_elements[editor_prog]} $xfile" 
[[ $test -gt 0 ]] && echo $command_to_execute


		# Check if file exists then start
		if [[ ! -f $xfile ]]; then 
			message_exit "File '$xfile' not found." 77
			exit $?
		else 
			# Run the command in the background and redirect its output to /dev/null
			$command_to_execute & >/dev/null 2>&1		
		fi
		;;		

	${template_name[$foundIndex]})
		# Construct the command to execute
		command_to_execute="${template_prog[$foundIndex]} ${template_path[$foundIndex]}${template_file[$foundIndex]}"

		# Check if file exist
		if [[  ${template_file[$foundIndex]} =~ ".ott" && ! -r "${template_path[$foundIndex]}${template_file[$foundIndex]}" ]]; then
			message_exit "'${template_path[$foundIndex]}${template_file[$foundIndex]}' \n not found." 05
			exit $?
		fi

		# Run the command in the background and redirect its output to /dev/null
		$command_to_execute & >/dev/null 2>&1		
		;;

	*) 			# caseelse
		message_exit "Case '$selection' not defined." 99
		exit $?
			#echo "Fehler 99 (caseelse)"
		;;		
esac

exit 0

## ab hier junk
