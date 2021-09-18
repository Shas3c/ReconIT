#!/bin/bash
#Author : @Shas3c
           
#banner() {
#echo " 
#   -"
#banner
red=`tput setaf 1`
reset=`tput sgr0`
green=`tput setaf 2`
yellow=`tput setaf 3`

echo "${red}
 _____    _____   _____   _____   _    _     _____   ______
|  _  \  |     | /     | /     \ | \  | |   |_   _| |      |
| |_| /  |   __| |   __| |  _  | |  \ | |     | |   |_    _|
|    /   |  |_   |  /    | / \ | |   \| |     | |     |  |
|    \   |   _|  |  \__  | \_/ | | |\   |     | |     |  |
| |\  \  |  |__  |     | |     | | | \  |    _| |_    |  |
|_| \__\ |_____| \_____| \_____/ |_|  \_|   |_____|   |__| 
                      				   
                                                 -Sahil Sharma		
${reset}"

#echo "choose any option :"
#read no
#echo "enter url:"
#read url

#amass_func() 

sub_lister() {	
	echo "-----subdomain enumeration-----"
	sublist3r > sub
	s=$(wc sub)
	if [[ -n $s ]]; then
		sublist3r -d $url | tee sublist3r.txt
	elif [[ -z $s ]]; then
		echo "------installing sublist3r----"			
		apt-get install sublist3r
		sublist3r -h $url | tee sublist3r.txt
	else
		echo "something wrong"
	fi
rm sub
}

asset_finder () {
	echo " ---------AssetFinder------"
		#echo "enter url :"
		#read url
	z=$(go version | wc)
	if [[ -n $z ]]; then
		echo " GO exist"
		echo "----verifying if Assetfinder Exist----"
		assetfinder -h
		echo "${green}+-----If you see any output of assetfinder----+${reset}"
		echo -n "+----- Press Y if exist or N if not-----+ "; read b
		z=$(pwd)
		if [[ $b =~ "Y" ]]; then 
			echo "Assetfinder also exist"
			cp /root/go/bin/assetfinder /usr/local/bin
			assetfinder --subs-only $url | tee assetfinder.txt 
			echo "Subdomain saved to $z/assetfinder.txt"
		elif [[ $b =~ "N" ]]; then
			echo "Assetfinder not exist"
			echo "----start downloading assetfinder"
			go get -u github.com/tomnom/assetfinder
			cp /root/go/bin/assetfinder /usr/local/bin
			assetfinder --subs-only $url | tee assetfinder.txt
		else
			echo "something wrong"
		fi
	elif [[ -z $z ]]; then
		echo " Go not exist"
		echo "------start downloading Go"
		source go.sh
		echo "---Start downloading Go"
		go get -u github.com/tomnomnom/assetfinder
		cp /root/go/bin/assetfinder /usr/local/bin
		assetfinder --subs-only $url | tee assetfinder.txt
	else
		echo "something went wrong"
	fi
}

#func_1() {
#	assetfinder --subs-only exmple.com
#}

amass_func() {
	echo "--------Amass--------"
	echo "----Checking if Amass installed----"
	amass --version
	echo "${yellow}If you see version${reset}"
	echo -n "press Y if exist or N if not "; read c
		#echo "enter domain: "
		#read url
	if [[ $c =~ "Y" ]]; then
		amass enum -passive -d $url | tee amass.txt
	elif [[ $c =~ "N" ]]; then
		echo "-----start downloading Amass-----"			
		apt-get install amass
		amass enum -passive -d $url | tee amass.txt
	else
		echo "something gone wrong"		
	fi
}

echo "${red}
1. Nmap
2. GOBUSTER
3. Hash-Identifier
4. Nikto
5. Subdomain Enumeration${reset}"
echo 
echo -n "choose any option : "; read no 
		
case $no in

	1)		
		echo "${red}+---------------Nmap Running---------------+${reset}"
		echo -n "enter IP/CIDR : "; read ip	
	
		echo "------PING SCAN-------"
		nmap -sn $ip
		

		echo "-----BASIC SCAN-------"
		nmap -sC -sV $ip

		echo "-----ALL TCP PORTS SCAN-----"
		nmap -sC -sV -p- $ip

		echo "-----DETECTING OS VERSION----"
		nmap -O $ip

		echo "------UDP SCAN--------"
		nmap -sU -v $ip
		
		echo "--------VULNS SCAN------"
		nmap -sV --script vuln $ip 

		;;

	2)
		echo "${green}+-------------------GOBUSTER-------------------+${reset}"	
		go_buster() {		
		echo -n "enter url : "; read url
		echo -n "wordlist full path: "; read wordlist
		gobuster > gobuster
		g=$(wc gobuster)
			if [[ -n $g ]]; then
				if [[ -z $wordlist ]]; then
					gobuster dir -u $url -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt
				else
					gobuster dir -u $url -w $wordlist
				fi
			elif [[ -z $g ]]; then
				echo "------start installing gobuster-----"
				apt-get install gobuster
				if [[ -z $wordlist ]]; then
					gobuster dir -u $url -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt
				else
					gobuster dir -u $url -w $wordlist
				fi
			else
				echo "something went wrong"
			fi
		rm gobuster
		}
		go_buster

		;;

	3)
		echo "${yellow}+-------------------hash Identifier-------------------+${reset}"
		hash-identifier
		;;


	4)
		echo "${yellow}+-----------------------Nikto-------------------------+${reset}"
		echo -n "enter url: "; read url
		a=$(locate nikto.pl)
		if [[ $a =~ "nikto.pl" ]]; then
			echo "Nikto Exist"
			perl $a -h $url
		elif [[ $a -ne "nikto.pl" ]]; then 
			source nikto.sh
			perl $a -h $url
		else
			echo "something missing" 
		fi
		;;
	

	5)
		echo "${green}+-------------------Subdomain ALL-------------------+${reset}"
		echo -n "enter url: "; read url
		asset_finder
		amass_func
		sub_lister
		echo "+-----Scraping Wayback URLs-------+"
		echo "+-----Make sure you have waybackurls installed-----+"
		cat sublist3r.txt | waybackurls > wb_sublist3r.txt
		cat assetfinder.txt | waybackurls > wb_assetfinder.txt
		cat amass.txt | waybackurls > wb_amass.txt
		cat wb_sublist3r.txt wb_assetfinder.txt wb_amass.txt | sort | uniq > wb_subdomains.txt
		echo "+------Unfurl Pull out uniq keys------+"
		cat wb_subdomains.txt | unfurl --unique keys > unique_keys.txt
		#func_1
		;;

	*)
		echo "unknown"
		;;

esac
