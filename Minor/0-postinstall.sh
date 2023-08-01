#!/bin/bash

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

echo
echo "Updating repo"
echo
sudo apt update
sleep 1s

echo
echo "Installing dependencies"
echo
sudo apt install build-essential make dkms gcc linux-headers-$(uname -r) -y
sleep 1s

echo
echo "Insert Guest Additions CD, press anything when you're done"
echo
read ANYTHING

echo
echo "Mounting Guest Additions to /mnt"
echo
sudo mount /dev/cdrom /mnt
cd /mnt
sudo chmod +x VBoxLinuxAdditions.run
sudo ./VBoxLinuxAdditions.run
sleep 1s

echo
echo "Modprobing 'vboxguest', 'vboxsf' and 'vboxvideo'"
echo
sudo /usr/sbin/modprobe -a vboxguest vboxsf vboxvideo
sleep 1s

if ! [[ -f /etc/systemd/system/vbclient.service ]]; then
    echo
    echo "Creating a service named 'vbclient.service' that will run 'VBoxClient-all' command"
    echo "So all host-guest interactions works"
    echo
    sudo touch /etc/systemd/system/vbclient.service
    printf "[Unit]\nDescription=VBoxClient\n\n[Service]\nExecStart=/bin/bash VBoxClient-all\n\n[Install]\nWantedBy=multi-user.target\n" | sudo tee /etc/systemd/system/vbclient.service
    sleep 1s

    echo
    echo "Enabling 'vbclient.service'"
    echo
    sudo systemctl enable vbclient.service
    sleep 1s
fi

echo
echo "Done, Shutdown the system, turn 3D Acceleration on and turn back on"
echo
read ANYTH
shutdown now
