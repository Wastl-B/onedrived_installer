#######################################################################
#																																			#
# onedrived install script																						#
#																																			#
# i'm not the developer of onedrived. 																#
# 																																		#
# for more informations visit: https://github.com/xybu/onedrived-dev  #
#																																			#
#######################################################################

getlocation() {
	read -p "enter location to install[default=$HOME/programs/onedrived]: " location

	if [ ! -z $location ]
		then
			case ${location%%/*} in
				~|"~")
					location="$HOME/${location#*/}"
						if [ ! -d $location ]  
							then
								echo "the destination $location will be created"
								mkdir -p $location
							else
								read -p "$location already exist, change destination?[y/n]?" answer
								case "$answer" in
									y|Y)	
											getlocation
										;;
										*)	
											getlocation
										;;
								esac
						fi
					;;
				*)
					echo "moep"
					if [ ! -d $location ]  
						then
							echo "the destination $location will be created"
							mkdir -p $location
						else
							read -p "$location already exist, change destination?[y/n]?" answer
							case "$answer" in
								y|Y)	
										getlocation
									;;
									*)	
										getlocation
									;;
							esac
					fi
					mkdir -p $location
					;;
			esac
			#if [ ${location%%/*}=="~" ]
				#then
					#location="$HOME/${location#*/}"
					#if [ -d $location ]  
						#then
							#echo "exists"
					#fi
			#fi
		else
			location="$HOME/proggis/onedrived"
	fi
	#return $location
}

bashentry() {
	if [ ! -f "$HOME/.bash_aliases" ]
		then
			echo "~/.bash_aliases will be created..."
			touch "$HOME/.bash_aliases"
		else
			echo "~/.bash_aliases exists, continuing..."
	fi

	echo "" | tee -a $HOME/.bash_aliases
	echo 'alias onedrive_start="python3 -m onedrived.od_main start"' | tee -a $HOME/.bash_aliases
	echo 'alias onedrive_stop="python3 -m onedrived.od_main stop"' | tee -a $HOME/.bash_aliases
	echo 'alias onedrive_status="python3 -m onedrived.od_main status"' | tee -a $HOME/.bash_aliases
	echo "" | tee -a $HOME/.bash_aliases

	source ~/.bashrc
	source ~/.bash_aliases
}

installthedrive() {
	read -p "install from (s)ource or via (p)ip+git?(default=p)[s/p]: " itype
	case $itype in
		s|S)	
					cd ${location%/*} #lastfolder${location##*/}
					git clone  https://github.com/xybu/onedrived-dev.git ${location##*/}
					cd ${location##*/}
					pip3 install -e .
					bashentry s
			;;
		p|P)
					pip3 install --user git+https://github.com/xybu/onedrived-dev.git
					bashentry p
			;;
			*)
					pip3 install --user git+https://github.com/xybu/onedrived-dev.git
					bashentry p
			;;
	esac
}

installngrok() {
	cd $location
	wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
	unzip ngrok-stable-linux-amd64.zip -d ngrok
	rm -f ngrok-stable-linux-amd64.zip
	echo "" | tee -a ~/.bashrc
	echo "# ngrok (for onedrived) path" | tee -a ~/.bashrc
	# TODO: checkt this v
	echo "export PATH=$location/ngrok:\$PATH" | tee -a ~/.bashrc
	echo "" | tee -a ~/.bashrc
}
confthedrive() {
	echo "Now it's time to authenticate onedrived."
	echo "Visit the link, login and go on until you end up with a blank page and copy&paste its url back here"
	eche "right after, select the drive you want to synchronize"

	python3 -m onedrived.od_pref account add
	python3 -m onedrived.od_pref drive set

}

read -p "start installer[y/n]? " answ

case $answ in
	y|Y)
					sudo apt update
					sudo apt install wget git python3 python3-pip build-essential python3-dev libssl-dev inotify-tools python3-dbus
					sudo pip3 install -U pip setuptools
					
					getlocation
					installthedrive
					confthedrive
					installngrok
		;;
	n|N|""|*)
					exit
		;;
esac







