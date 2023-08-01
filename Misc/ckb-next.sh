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

echo
echo "Installing ckb-next"
echo
paru -S ckb-next-git --noconfirm --needed --sudoloop

echo
echo "Open a new terminal window/tab run this command:"
echo "sudo EDITOR=nano systemctl edit ckb-next-daemon"
echo "Add these lines into ckb-next-daemon.service"
echo
echo "[Service]"
echo "ExecStart="
echo "ExecStart=/usr/bin/ckb-next-daemon --enable-experimental"
echo
echo "Save and close it, press any button when you're done"
read ANYBTN

sudo systemctl enable --now ckb-next-daemon.service

echo
echo "Done"
echo
exit 0
