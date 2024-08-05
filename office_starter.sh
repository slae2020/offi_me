#!/bin/bash

# Define associative array with desired elements & first allocation
declare -A config_elements=(
	[version]='version'
	[version_strg]='verstxt'
	[lang]='lang'

	[title_strg]='title'
	[menue_strg]='menue'
	[config_strg]='config'
	[editor_prog]='confProg'
    [word_processor_path]='wordprog'
    [calculator_path]='calcprog'

    [home_directory]='homeVerz'
    [storage_location]='stickort'
    [standard_directory]='StdVerz'
    [remote_location]='RemoteOrt'
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

# Function to extract configuration values from XML
extract_config_values() {
    local -n ref=$1  # Use nameref for indirect variable assignment

    for element in "${!ref[@]}"; do
		#replace first allocation with config-file-value
        ref["$element"]=$(xml_grep "${ref[$element]}" "$config_file" --text_only 2>/dev/null)
        [ -z "${ref[$element]}" ] && echo "Warning (8): '$element' not found in config file $config_file"
    done
}

extract_options_values() {
    local element="$1"    
    xml_grep $element "$config_file" --text_only
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

# Replace placeholders from config
config_elements[menue_strg]="${config_elements[menue_strg]//\$version/${config_elements[version]}}"
config_elements[menue_strg]="${config_elements[menue_strg]//\$verstxt/${config_elements[version_strg]}}"

if [ -z "config_elements[editor_prog" ]; then
echo "nuue Fehler (998)"
# leer: kein commandzeiel oúnd/oder config leer dann gedit oder geany ???
	confProg="${confProg:-$(xml_grep 'confProg' "$config_file" --text_only 2>/dev/null)}" || { 
		echo "Error extracting confProg" >&2
		exit 1
	}
fi

# Extract IDs, names, paths etc. for templates
id=($(extract_options_values 'id'))
template_name=($(extract_options_values 'name' ))
template_prog=($(extract_options_values 'prog'))
template_param=($(extract_options_values 'param'))
template_path=($(extract_options_values 'template_path'))
template_file=($(extract_options_values 'template_file'))



# Replace placeholders after reading
for ((k = 0 ; k < ${#id[@]} ; k++)); do 	# standard-Verzeichnis einsetzen oder korrigieren (~ zu /home/stefan/)
	if [[ ${template_path[k]} =~ [~|\$] ]]; then
		template_path[k]=$(echo "${template_path[k]}" | sed "s|~|${config_elements[home_directory]}|; \
                                                     s|\\\$homeVerz|${config_elements[home_directory]}|; \
                                                     s|\\\$stdpath|${config_elements[standard_path]}|")
															
								  #|	sed "s|\$stickort|$stickort|" \				  #|	sed "s|\$StdVerz|$StdVerz|" \		  #|	sed "s|\$RemoteOrt|$RemoteOrt|" \
								  #|	sed "s|\$stdpath|$stdpath|" 
		
	fi
	if [[ ${template_prog[k]} =~ [~|\$] ]]; then
		template_prog[k]=$(echo "${template_prog[k]}" | sed "s|~|${config_elements[home_directory]}|; \
                                                      s|\\\$homeVerz|${config_elements[home_directory]}|; \
                                                      s|\\\$wordprog|${config_elements[word_processor_path]}|; \
                                                      s|\\\$calcprog|${config_elements[calculator_path]}|")
	
	fi
done
	
#[[ $cmdNr -lt ${#id[@]} ]]  || unset cmdNr # wenn cmdNr nicht auf Liste loeschen ??? erst comamnd einlesen machen

# Check the total number of template elements
# (Calculate the number of templates by dividing the total by the number of template types)
total_template_elements=$((${#template_name[@]} + ${#template_prog[@]} + ${#template_param[@]} + ${#template_path[@]} + ${#template_file[@]}))

num_templates=$((total_template_elements / 5))

# Check if the number of templates matches the number of IDs
if [[ $num_templates -ne ${#id[@]} ]]; then
    echo "Error: Parameter file '%s' is not well-filled (45)." >&2
    exit 45
fi


echo -e "eingelesen! >$cmdNr\n" # Testoption

#################

#eintr22="AB>>Physik_(Stdquer?)"  prog22="$myprog -n $mypath/abf/ab_physik_K202008.ott"
#eintr23="AB>>Physik_(Paetec)"   prog23="$myprog -n $mypath/abf/ab_physik_paetec201904.ott"
#eintr24="AB>>Physik_(QUER_2Sp)"   prog24="$myprog -n $mypath/abf/ab_physik_2Q202002.ott"
#eintr25="AB>>Physik_(QUER_3Sp)"   prog25="$myprog -n $mypath/abf/ab_physik_3Q202103.ott"


#eintr61="LK_Physik_klass"       prog61="$myprog -n $mypath/lk_physik_OSpr_2311.ott"
#eintr62="LK_Physik_mitSprBwtg"  prog62="$myprog -n $mypath/lk_physik_Spr_2311.ott"
#eintr63="LK_Mathe"              prog63="$myprog -n $mypath/lk_ma_202303.ott"
#eintr8="Abi_mdl"                prog8="$myprog -n $mypath/prf_abi_202206.ott"

#eintr10="calc_(leer)"           prog10="$myprog -calc"
#eintr90="Office_pur"            prog90="$myprog"
#eintr99="Alle_template_fileagen"         prog99="caja $mypath"
#configStrg="Einstellungen"

#eintraege="$eintr0 $eintr1 
#$eintr2 $eintr22 $eintr23 $eintr24 $eintr25 $eintr26 -
#$eintr3 $eintr32 $eintr33 -
#$eintr61 $eintr62 $eintr63 
#$eintr8 
#$eintr10 $eintr90 $eintr99"


 
######## Hauptfenster ######## config_elements[menue_strg]=
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

# Check if foundIndex is set and within bounds
if [[ -n $foundIndex && foundIndex -ge 0 && foundIndex -lt ${#template_name[@]} ]]; then
    selection=${template_name[$foundIndex]}
else
    echo "Error: Invalid index foundIndex (77)." >&2 # noetig ???
    selection=""
fi

# Continue with the selected option

# Replace "_" from config_file with ""
[[ "${template_path[$foundIndex]}" == "_" ]] && template_path[$foundIndex]=""
[[ "${template_file[$foundIndex]}" == "_" ]] && template_file[$foundIndex]=""


ZeigeOptionen # Testoption
echo "Selected: $selection" # Testversion

echo -e $selection"+++ "$foundIndex" +++"${id[$foundIndex]}"##"#${template_prog[$foundIndex]}"<>""${template_path[$foundIndex]}${template_file[$foundIndex]}"#Testoption





### ?????  
#Konzepz ändern
#-n geht nicht   wg. minus?
#loffice --writer geht nicht wg. Lücke
#( ${prog[$foundIndex]} --writer "" & ) 

# Construct the command to execute
command_to_execute="${template_prog[$foundIndex]}  \"${template_path[$foundIndex]}${template_file[$foundIndex]}\""

echo $command_to_execute
# Execute the command
exec $command_to_execute &

exit 2

# Execute the command
${template_prog[$foundIndex]} "${template_path[$foundIndex]}${template_file[$foundIndex]}" &
if [ $? -ne 0 ]; then
    echo "(Fehler 666)"
fi

exit 2

#### Aufruf ####
case $selection in
	$configStrg)  	# script ändern)
		#$confProg "$script_template_pathectory${0:1}" || echo "Fehler 88"
		;;		
	${template_name[$foundIndex]})
		#grep -q "/mnt/"   <<<"${template_path1[$foundIndex]}" && verbunden "${template_path1[$foundIndex]}"
		#grep -q "/mnt/"   <<<"${template_path2[$foundIndex]}" && verbunden "${template_path2[$foundIndex]}"
		###
		( ${template_prog[$foundIndex]} "${template_path[$foundIndex]}${template_file[$foundIndex]}" & ) || echo "(Fehler 66)" 
		;;
###

	$configStrg)
		#$myedit $0
		;;
	*) 			# caseelse
		echo "Fehler 99 (caseelse)"
		;;		
esac

exit 0

## ab hier junk

eintr0="writer_(leer)"          prog0="$myprog --writer"
eintr1="slae__Brief"            prog1="$myprog -n $mypath/LaeHomeBrief.ott"

#eintr2="AB>>Physik_(Stand.)"    prog2=" $myprog -n $mypath/abf/ab_physik_K202008.ott"
eintr22="AB>>Physik_(Stdquer?)"  prog22="$myprog -n $mypath/abf/ab_physik_K202008.ott"
eintr23="AB>>Physik_(Paetec)"   prog23="$myprog -n $mypath/abf/ab_physik_paetec201904.ott"
eintr24="AB>>Physik_(QUER_2Sp)"   prog24="$myprog -n $mypath/abf/ab_physik_2Q202002.ott"
eintr25="AB>>Physik_(QUER_3Sp)"   prog25="$myprog -n $mypath/abf/ab_physik_3Q202103.ott"

#eintr3="AB>>Mathe_(leer)"       prog3= "$myprog -n $mypath/abf/ab_matheL202010.ott"
#eintr32="AB>>Mathe_(Karos)"     prog32="$myprog -n $mypath/abf/ab_mathe201903.ott"
#eintr33="AB>>Mathe_(Klett&co)"  prog33="$myprog -n $mypath/abf/ue_mathe201903.ott"

eintr61="LK_Physik_klass"       prog61="$myprog -n $mypath/lk_physik_OSpr_2311.ott"
eintr62="LK_Physik_mitSprBwtg"  prog62="$myprog -n $mypath/lk_physik_Spr_2311.ott"
eintr63="LK_Mathe"              prog63="$myprog -n $mypath/lk_ma_202303.ott"
eintr8="Abi_mdl"                prog8="$myprog -n $mypath/prf_abi_202206.ott"

eintr10="calc_(leer)"           prog10="$myprog -calc"
eintr90="Office_pur"            prog90="$myprog"
eintr99="Alle_template_fileagen"         prog99="caja $mypath"

	$eintr0)
		$prog0
		;;
	$eintr10)
		$prog10
		;;
	$eintr1)
		$prog1
		;;

	$eintr2)
		$prog2
		;;
	$eintr22)
		$prog22
		;;		
	$eintr23)
		$prog23
		;;		
	$eintr24)
		$prog24
		;;		
	$eintr25)
		$prog25
		;;		
	$eintr26)
		$prog26
		;;	

	$eintr3)
		$prog3
		;;
	$eintr32)
		$prog32 
		;;
	$eintr33)
		$prog33 
		;;

	$eintr61)
		$prog61 
		;;
	$eintr62)
		$prog62 
		;;
	$eintr63)
		$prog63
		;;
	$eintr8)
		$prog8 
		;;

	$eintr90)
		$prog90
		;;	
	$eintr99)
		$prog99
		;;
