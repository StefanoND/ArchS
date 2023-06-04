#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
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
echo "                                  Post-Install Script"
echo
echo
sleep 2s
clear

sleep 1s

echo
echo "pacman update/upgrade"
echo
sleep 1s
sudo pacman -Syu --noconfirm --needed
sleep 1s
echo
echo "Paru update/upgrade"
echo
sleep 1s
paru -Syu --noconfirm --needed --sudoloop
sleep 1s
echo
echo "rus
sleep 1stup update/upgrade"
echo
rustup self upgrade-data
sleep 1s
echo
echo "flatpak update/upgrade"
echo
sleep 1s
flatpak update
sleep 1s
cd /usr/bin/
sudo ./cups-genppdupdate
cd ~
echo
echo "wine update/upgrade"
echo
sleep 1s
sudo winetricks --self-update

sleep 1s
echo
echo "Demon-reload"
echo
sleep 1s
sudo systemctl daemon-reload
sleep 1s
echo
echo "Restart cups"
echo
sleep 1s
sudo systemctl restart cups

sleep 1s
echo
echo "update-grub"
echo
sleep 1s
sudo update-grub
sleep 1s

echo
echo "Done!"
echo "Press Y to reboot now or N if you plan to manually reboot later."
echo
read REBOOT
if [ ${REBOOT,,} = y ]; then
    reboot
fi
exit 0
