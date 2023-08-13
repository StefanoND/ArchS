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

# PACMAN
PKGX=(
    'docker'                                    #
    'docker-buildx'                             #
    'wine-staging'                              # Compatibility Layer for running Windows programs (Staging Branch)
    'winetricks'                                # Work around problems and install apps under Wine
    'wine-mono'                                 # Wine's built-in replacement for Microsoft's .NET Framework
    'wine-gecko'                                # Wine's built-in replacement for Microsoft's Internet Explorer
#    'dos2unix'                                  # Converting DOS stuff to unix
#    'lutris'                                    # Lutris
#    'steam'                                     # Steam
    'distrobox'                                 #
#    ''                                          #
)

for PKG in "${PKGX[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo pacman -S "$PKG" --noconfirm --needed
    echo
    sleep 1s
done

# AUR
PKGY=(
    'qt5-tools'
    'deckboard-appimage'                        # Streamdeck alternative
#    'protonup-qt'                               # ProtonUp-Qt
#    'eam-git'                                   # Epic Games' Marketplace for Linux
#    'heroic-games-launcher-bin'                 # Epic Games and GOG launcher
#    'bottles'                                   # Bottles
#    'protontricks'                              # Wrapper to make winetricks work with Proton enabled games
#    'dxvk-bin'                                  # Vulkan-based compatibility layer for Direct3D 9/10/11
#    'vkd3d-proton-mingw'                        # Vulkan-based compatibility layer for Direct3D 12
#    'jetbrains-toolbox'                         #
    'mullvad-vpn'                               # VPN
#    'davinci-resolve'                           # Video editing software
#    ''                                          #
)

for PKG in "${PKGY[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    paru -S "$PKG" --noconfirm --needed --sudoloop
    echo
    sleep 1s
done

echo
echo "Fixing cursor changing to Default when over flatpak apps"
echo
sleep 1s
echo 'cp -nur /usr/share/icons $HOME/.icons'
cp -nur /usr/share/icons $HOME/.icons
echo 'cp -nur $HOME/.icons /usr/share/icons'
cp -nur $HOME/.icons /usr/share/icons
mkdir -p $HOME/.fonts
cp -nur /usr/share/fonts $HOME/.fonts
echo 'flatpak --user override --filesystem=$HOME/.icons/:ro'
flatpak --user override --filesystem=$HOME/.icons/:ro
echo 'flatpak --user override --filesystem=/usr/share/icons/:ro'
flatpak --user override --filesystem=/usr/share/icons/:ro
echo 'flatpak --user override --filesystem=/usr/share/fonts/:ro'
flatpak --user override --filesystem=/usr/share/fonts/:ro
echo 'flatpak --user override --filesystem=$HOME/.fonts/:ro'
flatpak --user override --filesystem=$HOME/.fonts/:ro
echo 'flatpak --user override --env=XCURSOR_PATH=~/.icons'
flatpak --user override --env=XCURSOR_PATH=~/.icons
echo 'flatpak --user override --filesystem=xdg-config/gtk-3.0:ro'
flatpak --user override --filesystem=xdg-config/gtk-3.0:ro
sleep 1s

echo
echo " Done!"
echo

sleep 1s

echo
echo "press Y to reboot now or N if you plan to manually reboot later."
echo

read REBOOT
if [ ${REBOOT,,} = y ]; then
    sudo reboot now
fi
exit 0
