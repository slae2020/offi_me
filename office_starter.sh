#!/bin/bash

# Define a placeholder space character for use in a configuration file
placeholder_space="#x0020"

# Define associative array with desired elements & first allocation
declare -A config_elements=(
	[version]='version'
	[version_strg]='verstxt'
	[lang]='lang'

	[title_strg]='title'
	[menue_strg]='menue'
	[config_strg]='config'
	[editor_prog]='confProg'
    [office_prog]='officeprog'
    
    [home_directory]='homeVerz'
    [storage_location]='stickort'
    [standard_path]='stdpath'
)
# Define parameter of template-group-elements
declare -a id
declare -a template_name
declare -a template_prog
declare -a template_param
declare -a template_path
declare -a template_file

script_directory=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) # ????

# Function #1 to extract configuration single values from XML
extract_config_values() {
    local -n ref=$1  # Use nameref for indirect variable assignment

    for element in "${!ref[@]}"; do
		#replace first allocation with config-file-value
        ref["$element"]=$(xml_grep "${ref[$element]}" "$config_file" --text_only 2>/dev/null)
        # warn if xml-tag is missing or empty
        [ -z "${ref[$element]}" ] && echo "Warning (8): '$element' not found in config file $config_file" && unset ${ref[$element]}
    done
}

# Function #2 to extract configuration arrays from XML
extract_options_values() {
    local element="$1"    
    xml_grep $element "$config_file" --text_only   
}

