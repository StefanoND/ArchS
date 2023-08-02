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

if ! test -e /etc/udev/rules.d/10-cups-usb.rules; then
    sudo touch /etc/udev/rules.d/10-cups-usb.rules
    sleep 1s
fi

vendorid=0
productid=0
vendortrue=n
producttrue=n

lsusb

echo
echo "What is the Vendor ID and Product ID of your printer? It'll look like this:"
echo "Bus XXX Device XXX: ID VENDORIR:PRODUCTID Printer Name"
echo "Example: \"Bus 003 Device 008: ID 03f0:e111 HP, Inc DeskJet 2130 series\""
echo
echo "So in this case, Vendor ID=03f0 and Product ID=e111"
echo
echo
while [[ ${vendortrue,,} = n ]]; then
    echo
    echo "What is the Vendor ID?"
    echo
    read VENDID
    vendorid=$VENDID
    if ! lsusb | grep -q $vendorid; then
        echo
        echo "Invalid Product ID"
        echo
    else
        vendortrue=y
    fi
done
while [[ ${producttrue,,} = n ]]; then
    echo
    echo "What is the Product ID?"
    echo
    read PRODDID
    productid=$PRODDID
    if ! lsusb | grep -q $productid; then
        echo
        echo "Invalid Product ID"
        echo
    else
        producttrue=y
    fi
done
sleep 1s

printf "ATTR{idVendor}==\"$vendorid\", ATTR{idProduct}==\"$productid\", MODE:=\"0664\", GROUP:=\"lp\", ENV{libsane_matched}:=\"yes\"" | sudo tee /etc/udev/rules.d/10-cups-usb.rules
sleep 1s

if ! groups|grep lp>/dev/null;then
    echo
    echo "Adding \"$(logname)\" to \"lp\" group"
    echo
    sudo usermod -aG lp $(logname)
    sleep 1s
fi

echo
echo "Restarting udev service"
echo
sudo systemctl restart systemd-udevd.service
sleep 1s

echo
echo "Done"
echo
exit 0
