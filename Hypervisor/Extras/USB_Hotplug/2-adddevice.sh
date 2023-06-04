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
echo "ADDING DEVICES TO HOTPLUG"
echo

sleep 1s

if ! test -e /etc/udev/rules.d
    then
        sudo mkdir -p /etc/udev/rules.d
fi
if ! test -e /etc/udev/rules.d/90-usb-libvirt-hotplug.rules
    then
        sudo touch /etc/udev/rules.d/90-usb-libvirt-hotplug.rules
fi

sleep 1s

answer=y
while [ ${answer,,} = y ]
    do
        lsusb

        echo
        echo "What's the Vendor ID? It's the XXXX in Bus.. Device... ID XXXX:YYYY Device Name..."
        read VENDORID

        echo
        echo "What's the Model ID? It's the YYYY in Bus.. Device... ID XXXX:YYYY Device Name..."
        read MODELID

        echo
        echo "What's the VM Name?"
        read OSNAME

        echo -e "SUBSYSTEM==\"usb\", ENV{ID_VENDOR_ID}==\"$VENDORID\", ENV{ID_MODEL_ID}==\"$MODELID\", RUN+=\"/opt/usb-libvirt-hotplug/usb-libvirt-hotplug.sh $OSNAME\"\n" | sudo tee -a /etc/udev/rules.d/90-usb-libvirt-hotplug.rules
        
        echo
        echo "Do you want to add another device?"
        echo

        read answer
        if [ ${answer,,} = y ]
            then echo ""
        fi
done

sleep 1s

echo
echo "Applying changes and restarting udev service"
echo
sleep 1s
sudo systemctl restart systemd-udevd.service

sleep 1s

echo
echo "Done"
echo
exit 0
