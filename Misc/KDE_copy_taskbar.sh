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
echo "                        Archlinux Post-Install Setup and Config"
echo
echo
sleep 2s
clear

sleep 1s

echo
echo "If you have multiple monitors and want to use the same taskbar layout for all of them, this script will help you"
echo
echo "If you want to copy your taskbar/panel to another monitor go to ~/.config/plasma-org.kde.plasma.desktop-appletsrc"
echo
echo "Find your panel, easiest way to find is the one that has matching icons in your taskbar"
echo
echo "Copy all containments of the same number (Ignore the numbers that comes after Applets)"
echo
echo "Create a new task and pin an icon to make it unique, find it in the text"
echo
echo "Replace all containments of the same number with the one you copied"
echo
echo "You may need to remove and readd the System Tray widget on the other taskbar"
echo
echo "Run script below"
echo

sleep 1s

echo "Press Y to run the script after you've done with the steps above"
read CONFIRM
if [ ${CONFIRM,,} = y ]; then
    echo
    echo "What is your Plasma version: 1 = 5.10 or above, 2 = between 5 and < 5.10, 3 = 4"
    read VERSION
    if [ ${VERSION,,} = 1 ]; then
        echo
        echo "Is version 5.10 right? Press Y to confirm"
        read CONFIRMVERSIONONE
        if [ ${CONFIRMVERSIONONE,,} = y ]; then
            # Build binary cache of the data stored in .desktop and MIME type .xml files that the KService framework uses to find plugins, applications and other services.
            kbuildsycoca5
            timeout 5 kquitapp5 plasmashell || killall plasmashell
            sleep 1s
            kstart5 plasmashell
        fi
    elif [ ${VERSION,,} = 2 ]; then
        echo
        echo "Is version between 5 and < 5.10 right? Press Y to confirm"
        read CONFIRMVERSIONTWO
        if [ ${CONFIRMVERSIONTWO,,} = y ]; then
            # Build binary cache of the data stored in .desktop and MIME type .xml files that the KService framework uses to find plugins, applications and other services.
            kbuildsycoca5
            timeout 5 killall plasmashell
            sleep 1s
            kstart plasma-desktop
        fi
    elif [ ${VERSION,,} = 3 ]; then
        echo
        echo "Is version 4 right? Press Y to confirm"
        read CONFIRMVERSIONTHREE
        if [ ${CONFIRMVERSIONTHREE,,} = y ]; then
            # Build binary cache of the data stored in .desktop and MIME type .xml files that the KService framework uses to find plugins, applications and other services.
            kbuildsycoca5
            timeout 5 killall plasma-desktop
            sleep 1s
            kstart plasma-desktop
        fi
    fi

    sleep 1s
    echo
    echo "The taskbar/panel is ontop of each other on the main screen, just make one taskbar/panel autohide"
    echo
    echo "Now you can see the other panel and enter edit mode and drag it to the other monitor"
    echo
    echo "Disable autohide from the taskbar/panel and you're done, repeat these steps for other monitor(s)"
    echo
    sleep 1s
fi

echo
echo "Done"
echo
exit 0
