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
    sleep 1s
    exit 1
fi

echo
echo "Choose \"1) unreal-engine\" when asked about available providers NOT the -bin one"
echo
echo "Make changes to the \"unreal-engine.PKGBUILD\" file"
echo "At line 49: Change \"_install_dir=\"opt/${pkgname}\"\" to \"_install_dir=\"your/custom/path/${pkgname}\"\""
echo "At line 52: Change \"_WithDDC=false\" to \"_WithDDC=true\""
echo
sleep 2s
echo
echo "This will take a long time"
echo
sleep 2s
paru -S unreal-engine --sudoloop
echo
echo "Done!"
echo
echo "Press Y to reboot now or N if you plan to manually reboot later."
echo

read REBOOT
if [ ${REBOOT,,} = y ]; then
    reboot
fi
exit 0
