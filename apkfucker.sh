#!/bin/bash

APK_DIR=""
MATCHES=0

function depack_apk {
	if [ ! -f tools/apktool ]; then
   	 	echo "[!] apktool not found!"
		exit 1
	else
		if [ ! -f $1 ]; then
			echo '[!] Your APK not found ...'
			exit 2
		else
			echo '[*] Processing your apk ...'
			APK_DIR="tmp/$RANDOM"
			tools/apktool -o $APK_DIR d $1 > /dev/null
			echo "[*] Done! APK folder: $APK_DIR"
		fi
	fi
}

function clear_tmp {
	if [ $(ls -l tmp/ | wc -l) -gt 0 ]; then
		echo -n "[!] Do you want to clear tmp folder? [!] (y/n): "
		read ans

		if [ "$ans" == "y" ]; then
			rm -rf tmp/*		
		fi
	fi
}

function search {
	echo "[*] Looking for $1 in $2 ..."
	for i in $(find $APK_DIR/smali/$(echo $2 | tr "." "/") -name "*.smali"); do
		if [[ ! -d $i ]]; then
			local out=$(cat $i | grep --color=never $1)
			if [[ $out ]]; then
				echo "	-$out"
				((MATCHES++))
			fi
		fi
        done

}

function list_db {
	for db_item in $(find db/*); do
		if [[ -d $db_item ]]; then
			echo "	-Module $(basename $db_item) available!"
		fi
	done
}

function check_module {
	if [[ ! -d "db/$1" ]]; then
		echo "[!] Module $1 does not exists!"
		exit 4
	fi	
}

function module_info {
	echo "--- $1 ---"
	echo "Author:	$(cat db/$1/author)"
	echo "Description:	$(cat db/$1/desc)"
	echo "----------"
	echo -n "[?] Continue? (y/n): "
	read ans

	if [ "$ans" != "y" ]; then
		exit 0
	fi
}

echo '''
 █████╗ ██████╗ ██╗  ██╗    ███████╗██╗   ██╗ ██████╗██╗  ██╗███████╗██████╗ 
██╔══██╗██╔══██╗██║ ██╔╝    ██╔════╝██║   ██║██╔════╝██║ ██╔╝██╔════╝██╔══██╗
███████║██████╔╝█████╔╝     █████╗  ██║   ██║██║     █████╔╝ █████╗  ██████╔╝
██╔══██║██╔═══╝ ██╔═██╗     ██╔══╝  ██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
██║  ██║██║     ██║  ██╗    ██║     ╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║
╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝    ╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                                             
'''

echo '[*] AVAILABLE DB [*]'
list_db

if [ "$#" -eq 3 ]; then
	clear_tmp
	check_module $2
	depack_apk $1
	module_info $2

	while read item; do
		search $item $3
	done < db/$2/list
	
	echo "[+] Done! Total matches: $MATCHES Thank you for using this tool :3"

else 
	echo "Usage: $0 <apk> <module> <package>"
	echo "	[* Example *]: $0 vk.apk api com.vkontakte.android"
	exit 3
fi
