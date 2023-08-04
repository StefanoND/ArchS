#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
    exit 1
fi

if ! groups|grep wheel>/dev/null;then
    echo
    echo "You need to be a member of the wheel to run me!"
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
echo "This script will apply the correct settings to your patched.rom file"
echo
sleep 1s
if test -e "/usr/share/vgabios/patched.rom"; then
    sudo chmod -R 644 /usr/share/vgabios/patched.rom
    sleep 1s
    sudo chown $(logname):$(logname) /usr/share/vgabios/patched.rom
    echo
    echo "Done"
    echo
else
    echo
    echo "There's not \"patched.rom\" in \"/usr/share/vgabios\"."
    echo "Make sure the file and/or folder exists and named correctly."
    echo
    echo "Run this script again when you're done."
    echo
    exit 1
fi
exit 0
