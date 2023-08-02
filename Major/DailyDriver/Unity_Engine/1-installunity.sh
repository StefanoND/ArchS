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
    'gconf'                         # Required for version 2019.4 or older
    'libicu50'                      # Compile Error Fix
    'icu70'                         # Compile Error Fix
    'unityhub'                      # Unity
#    ''
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    paru -S "$PKG" --noconfirm --needed --sudoloop
    sleep 1s
done

echo
echo "Done!"
echo
sleep 1s
echo
echo "Now you can open Unity Hub, log in and install the Editors."
echo
echo "For Rider integration, create/open a project, once it's loaded click on \"Edit->Preferences\""
echo "The \"Preferences\" window will pop up, click on the \"External Tools\" tab"
echo "In the \"External Script Editor\" change to \"Rider XXXX.X.X\" where X's are the Rider's version"
echo "Done. Now you can double-click the scripts in Unity Editor and they'll automatically open with Rider"
echo
sleep 1s
exit 0
