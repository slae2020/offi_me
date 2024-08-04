#!/bin/bash

################# config einlesen
[[ -z "$cfile" ]] && cfile="config.xml"
version=$(xml_grep 'version' "$cfile" --text_only) && verstxt=$(xml_grep 'verstxt' "$cfile" --text_only)
scriptort=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

title=$(xml_grep 'title' $cfile --text_only) 
text=$(xml_grep 'text' "$cfile" --text_only) && text=${text/\$version/$version} && text=${text/\$verstxt/$verstxt} 
config=$(xml_grep 'config' "$cfile" --text_only)
[[ -z "$confProg" ]] && confProg=$(xml_grep 'confProg' "$cfile" --text_only)

wordprog=$(xml_grep 'wordprog' "$cfile" --text_only) 
calcprog=$(xml_grep 'calcprog' "$cfile" --text_only)

homeVerz=$(xml_grep 'homeVerz' "$cfile" --text_only)
stickort=$(xml_grep 'stickort' "$cfile" --text_only)
StdVerz=$(xml_grep 'StdVerz' "$cfile" --text_only)
RemoteOrt=$(xml_grep 'RemoteOrt' "$cfile" --text_only)
stdpath=$(xml_grep 'stdpath' "$cfile" --text_only)

### Liste der möglichen Vergleiche (Ordner)
ident+=($(xml_grep 'id' "$cfile" --text_only))
optName+=($(xml_grep 'name' "$cfile" --text_only))
prog+=($(xml_grep 'prog' "$cfile" --text_only))
dir+=($(xml_grep 'dir' "$cfile" --text_only))
vorl+=($(xml_grep 'vorl' "$cfile" --text_only))
#dir1+=($(xml_grep 'dir1' "$cfile" --text_only)) #kw
#dir2+=($(xml_grep 'dir2' "$cfile" --text_only)) #kw

####
for ((k = 0 ; k < ${#ident[@]} ; k++)); do 	# standard-Verzeichnis einsetzen oder korrigieren (~ zu /home/stefan/)
	[[ ${dir[k]} =~ [~|\$] ]] &&
		dir[k]=$(echo ${dir[k]}   | sed "s|~|${homeVerz}|;s|\$homeVerz|${homeVerz}|"  \
								  |	sed "s|\$stickort|$stickort|" \
								  |	sed "s|\$StdVerz|$StdVerz|" \
								  |	sed "s|\$RemoteOrt|$RemoteOrt|" \
								  |	sed "s|\$stdpath|$stdpath|" \
																						)
	[[ ${prog[k]} =~ [~|\$|p] ]] &&  # anpasenn??
		prog[k]=$(echo ${prog[k]} | sed "s|~|${homeVerz}|;s|\$homeVerz|${homeVerz}|"  \
								  |	sed "s|\$wordprog|$wordprog|" \
								  |	sed "s|\$calcprog|$calcprog|" \
								  
																						)
	done
#[[ $cmdNr -lt ${#ident[@]} ]]  || unset cmdNr # wenn cmdNr nicht auf Liste loeschen

echo -e "eingelesen! >$cmdNr\n" # Testoption

#?????
###
ZeigeOptionen () { #fct alle Optionen zur Auswahl anzeigen/ Testoption

	echo .
declare -p | grep ident
declare -p | grep optName

declare -p | grep prog
#declare -p | grep dir
#declare -p | grep vorl

	#echo ${#options[*]}

	echo $auswahl
	#echo ${optName[8]}
	echo .

#	echo $(xml_grep 'version' "$cfile" --text_only)


}
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
#eintr99="Alle_Vorlagen"         prog99="caja $mypath"
#config="Einstellungen"

#eintraege="$eintr0 $eintr1 
#$eintr2 $eintr22 $eintr23 $eintr24 $eintr25 $eintr26 -
#$eintr3 $eintr32 $eintr33 -
#$eintr61 $eintr62 $eintr63 
#$eintr8 
#$eintr10 $eintr90 $eintr99"

#eintraege="qw qed"

ZeigeOptionen # Testoption
 
######## Hauptfenster ########
while [ ! "$auswahl" ] # Wiederanzeige bis Auswahl
do
	auswahl=`zenity --height "510" --width "450" \
	--title "$title" --text "$text" \
	--list --column="Eintraege"	${optName[*]} $config \
	`
#	auswahl=`zenity --list --column="Eintraege" $eintraege`
	###### gewaehlt -> abgang ######
	if  [ $? != 0 ]; then
		exit 1
	fi
	[ $? -ne 0 ] && exit 2 # Abbruch
done

###
for i in "${!optName[@]}"; do
	[[ "${optName[$i]}" = "$auswahl" ]] && index=$i
	done
[[ -z $index ]] || auswahl=${optName[$index]} # Absicherung 

echo -e $auswahl"+++ "$index" +++"${ident[$index]}"##"#${prog[$index]} #Testoption
 
### ?????  
Konzepz ändern
-n geht nicht   wg. minus?
loffice --writer geht nicht wg. Lücke
( ${prog[$index]} --writer "" & ) 

exit 0

#### Aufruf ####
case $auswahl in
	$config)  	# script ändern)
		$confProg "$scriptort${0:1}" || echo "Fehler 88"
		;;		
	${optName[$index]})
		#grep -q "/mnt/"   <<<"${dir1[$index]}" && verbunden "${dir1[$index]}"
		#grep -q "/mnt/"   <<<"${dir2[$index]}" && verbunden "${dir2[$index]}"
		###
		( ${prog[$index]} "${dir[$index]}${vorl[$index]}" & ) || echo "(Fehler 66)" 
		;;
###

	$config)
		$myedit $0
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
eintr99="Alle_Vorlagen"         prog99="caja $mypath"

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
