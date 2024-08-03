#!/bin/bash
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

#################
#version="0.2" # slae 2012-08-02 version="0.3" # slae 2017-10-30 "0.4" # slae 2017-12-10 "0.5" # slae 2018-12-17 "0.6" # slae 2019-04-17 "0.7" # slae 2020-08-15 "0.8" # slae 2021-02-24 "0.8b" # slae 2022-06-01
#version="0.8c" # slae 2023-11-22 mit Sprach
version=0.9 
## Version 1.0 muss mit db sein...!
title="Office Vorlagen Starter $version"

#################
myprog="loffice --nologo"
mypath="/home/stefan/slae_kim/etc/vorlagen" # ohne / am Ende
myedit="geany"

#################
text="Vorlage auswählen :"
eintr0="writer_(leer)"          prog0="$myprog --writer"
eintr1="slae__Brief"            prog1="$myprog -n $mypath/LaeHomeBrief.ott"

eintr2="AB>>Physik_(Stand.)"    prog2="$myprog -n $mypath/abf/ab_physik_K202008.ott"
eintr22="AB>>Physik_(Stdquer?)"  prog22="$myprog -n $mypath/abf/ab_physik_K202008.ott"
eintr23="AB>>Physik_(Paetec)"   prog23="$myprog -n $mypath/abf/ab_physik_paetec201904.ott"
eintr24="AB>>Physik_(QUER_2Sp)"   prog24="$myprog -n $mypath/abf/ab_physik_2Q202002.ott"
eintr25="AB>>Physik_(QUER_3Sp)"   prog25="$myprog -n $mypath/abf/ab_physik_3Q202103.ott"

eintr3="AB>>Mathe_(leer)"       prog3="$myprog -n $mypath/abf/ab_matheL202010.ott"
eintr32="AB>>Mathe_(Karos)"     prog32="$myprog -n $mypath/abf/ab_mathe201903.ott"
eintr33="AB>>Mathe_(Klett&co)"  prog33="$myprog -n $mypath/abf/ue_mathe201903.ott"

eintr61="LK_Physik_klass"       prog61="$myprog -n $mypath/lk_physik_OSpr_2311.ott"
eintr62="LK_Physik_mitSprBwtg"  prog62="$myprog -n $mypath/lk_physik_Spr_2311.ott"
eintr63="LK_Mathe"              prog63="$myprog -n $mypath/lk_ma_202303.ott"
eintr8="Abi_mdl"                prog8="$myprog -n $mypath/prf_abi_202206.ott"

eintr10="calc_(leer)"           prog10="$myprog -calc"
eintr90="Office_pur"            prog90="$myprog"
eintr99="Alle_Vorlagen"         prog99="caja $mypath"
config="Einstellungen"

eintraege="$eintr0 $eintr1 
$eintr2 $eintr22 $eintr23 $eintr24 $eintr25 $eintr26 -
$eintr3 $eintr32 $eintr33 -
$eintr61 $eintr62 $eintr63 
$eintr8 
$eintr10 $eintr90 $eintr99"
 
######## Hauptfenster ########
while [ ! "$auswahl" ] # Wiederanzeige bis Auswahl
do
	auswahl=`zenity --height "510" --width "450" \
	--title "$title" --text "$text" \
	--list --column="Eintraege"	$eintraege $config \
	`
#	auswahl=`zenity --list --column="Eintraege" $eintraege`
	###### gewaehlt -> abgang ######
	if  [ $? != 0 ]; then
		exit 1
	fi
	[ $? -ne 0 ] && exit 2 # Abbruch
done

echo $auswahl
 
#### Aufruf ####
case $auswahl in
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
	$config)
		$myedit $0
		;;
	*) 
echo auswahl=1 # caseelse
# hier noch Fehler abfangen also Abbr oder zurück falls keine Vorlage gefunden
	
		;;
esac

