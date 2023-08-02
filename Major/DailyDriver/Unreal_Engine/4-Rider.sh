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
echo "CD'ing to \"/tmp\""
echo
cd /tmp
sleep 1s
echo
echo "Downloading \"Rider Source Code Access\""
echo
wget -c https://github.com/JetBrains/RiderSourceCodeAccess/archive/refs/heads/main.zip -O RiderSourceCodeAccess-main.zip
sleep 1s
echo
echo "Unzipping \"RiderSourceCodeAccess-main.zip\""
echo
unzip RiderSourceCodeAccess-main.zip
sleep 1s
echo
echo "Renaming \"RiderSourceCodeAccess-main\" to \"RiderSourceCodeAccess\""
echo
mv RiderSourceCodeAccess-main RiderSourceCodeAccess
sleep 1s
echo
echo "Copying \"RiderSourceCodeAccess\" to \"/mnt/SSD_WORK/Unreal/Editors/UnrealEngine5_2/Engine/Plugins/Developer\""
echo
cp -r RiderSourceCodeAccess "/mnt/SSD_WORK/Unreal/Editors/UnrealEngine5_2/Engine/Plugins/Developer"
sleep 1s
echo
echo "Removing leftovers"
echo
rm -r RiderSourceCodeAccess
rm RiderSourceCodeAccess-main.zip
sleep 1s

echo
echo "Now create a C++ project. Once it's created and the Editor shows up (If it's your first time creating a C++ project, click on \"Disable VSCode\")"
echo "In \"Editor Settings\" click on the \"Source Code\" tab, in there click on the dropdown and select \"Rider UProject\", restart and done"
echo "You can also \"Set Default\" for future projects"
echo
echo "Open a C++ class in Rider and install \"RiderLink\" in engine"
echo "You may click on \"Set as Default\" for future projects as well"
echo
sleep 1s
echo
echo "Sometimes it may complain about \"RiderSourceCodeAccess\" just open Unreal Editor through Rider's \"Run\" button on the Top-Right corner"
echo

exit 0
