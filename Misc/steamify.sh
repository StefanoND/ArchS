#!/usr/bin/env bash


if ! [[ $EUID -ne 0 ]]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
    exit 1
fi

clear
echo
echo
echo "      _        _                                     ___                               "
echo "     / \   ___| |_ ___ _ __ _ __  _   _ _ __ ___    / _ \ _ __ ___   ___  __ _  __ _   "
echo "    / _ \ / _ \ __/ _ \ '__| '_ \| | | | '_ ' _ \  | | | | '_ ' _ \ / _ \/ _' |/ _' |  "
echo "   / ___ \  __/ ||  __/ |  | | | | |_| | | | | | | | |_| | | | | | |  __/ (_| | (_| |  "
echo "  /_/   \_\___|\__\___|_|  |_| |_|\__,_|_| |_| |_|  \___/|_| |_| |_|\___|\__, |\__,_|  "
echo "                                                                         |___/         "
echo "                                                                                       "
echo
echo
sleep 2s
clear

sleep 1s



steamid=null
desktopname=null
appname=null
answersteamid=n
answername=n

while [[ ${answername,,} == n ]]; do
    echo
    echo "What's the \"pretty\" name you want to give the application?"
    echo
    read ANAME
    echo
    echo "Is \"$ANAME\" correct?"
    echo
    read answername
    if [[ ${answername,,} == y ]]; then
        appname=$ANAME
        desktopname=`echo "$appname" | sed -e 's/ //g' -e 's/.*/\L&/g'`
        echo
        echo "The .desktop will be at \"$HOME/.local/share/applications/$desktopname.desktop\""
        echo
    fi
done

echo

while [[ ${answersteamid,,} == n ]]; do
    echo
    echo "What's the SteamID of the game?"
    echo "You can search for your game's Steam ID here: https://steamdb.info/"
    echo
    read STNAME
    echo
    echo "Is \"$STNAME\" correct?"
    echo
    read answersteamid
    if [[ ${answersteamid,,} == y ]]; then
        steamid=$STNAME
    fi
done

echo
echo "Creating $desktopname.desktop"
echo

if test -e $HOME/.local/share/applications/$desktopname.desktop; then
    echo
    echo "Found another app with the same name, backing up"
    echo
    mv $HOME/.local/share/applications/$desktopname.desktop $HOME/.local/share/applications/$desktopname.desktop.bkp
    sleep 1s
fi

touch $HOME/.local/share/applications/$desktopname.desktop
chmod +x $HOME/.local/share/applications/$desktopname.desktop
sleep 1s

echo
echo "Configuring $desktopname.desktop"
echo

printf "[Desktop Entry]\n" | tee $HOME/.local/share/applications/$desktopname.desktop
printf "Name=$appname\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Comment=Play this game on Steam\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Exec=steam steam://rungameid/$steamid\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Icon=steam\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Terminal=false\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Type=Application\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Categories=Games;\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop

sleep 1s

echo
echo "Do you want to be able to open the app through a terminal?"
echo
read TERMINAL
if [[ ${TERMINAL,,} == y ]]; then
    echo
    echo "Configuring to open through terminal"
    echo
    if ! test -e $HOME/.bash_aliases; then
        mkdir $HOME/.bash_aliases
    fi
    sleep 1s
    if ls /usr/bin/*session | grep gnome; then
        printf "\nalias $desktopname='gtk-launch $desktopname &'\n" | tee -a $HOME/.bash_aliases
    fi
    if ls /usr/bin/*session | grep plasma; then
        printf "\nalias $desktopname='kioclient exec $HOME/.local/share/applications/$desktopname.desktop &'\n" | tee -a $HOME/.bash_aliases
    fi
    echo
    echo "Restart your terminal to start using it"
    echo
fi

echo
echo "Done"
echo
exit 0
