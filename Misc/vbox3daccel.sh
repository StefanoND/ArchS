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

sleep 1s

distro=n

echo
echo "Are you using Debian or Arch based distro? 1 - Deb | 2 - Arch"
echo
read WHICHDISTRO

if [[ ${WHICHDISTRO,,} == 1 ]]; then
    sudo apt update
    sudo apt install build-essential dkms linux-headers-$(uname -r) -y
    echo
    echo "Insert Guest Additions CD, press anything when you're done"
    echo
    read ANYTHING
    sudo mount /dev/cdrom /mnt
    cd /mnt
    sudo ./VBoxLinuxAdditions.run
    sudo /usr/sbin/modprobe -a vboxguest vboxsf vboxvideo
elif [[ ${WHICHDISTRO,,} == 2 ]]; then
    sudo pacman -Syy
    sudo pacman -S dkms virtualbox-guest-utils --noconfirm --needed
    sudo modprobe -a vboxguest vboxsf vboxvideo
fi

if ! [[ -f /etc/systemd/system/vbclient.service ]]; then
    sudo touch /etc/systemd/system/vbclient.service
    printf "[Unit]\nDescription=VBoxClient\n\n[Service]\nExecStart=/bin/bash VBoxClient-all\n\n[Install]\nWantedBy=multi-user.target\n" | sudo tee /etc/systemd/system/vbclient.service
fi

sudo systemctl enable vbclient.service

echo
echo "You may now shut down and enable 3D Acceleration"
echo

exit 0
