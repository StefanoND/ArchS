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

desktopname=null
appname=null
appicon=system-run
apppath=null
catname="null"
workpath=null
normalpath=null
scriptpath=null
winepath=null
appcategory="Utilities;"
appversion=1.0
appcomment=null
answerdesktop=n
answername=n
answericon=n
answercomment=n
answerexec=n
answercategory=n
answerversion=n

isscript=n
iswine=n

filename=n
rawpath=n

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
    fi
done

echo

while [[ ${answerdesktop,,} == n ]]; do
    echo
    echo "What's the name you want to give to the .desktop file?"
    echo
    read DTNAME
    echo
    echo "Is \"$DTNAME\" correct?"
    echo
    read answerdesktop
    if [[ ${answerdesktop,,} == y ]]; then
        desktopname=$DTNAME
        appcomment="$desktopname Appified"
    fi
done

echo

while [[ ${answerexec,,} == n ]]; do
    wineprefix=$HOME/.wine
    tmploc=n
    tmppath=n
    echo
    echo "Is the executable a script (.sh) file? Press Y for yes or N for no"
    echo
    read ISSCRIP
    if [[ ${ISSCRIP,,} == y ]]; then
        isscript=y
    fi
    if [[ ${isscript,,} == n ]]; then
        echo
        echo "Is the executable a windows executable (.exe) file? Press Y for yes or N for no"
        echo
        read ISWIN
        if [[ ${ISWIN,,} == y ]]; then
            iswine=y
            while ! test -e $tmploc; do
                echo
                echo "What's the path your custom wineprefix? Don't add \"WINEPREFIX=\" it'll be added automatically"
                echo "Leave empty for default \"$HOME/.wine\""
                echo
                read WPREFIX
                tmploc=$WPREFIX
                if [[ ${tmploc,,} == "" ]]; then
                    tmploc=$wineprefix
                fi
                wineprefix="'$tmploc'"
            done
        fi
    fi
    while ! test -e "$tmppath"; do
        echo
        echo "What's the executable path?"
        echo "You can \"Right Click->Copy Location\" the file itself and paste it in here"
        echo
        read APATH
        tmppath=$APATH
        if test -e "$tmppath"; then
            answerexec=y
            rawpath=$tmppath
            workpath="${tmppath%/*}"
            if [[ ${isscript,,} == y ]]; then
                scriptpath="'$tmppath'"
                apppath="bash $scriptpath"
            elif [[ ${iswine,,} == y ]]; then
                winepath="'$tmppath'"
                apppath="WINEPREFIX=$wineprefix wine $winepath"
            else
                normalpath="'$tmppath'"
                apppath=$normalpath
            fi
        fi
    done
done

echo

while [[ ${answericon,,} == n ]]; do
    echo
    echo "What's the icon path? Leave empty for default icon"
    echo "You can \"Right Click->Copy Location\" the file itself and paste it in here"
    echo
    read AICON
    if test -e "$AICON"; then
        answericon=y
        appicon=$AICON
    else
        echo
        echo "\"$AICON\" doesn't exist"
        echo
    fi
done

echo

while [[ ${answercategory,,} == n ]]; do
    echo
    echo "What's the application category? Leave empty for default (Utilities)"
    echo "0 - Development"
    echo "1 - Games"
    echo "2 - Graphics"
    echo "3 - Internet"
    echo "4 - Multimedia"
    echo "5 - Office"
    echo "6 - Science & Math"
    echo "7 - Settings"
    echo "8 - System"
    echo "9 - Utilities"
    echo
    read ACATEGORY
    if [[ ${ACATEGORY,,} == "" ]]; then
        answercategory=y
        appcategory="Utilities;"
    else
        case $ACATEGORY in
            0) catname="Development;" ;;
            1) catname="Games;" ;;
            2) catname="Graphics;" ;;
            3) catname="Internet;" ;;
            4) catname="Multimedia;" ;;
            5) catname="Office;" ;;
            6) catname="Science & Math;" ;;
            7) catname="Settings;" ;;
            8) catname="System;" ;;
            9) catname="Utilities;" ;;
            *) catname="Utilities;" ;;
        esac
        echo
        echo "Is \"$catname\" correct?"
        echo
        read answercategory
        if [[ ${answercategory,,} == y ]]; then
            appcategory=$catname
        fi
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
printf "Categories=$appcategory\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Comment=\"$appcomment\"\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Exec=$apppath\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Path=$workpath\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Icon=$appicon\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Name=$appname\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "StartupNotify=true\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Terminal=false\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Type=Application\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop
printf "Version=$appversion\n" | tee -a $HOME/.local/share/applications/$desktopname.desktop

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
