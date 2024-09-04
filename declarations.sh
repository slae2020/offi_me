#!/usr/bin/env bash

# Define a placeholder space character for use in a configuration file
#declare placeholder_space="#x0020"  #???? -->placeholder [0]


################################
# Declarations for Offime only #
################################

# Define placeholders for config-xml-file
declare -a placeholder=(   # ??? Name ändern?
	[0]='space'
	
	# general
	[1]='version1'
	[2]='version2'
	[3]='lang|de-DE'
	
	# for dialogues
	[4]='dialog_title'
	[5]='dialog_menue'
	[6]='dialog_config'
	
	# progs for setting & main
	[7]='std_prog|soffice' 
	[8]='name_stdprg|Office'
	[9]='editor_prog|gedit' 	
	
	# directories
	[10]='home_dir|~' 
	[11]='std_dir' 
	[12]='usb_dir' 
	[13]='remote_dir|' 
	
	
)

# Define associative arrays with desired elements & first allocation
#declare -A config_elements2=(
    #[version]=''
    #[version_strg]=''
    
    #[lang]='en-GB'
    #[title_strg]=''
    #[menue_strg]=''
    #[config_strg]=''
    
    #[${placeholder[0]}]=' '
    #[${placeholder[1]}]=''
    #[${placeholder[2]}]=''
    #[${placeholder[3]}]=''
    #[${placeholder[4]}]=''
    #[${placeholder[5]}]=''
    #[${placeholder[6]}]=''  
#)

declare -A config_elements    #??? nach configreader?
declare -A config_std
for ((k = 0; k < ${#placeholder[@]}; k++)); do
	config_elements[${placeholder[k]%%|*}]=""
	# Fill standard-values
	if [[ ${placeholder[k]} =~ "|" ]]; then
		#echo $k
		config_std[${placeholder[k]%%|*}]=${placeholder[k]##*|}
		placeholder[k]=${placeholder[k]%%|*}
	else
		#echo $k
		config_std[${placeholder[k]%%|*}]="" #${placeholder[k]} ???
	fi
done

#echo "www"
#declare -p placeholder
##declare -p config_elements2
#echo .
#declare -p config_elements

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

return



declare -p config_elements
declare -p config_std

exit 0

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

#declare -a template_name
#declare -a template_prog
#declare -a template_param
#declare -a template_path
#declare -a template_file


declare var='erstes|zweites'
#var="wewr|"
#var="|uer"
echo $var

#eins=$(echo $var | sed "s/\|*/ ./" )
eins=${var%%|*}

#eins=$( echo $var | sed 's/\|.*//s')

echo $eins
zwo=${var##*|}
echo $zwo
