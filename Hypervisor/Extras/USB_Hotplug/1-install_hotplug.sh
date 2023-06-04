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
echo "CONFIGURING USB HOTPLUG"
echo

if test -e /opt/usb-libvirt-hotplug/usb-libvirt-hotplug.sh;
    then
        sudo mv /opt/usb-libvirt-hotplug/usb-libvirt-hotplug.sh /opt/usb-libvirt-hotplug/usb-libvirt-hotplug.sh.old
        chmod +x /opt/usb-libvirt-hotplug/usb-libvirt-hotplug.sh
        sudo cp usb-libvirt-hotplug.sh /opt/usb-libvirt-hotplug;
elif ! test -e /opt/usb-libvirt-hotplug;
    then
        sudo mkdir -p /opt/usb-libvirt-hotplug;
        chmod +x /opt/usb-libvirt-hotplug/usb-libvirt-hotplug.sh
        sudo cp usb-libvirt-hotplug.sh /opt/usb-libvirt-hotplug;
fi

sleep 1s
echo
echo "Done"
echo
exit 0
