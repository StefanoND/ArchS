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
echo "System update/upgrade"
echo
paru
sleep 1s
if pacman -Q | grep rust; then
    echo
    echo "rustup update/upgrade"
    echo
    rustup self upgrade-data
    sleep 1s
fi
if pacman -Q | grep flatpak; then
    echo
    echo "flatpak update/upgrade"
    echo
    flatpak update -y
    sleep 1s
fi
if pacman -Q | grep wine; then
    echo
    echo "wine update/upgrade"
    echo
    sudo winetricks --self-update
    sleep 1s
fi
echo
echo "Demon-reload"
echo
sudo systemctl daemon-reload
sleep 1s
echo
echo "Restarting cups"
echo
sudo systemctl restart cups
sleep 1s
echo
echo "Modprobin NVidia"
echo
sudo nvidia-modprobe
sleep 1s
echo
echo "Updating systemd-boot"
echo
sudo bootctl update
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
