#!/bin/bash

# Remplace le ctrl-c par la fonction ctrl_c()
trap ctrl_c INT

function banner() {
	clear
	echo "            ______________________________________________________________"
	echo "           /      ____ _____ ____  ____         _____                     \\"
	echo "           |     |  _ \_   _/ ___||  _ \       | ____|   _  ___  ___      |"
	echo "           |     | |_) || | \___ \| |_) | ____ |  _|| | | |/ _ \/ __|     |"
	echo "           |     |  _ < | |  ___) |  __/ |____|| |__| |_| |  __/\__ \     |"
	echo "           |     |_| \_\|_| |____/|_|          |_____\__, |\___||___/     |"
	echo "           |                                         |___/                |"
	echo "           \________________________By_7h30th3r0n3________________________/"
	echo " "
	echo " "
	echo " "
}

function rtspnumline() {
	rtspip=$(sed -n ''"$pline"','"$dline"'p' $rtspfile)
	nbcamrest=$(sed -n ''"$pline"','"$dline"'p' $rtspfile|wc -l)
	nbrtspline=$(cat $rtspfile|wc -l)
	if [ -z "$rtspip" ]; then
		messagefinal
		exit 1
	else
		banner
		echo "-----------------------------------------------"
		echo " Il y a $nbrtspline cameras dans le fichier"
		echo "-----------------------------------------------"
		if [ $nbcamrest -lt 20 ]; then
			# Si oui, on exécute cette commande
			nbcamrestant=$(($pline+$nbcamrest-1))
			echo " Chargement des cameras $pline à $nbcamrestant..."
		else
			echo " Chargement des cameras $pline à $dline..."
		fi	
	fi
}

function displaycam() {
	left=0
	top=0
	for line in $rtspip;
		do
			xterm -geometry "42x2+650+110" -e "ffplay -an -max_delay 50 -rtsp_transport tcp $line -x 384 -y 216 -left $left -top $top"&
			if [ $left -ne 1528 ]
				then
					left=$((left+382))
				else
					top=$((top+260))
					left=0
			fi
		done
	if [ $nbcamrest -lt 20 ]; then
			echo "-----------------------------------------------"
			echo " "
			read -p " Il n'y a pas d'autres cameras à afficher. appuyer sur entrée pour quitter..."
		else
			echo "-----------------------------------------------"
			echo " Menu :"
			echo " "
			echo " Entrée : Caméras suivantes "
			read -p " Ctrl-c : Quitter "
		fi	
	killcam
	
	let pline=pline+20
	let dline=dline+20
	rtspnumline
	displaycam
}

function killcam() {
	PIDS=$(pgrep xterm)
	for pid in $PIDS;
	do
		if kill -s 0 $pid 2>/dev/null; then
			kill $pid
		fi
	done
}

function init(){
	banner
	if [[ -z $1 ]]
		then
			read -p " Fichier contenant les adresses RTSP : " rtspfile
		else 
			rtspfile="$1"
		fi
	pline=1
	dline=20
	rtspnumline
	displaycam
	dline=$(($dline+1))
}

function ctrl_c(){
	killcam
	messagefinal 
	exit
}

function messagefinal(){
	banner
	echo "---------------------------------------------------"
	echo "  Merci d'avoir utilisé RTSP-Eyes by 7h30th3r0n3 "
	echo "---------------------------------------------------"
}

init

# Restore le ctrl-c
trap - INT
