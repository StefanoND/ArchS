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

PKGS=(
    "/home/$(logname)/.wine"                            # Main WINE
#    ""                            # Custom WINE
)

for PKG in "${PKGS[@]}"; do
    if [[ $PKG == *"/.var/app/"* ]]; then
        echo
        echo "\"$PKG\" is a Flatpak app!"
        echo "Do not use this script for Flatpak apps, use ProtonUP-QT instead!"
        echo
        sleep 1s
        echo
        echo "Skipping"
        echo
        sleep 2s
        continue
    fi
    if ! test -e "$PKG"; then
        echo
        echo "Wineprefix \"$PKG\" not found, creating..."
        echo
        sleep 2s
        WINEPREFIX="$PKG" wineboot
        sleep 1s
        echo
        echo "Wineprefix \"$PKG\" created."
        echo
        sleep 2s
        echo
        echo "Continuing..."
        echo
        sleep 1s
    fi

    echo
    echo "Copying DXVK and VKD3D DLLs to \"$PKG\""
    echo

    sleep 1s

    echo
    echo "Copying DXVK's 32-Bit DLLs to \"$PKG/drive_c/windows/system32\""
    echo
    sleep 1s
    cp -rf /usr/share/dxvk/x32/*.dll $PKG/drive_c/windows/system32
    sleep 1s
    echo
    echo "Copying DXVK's 64-Bit DLLs to \"$PKG/drive_c/windows/syswow64\""
    echo
    sleep 1s
    cp -rf /usr/share/dxvk/x64/*.dll $PKG/drive_c/windows/syswow64
    sleep 1s
    echo
    echo "Copying VKD3D's 32-Bit DLLs to \"$PKG/drive_c/windows/system32\""
    echo
    sleep 1s
    cp -rf /usr/share/vkd3d-proton/x86/*.dll $PKG/drive_c/windows/system32
    sleep 1s
    echo
    echo "Copying VKD3D's 64-Bit DLLs to \"$PKG/drive_c/windows/syswow64\""
    echo
    sleep 1s
    cp -rf /usr/share/vkd3d-proton/x64/*.dll $PKG/drive_c/windows/syswow64
    sleep 1s
done

sleep 1s
echo
echo " Done!"
echo
sleep 1s
exit 0
