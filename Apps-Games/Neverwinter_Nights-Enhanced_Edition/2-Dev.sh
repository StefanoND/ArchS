#!/usr/bin/env bash

# Nim updated to version 2.0 and currently Nasher doesn't support it, so this script will install nim 1.6.14

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this program as root."
    echo
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
echo "                        Archlinux Post-Install Setup and Config"
echo
echo
sleep 2s
clear

sleep 1s

echo
echo "Installing Nim"
echo
wget -o - init.sh https://nim-lang.org/choosenim/init.sh
sed -i 's/CHOOSE_VERSION=.*/CHOOSE_VERSION="1.6.14"/g' init.sh
./init.sh

echo
echo "Adding Nimble to PATH"
echo
printf "\nexport PATH=\$HOME/.nimble/bin:\$PATH\n" | tee -a $HOME/.bashrc

echo
echo "Installing \"neverwinter.nim\""
echo
~/.nimble/bin/nimble install neverwinter

echo
echo "Installing \"nasher\""
echo
~/.nimble/bin/nimble install nasher

confirmrootfolder=n
confirmhomefolder=n
rootfolder=null
homefolder=null

while [[ ${confirmrootfolder,,} = n ]]; do
    echo
    echo "What's the path to your NWN install folder? (It's usually \"$HOME/.local/share/Steam/steamapps/common/Neverwinter Nights\")"
    echo "Unless you have it in an external drive (Like \"/PATH/TO/EXTERNAL_DRIVE/SteamLibrary/steamapps/common/Neverwinter Nights\")"
    echo "Or if you're using flatpak it should be in:"
    echo "\"$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Neverwinter Nights\""
    echo
    read RTFOLDER
    rootfolder=$RTFOLDER
    if ! test -e $rootfolder; then
        rootfolder=null
        echo
        echo "Not found path to \"$rootfolder\""
        echo "Try again"
        echo
    else
        confirmrootfolder=y
    fi
done
while [[ ${confirmhomefolder,,} = n ]]; do
    echo
    echo "What's the path to your NWN Document folder? (It's usually \"$HOME/.local/share/Neverwinter Nights\")"
    echo "Or if you're using flatpak it should be in:"
    echo "\"$HOME/.var/app/com.valvesoftware.Steam/data/Neverwinter Nights\""
    echo
    read HEFOLDER
    homefolder=$HEFOLDER
    if ! test -e $homefolder; then
        homefolder=null
        echo
        echo "Not found path to \"$homefolder\""
        echo "Try again"
        echo
    else
        confirmhomefolder=y
    fi
done

# Sanity check
if test -e $rootfolder; then
    export NWN_ROOT="$rootfolder"
fi
if test -e $homefolder; then
    export NWN_HOME="$homefolder"
fi

echo
echo "Downloading \"NWScript Compiler\""
echo
wget https://github.com/nwneetools/nwnsc/releases/download/v1.1.5/nwnsc-linux-v1.1.5.zip
echo
echo "Extracting \"nwnsc-linux-v1.1.5.zip\""
echo
unzip nwnsc-linux-v1.1.5.zip
echo
echo "Moving \"nwnsc\" to \"$HOME/.nimble/bin\""
echo
mv nwnsc $HOME/.nimble/bin
echo
echo "Removing leftovers"
echo
rm nwnsc-linux-v1.1.5.zip

echo
echo "Making nasher recognizer nwnsc's location"
echo
nasher config nssCompiler "$HOME/.nimble/bin/nwnsc"

echo
echo "Your Nasher configuration file is in \"$HOME/.config/nasher/user.cfg\""
echo
echo
echo "For further configuration check Squatting Monk's Nasher github repo"
echo "https://github.com/squattingmonk/nasher"
echo

echo
echo "Done"
echo
exit 0
