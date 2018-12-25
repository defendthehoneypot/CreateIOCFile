#!/usr/bin/env bash
# Script to download IP/Domain Names from a website and post to PasteBin
# 12/14/2018 Version 1.0
# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
NC='\033[0m' 		  # No Color

main () {
	# Clear the screen
	clear
	# Ask for website containing IOCs
	echo ""
	echo -e ${Green}"This script pulls IP and Domain Names from websites to create IOC files"${NC}
	echo ""
	echo -e ${Green}"Paste the website URL: "${NC}
	read -e varURL
	echo ""

	#Create a directory if it does not exist
	if	[ ! -d $HOME/working ]; then
	mkdir $HOME/working
	fi

	# Declare variables
	varTempDownloadFile="$HOME/working/tempfile.txt"
	varExtractedC2sFile="$HOME/working/extracted-ips.txt"
	varExtractedDomainNamesFile="$HOME/working/extracted-domainnames.txt"
	varExtractedSHA256HashesFile="$HOME/working/extracted-hashes.txt"
	varDate=$(date +%Y-%m-%d)
	
	#Download website
	wget $varURL -O $varTempDownloadFile

	#Extract IPs from file
	grep -oE "\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" $varTempDownloadFile > $varExtractedC2sFile
	
	#Extract domain names from file
	grep "^http" $varTempDownloadFile | grep -vE "\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" | sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_' > $varExtractedDomainNamesFile

	#Extract SHA256 hashes from file
	egrep -o '[a-fA-F0-9]{64}' $varTempDownloadFile > $varExtractedSHA256HashesFile
	
	#Remove temp file
	rm $varTempDownloadFile
	# clear the screen
	clear
	echo ""
	echo -e ${Green}"Your extracted list of IPs is located here: $varExtractedC2sFile"${NC}
	echo -e ${Green}"Your extracted list of Domain Names is located here: $varExtractedDomainNamesFile"${NC}
	echo -e ${Green}"Your extracted list of SHA256 Hashes is located here: $varExtractedSHA256HashesFile"${NC}
	echo ""

	#Upload IOC list to pastebin
	#./PasteBinAPI.sh -n IOCs-$varDate -e 1W < $varExtractedC2sFile
}

main


