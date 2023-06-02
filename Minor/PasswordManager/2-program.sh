#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
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
echo "                                  Post-Install Script"
echo
echo
sleep 2s
clear

echo
echo "Do you want to install PWGen?"
echo "Y - Yes | N - No"
echo
read PWG
if [[ ${PWG,,} = y ]]; then
    echo
    echo "Installing PWGen"
    echo
    sleep 1s
    sudo pacman -S pwgen --noconfirm --needed
    sleep 1s
fi

PWM=0

echo
echo "Which password manager you want to install?"
echo
echo "1 - Bitwarden"
echo "2 - KeePassXD"
echo "3 - Pass"
echo "4 - All"
echo "Anything else - skip"
echo
read WHICH
PWM=$WHICH

if [[ ${PWM,,} = 1 ]] || [[ ${PWM,,} = 4 ]]; then
    echo
    echo "Installing Bitwarden"
    echo
    sleep 1s
    flatpak install flathub com.bitwarden.desktop -y --or-update
    sleep 1s
elif [[ ${PWM,,} = 2 ]] || [[ ${PWM,,} = 4 ]]; then
    echo
    echo "Installing KeePassXC"
    echo
    sleep 1s
    flatpak install flathub org.keepassxc.KeePassXC -y --or-update
    sleep 1s
elif [[ ${PWM,,} = 3 ]] || [[ ${PWM,,} = 4 ]]; then
    echo
    echo "Installing Pass"
    echo
    sleep 1s
    sudo pacman -S pass --noconfirm --needed
    sleep 1s
fi

echo
echo "Done"
echo

exit 0
