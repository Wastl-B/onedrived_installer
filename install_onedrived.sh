######################################################################
#                                                                    #
# onedrived install script                                           #
#                                                                    #
# i'm not the developer of onedrived.                                #
#                                                                    #
# for more informations visit: https://github.com/xybu/onedrived-dev #
#                                                                    #
######################################################################
thislocation=$PWD
getlocation() {
  echo
  echo
  read -p "enter location to install[default=$HOME/programs/onedrived]: " location
  if [ ! -z $location ] # empty location?
    then
      case ${location%%/*} in # wrothe with '~'?
        ~|"~")
          location="$HOME/${location#*/}" # switch '~/*' to '/home/USER/*'
          if [ ! -d $location ]  
            then
              echo
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
            if [ ! -d $location ]  
              then
                echo
                echo "the destination $location will be created"
                mkdir -p $location
              else
                echo
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
    else
      location="$HOME/proggis/onedrived"
  fi
}
bashentry() {
  if [ ! -f "$HOME/.bash_aliases" ]
    then
      echo
      echo "~/.bash_aliases will be created..."
      echo
      touch "$HOME/.bash_aliases"
    else
      echo
      echo "~/.bash_aliases exists, continuing..."
      echo
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
  echo
  read -p "install from (s)ource or via (p)ip+git?(default=p)[s/p]: " itype
  case $itype in
    s|S)	
      cd ${location%/*}
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
  wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -P $location
  unzip $location/ngrok-stable-linux-amd64.zip -d ngrok
  rm -f $location/ngrok-stable-linux-amd64.zip
  if [ ! -f ~/.extend.bashrc ]
    then
      touch ~/.extend.bashrc
      echo "" | tee -s ~/.bashrc
      echo "if [ -f ~/.extend.bashrc ] then" | tee -s ~/.bashrc
      echo "	. ~/.extend.bashrc" | tee -s ~/.bashrc
      echo "fi" | tee -s ~/.bashrc
      echo "" | tee -s ~/.bashrc
  fi
  echo "" | tee -a ~/.extend.bashrc
  echo "# ngrok (for onedrived) path" | tee -a ~/.extend.bashrc
  echo "PATH=$location/ngrok:\$PATH" | tee -a ~/.extend.bashrc
  echo "" | tee -a ~/.extend.bashrc
  source ~/.bashrc
}
confthedrive() {
  echo
  echo "Now it's time to authenticate onedrived."
  echo "Visit the link, login and go on until you end up with a blank page and copy&paste its url back here"
  echo "right after, select the drive you want to synchronize"
  read -p "ready?" r
  python3 -m onedrived.od_pref account add
  python3 -m onedrived.od_pref drive set
}
odcommands() {
  echo
  echo
  echo "control onedrive with the following commands:"
  echo
  echo "onedrive_start		to start the daemon"
  echo "onedrive_stop		to stop the daemon"
  echo "onedrive_status		recieve the daemons status"
  echo
}
reqs() {
  case $1 in
    apt)
      sudo apt update
      sudo apt-get install $(grep -vE "^\s*#" apt.list  | tr "\n" " ")
      ;;
    pac)
      sudo pacman -S  --needed `grep -vE '^\s*#' pacman.list | tr "\n" " "`
      ;;
      *)
        read -p "pleas enter your packagemanager [apt/pac]: " manager
        reqs $manager
  esac
}
installermain() {
  read -p "start installer[y/n]? " answ
  case $answ in
    y|Y)
      reqs $1
      sudo pip3 install -U pip setuptools
      getlocation
      installthedrive
      confthedrive
      installngrok
      odcommands
      ;;
      *)
        exit
      ;;
  esac
}
echo
#installermain
installermain $1
