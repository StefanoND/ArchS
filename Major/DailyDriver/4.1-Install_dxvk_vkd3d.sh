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

echo
echo "Intalling DXVK on Wineprefixes"
echo
sleep 1s

PKGS=(
    "/home/$(logname)/.wine"                        # Main WINE
#    ""                        # Custom WINE
)

for PKG in "${PKGS[@]}"; do
    if ! test -e "$PKG"; then
        echo
        echo "Wineprefix \"$PKG\" not found, creating..."
        echo
        sleep 1s
        WINEPREFIX="$PKG" wineboot
        sleep 1s
        echo
        echo "Wineprefix \"$PKG\" created."
        echo
        sleep 1s
    fi
    
    echo
    echo "Copying DXVK's 32-Bit DLLs to \"$PKG/drive_c/windows/system32\""
    echo
    sleep 1s
    cp /usr/share/dxvk/x32/*.dll $PKG/drive_c/windows/system32
    sleep 1s
    echo
    echo "Copying DXVK's 64-Bit DLLs to \"$PKG/drive_c/windows/syswow64\""
    echo
    sleep 1s
    cp /usr/share/dxvk/x64/*.dll $PKG/drive_c/windows/syswow64
    sleep 1s
    echo
    echo "Copying VKD3D's 32-Bit DLLs to \"$PKG/drive_c/windows/system32\""
    echo
    sleep 1s
    cp /usr/share/vkd3d-proton/x86/*.dll $PKG/drive_c/windows/system32
    sleep 1s
    echo
    echo "Copying VKD3D's 64-Bit DLLs to \"$PKG/drive_c/windows/syswow64\""
    echo
    sleep 1s
    cp /usr/share/vkd3d-proton/x64/*.dll $PKG/drive_c/windows/syswow64
    sleep 1s
done

sleep 1s
echo
echo " Done!"
echo
sleep 1s
exit 0
