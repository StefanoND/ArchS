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

sleep 1s

echo
echo "Installing Minecraft"
echo

sleep 1s

echo
echo "Installing Java"
echo

sleep 1s

sudo pacman -S jre-openjdk jdk-openjdk --noconfirm --needed

sleep 1s

echo
echo "Do you want to use a custom launcher? Y - Yes | N - No"
echo

read CUSTOML
if [ ${CUSTOML,,} = y ]; then
    echo
    echo "Which custom laucher you want to install?"
    echo
    echo "1 - Default"
    echo "2 - ATLauncher"
    echo "3 - GDLauncher"
    echo "4 - Prism Launcher"
    read LAUNCH
    if [ ${LAUNCH,,} =  1]; then
        echo
        echo "Which Edition of Minecraft do you want to install?"
        echo
        echo "1 - Java Edition"
        echo "2 - Bedrock Edition"
        echo "3 - Both"
        echo
        read EDIT
        if [ ${EDIT,,} =  1]; then
            flatpak install flathub com.mojang.Minecraft -y --or-update
        elif [ ${EDIT,,} =  2]; then
            flatpak install flathub io.mrarm.mcpelauncher -y --or-update
        elif [ ${EDIT,,} =  3]; then
            flatpak install flathub com.mojang.Minecraft -y --or-update
            flatpak install flathub io.mrarm.mcpelauncher -y --or-update
        fi
    elif [ ${LAUNCH,,} =  2]; then
        flatpak install flathub com.atlauncher.ATLauncher -y --or-update
    elif [ ${LAUNCH,,} =  3]; then
        flatpak install flathub io.gdevs.GDLauncher -y --or-update
    elif [ ${LAUNCH,,} =  4]; then
        flatpak install flathub org.prismlauncher.PrismLauncher -y --or-update
    fi
fi

sleep 1s
echo
echo " Done!"
echo
sleep 1s
exit 0