# Function to replace placeholders after reading
replace_placeholders () {
	local -n ref=$1
	for ((k = 0 ; k < ${#id[@]} ; k++)); do
		if [[ ${ref[k]} =~ [~|\$] ]]; then
			# replace defined placeholder from config-file
			ref[k]=$(echo "${ref[k]}" | sed "s|~|${config_elements[home_directory]}|; \
                                             s|\\\$homeVerz|${config_elements[home_directory]}|; \
                                             s|\\\$officeprog|${config_elements[office_prog]}|; \
                                             s|\\\$stdpath|${config_elements[standard_path]}|")
		fi
		if [[ ${ref[k]} =~ [$placeholder_space] ]]; then
			# global replace placeholder as declared with space
			ref[k]=$(echo "${ref[k]}" | sed "s|$placeholder_space| |g") 
		fi
	done
}

ZeigeOptionen () { #fct alle Optionen zur Auswahl anzeigen/ Testoption

	echo .
#for i in "${!config_elements[@]}"; do
    #echo -n "$i -->"
    #echo ${config_elements[$i]}
#done

echo .
# Debugging output
echo "Extracted IDs: ${id[@]}"
echo "Extracted Names: ${template_name[@]}"
echo "Extracted progs: ${template_prog[@]}|"
echo "Extracted param: ${template_param[@]}"
echo "Extracted template_paths: ${template_path[@]}"
echo "Extracted template_file: ${template_file[@]}"
echo .
	echo "Wahl: $selection""<-"
	#echo ${template_name[8]}
	echo .

#	echo $(xml_grep 'version' "$config_file" --text_only)
}

# start #
# Reading args  ???

# Reading configuration file 

# Ensure the configuration file is set, defaulting to "config.xml" if not provided
[[ -z "$config_file" ]] && config_file="${config_file:-config.xml}"   

# Ensure the configuration file exists and is readable
if [ ! -r "$config_file" ]; then
	echo "Error: Configuration file '$config_file' is not readable." >&2
	exit 1
fi

# Call function to extract values
extract_config_values config_elements

# Replace placeholders from config ??? replace?
config_elements[menue_strg]="${config_elements[menue_strg]//\$version/${config_elements[version]}}"
config_elements[menue_strg]="${config_elements[menue_strg]//\$verstxt/${config_elements[version_strg]}}"

# Ensure the editor-prog is set, defaulting to "gedit" if not provided
[[ -z "${config_elements[editor_prog]}" ]] && config_elements[editor_prog]="${config_elements[editor_prog]:-gedit}"  #mit cmd /args testen!!!???

# Extract IDs, names, paths etc. for templates
id=($(extract_options_values 'id'))
template_name=($(extract_options_values 'name' )) && replace_placeholders template_name
template_prog=($(extract_options_values 'prog'))  && replace_placeholders template_prog
template_param=($(extract_options_values 'param')) && replace_placeholders template_param
template_path=($(extract_options_values 'template_path')) && replace_placeholders template_path
template_file=($(extract_options_values 'template_file')) && replace_placeholders template_file

#[[ $cmdNr -lt ${#id[@]} ]]  || unset cmdNr # wenn cmdNr nicht auf Liste loeschen ??? erst comamnd einlesen machen

# Check the total number of template elements
	# (Calculate the number of templates by dividing the total by the number of template types)
	total_template_elements=$((${#template_name[@]} + ${#template_prog[@]} + ${#template_param[@]} + ${#template_path[@]} + ${#template_file[@]}))
	num_templates=$((total_template_elements / 5))

	# Check if the number of templates matches the number of IDs
	if [[ $num_templates -ne ${#id[@]} ]]; then
		echo "Error: Parameter file is not well-filled (45)." >&2
    exit 45
	fi
## reading config done
#echo -e "Konfiguration eingelesen! >$cmdNr<\n" # Testoption

# Loop until a selection is made
while [ -z "$selection" ]; do
    # Display the zenity list dialog
    selection=`zenity --height "510" --width "450" \
        --title "${config_elements[title_strg]}" --text "${config_elements[menue_strg]}" \
        --list --column="Eintraege" "${template_name[@]}" "${config_elements[config_strg]}"`
    # Check if the user canceled the dialog
    if [ $? -ne 0 ]; then
        echo "Dialog canceled by user (66)." # ??? dt? language? ueberhaupt nötig???
        exit 1
    fi
done

# Match foundIndex to selection
for i in "${!template_name[@]}"; do
    if [[ "${template_name[$i]}" == "$selection" ]]; then
        foundIndex=$i
        break  # Exit the loop early once the foundIndex is found
    fi
done

# Check if foundIndex is set and within bounds (to make sure)
if [[ -n $foundIndex && foundIndex -ge 0 && foundIndex -lt ${#template_name[@]} ]]; then
    selection=${template_name[$foundIndex]}
fi

ZeigeOptionen # Testoption
#echo "Selected: $selection" # Testversion
#echo -e $selection"+++ "$foundIndex" +++"${id[$foundIndex]}"##"${template_prog[$foundIndex]}"<>""${template_path[$foundIndex]}${template_file[$foundIndex]}"#Testoption


# Execution with the selected option
case $selection in
	${config_elements[config_strg]})  	# script ändern)
		# Construct the command to execute
		command_to_execute="${config_elements[editor_prog]} $script_directory${0:1}"

		# Run the command in the background and redirect its output to /dev/null
		$command_to_execute & >/dev/null 2>&1		
		;;		

	${template_name[$foundIndex]})

		# Construct the command to execute
		command_to_execute="${template_prog[$foundIndex]} ${template_path[$foundIndex]}${template_file[$foundIndex]}"

		# Check if file exist
		if [[  ${template_file[$foundIndex]} =~ ".ott" && ! -r "${template_path[$foundIndex]}${template_file[$foundIndex]}" ]]; then
			zenity --error --title "${config_elements[title_strg]}" \
					--text="\"${template_path[$foundIndex]}${template_file[$foundIndex]}\" wurde nicht gefunden (22)."
			exit 22
		fi

		# Run the command in the background and redirect its output to /dev/null
		$command_to_execute & >/dev/null 2>&1		
		;;

	*) 			# caseelse
		echo "Fehler 99 (caseelse)"
		;;		
esac

exit 0

## ab hier junk

####
# Construct the command to execute
#command_to_execute="${template_prog[$foundIndex]} ${template_path[$foundIndex]}${template_file[$foundIndex]}"

#echo "RRR"
#echo $command_to_execute
#echo "RRR"
# Execute the command
$command_to_execute 
#soffice --writer



# Execute the command
#${template_prog[$foundIndex]} ${template_path[$foundIndex]}${template_file[$foundIndex]} &
#if [ $? -ne 0 ]; then
 #   echo "(Fehler 666)"
#fi

