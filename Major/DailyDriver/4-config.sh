#!/usr/bin/env bash

echo
echo "      _        _                                     ___                               "
echo "     / \   ___| |_ ___ _ __ _ __  _   _ _ __ ___    / _ \ _ __ ___   ___  __ _  __ _   "
echo "    / _ \ / _ \ __/ _ \ '__| '_ \| | | | '_ ' _ \  | | | | '_ ' _ \ / _ \/ _' |/ _' |  "
echo "   / ___ \  __/ ||  __/ |  | | | | |_| | | | | | | | |_| | | | | | |  __/ (_| | (_| |  "
echo "  /_/   \_\___|\__\___|_|  |_| |_|\__,_|_| |_| |_|  \___/|_| |_| |_|\___|\__, |\__,_|  "
echo "                                                                         |___/         "
echo "                        Archlinux Post-Install Setup and Config"
echo

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    exit 1
fi

sleep 1s

if ! test -e /usr/lib/udev/rules.d/60-antimicrox-uinput.rules; then
    echo
    echo "Creating udev rule for AntiMicroX to avoid problems with wayland"
    echo
    cd /usr/lib/udev/rules.d/
    sudo wget https://raw.githubusercontent.com/AntiMicroX/antimicrox/master/other/60-antimicrox-uinput.rules
fi

sleep 1s

echo
echo " Done!"
echo

sleep 1s

echo
echo "press Y to reboot now or N if you plan to manually reboot later."
echo

read REBOOT
if [ ${REBOOT,,} = y ]; then
    sudo reboot now
fi
exit 0
