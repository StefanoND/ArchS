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
    'filelight'                                     # Show disk usage analyzer
    'gparted'                                       # Partitions Manager
    'hplip'                                         # Driver for HP Deskjet (All-in-One) printers
    'skanlite'                                      # Image Scanning App (If you have a scanner or aio printer/scanner)
    'wine-staging'                                  # Compatibility Layer for running Windows programs (Staging Branch)
    'winetricks'                                    # Work around problems and install apps under Wine
    'wine-mono'                                     # Wine's built-in replacement for Microsoft's .NET Framework
    'wine-gecko'                                    # Wine's built-in replacement for Microsoft's Internet Explorer
    'dos2unix'                                      # Converting DOS stuff to unix
    'npm'                                           # Package manager for Javascript
#    ''                                              # 
)

for PKG in "${PKGX[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo pacman -S "$PKG" --noconfirm --needed
    echo
    sleep 1s
done

sleep 1s

echo
echo "Enabling npm's tab completion"
echo
sudo npm install --global all-the-package-names

sleep 1s

echo
echo "Updating npm to latest version"
echo
sudo npm install -g npm@latest

sleep 1s

echo
echo "Auditting and fixing npm's issues/vulnerabilities (if there's any)"
echo
npm i --package-lock-only
sleep 1s
npm audit fix

sleep 1s

# AUR
PKGY=(
    'vscodium-bin'                                  # VS Code without Microsoft's branding/telemetry/licensing
    'vscodium-bin-marketplace'                      # VS Codium market place
    'vscodium-bin-features'                         # Unblock some features blocked for non-MS's VSCode
    'davinci-resolve'                               # Video editing software
    'deckboard-appimage'                            # Streamdeck alternative
    'hplip-plugin'                                  # Plugin for HP Deskjet (All-in-One) printers
    'mullvad-vpn'                                   # VPN
    'dxvk-bin'                                      # Vulkan-based compatibility layer for Direct3D 9/10/11
    'vkd3d-proton-bin'                              # Vulkan-based compatibility layer for Direct3D 12
    'ventoy-bin'                                    # Multiboot USB Solution
#    ''                                              # 
)

for PKG in "${PKGY[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    paru -S "$PKG" --noconfirm --needed --sudoloop
    echo
    sleep 1s
done

# FLATPAK
PKGZ=(
    'com.github.tchx84.Flatseal'                    # Flatpak permission manager
    'org.mozilla.firefox'                           # Firefox Browser
    'net.mullvad.MullvadBrowser'                    # Mullvad Browser
    'com.github.micahflee.torbrowser-launcher'      # Tor Browser
    'net.agalwood.Motrix'                           # Download Manager
    'org.onlyoffice.desktopeditors'                 # Open-source office suite ("replaces" MS Word, PowerPoint and Excel)
    'md.obsidian.Obsidian'                          # A knowledge base that works on local Markdown files
    'org.kde.okteta'                                # Hex Editor
    'org.kde.kleopatra'                             # Certificate Manager and Unified Crypto GUI
    'org.qbittorrent.qBittorrent'                   # Torrent app
    'io.mpv.Mpv'                                    # Media player
    'org.gimp.GIMP'                                 # GNU Image Manipulator
    'org.kde.krita'                                 # Digital Painting Software
    'org.inkscape.Inkscape'                         # Vector Graphics Editor
    'org.blender.Blender'                           # 3D Modelling Software
    'fr.handbrake.ghb'                              # Transcoder
    'io.github.Qalculate.qalculate-qt'              # Calculator
    'com.spotify.Client'                            # Spotify
    'com.obsproject.Studio'                         # Streaming software
    'io.github.achetagames.epic_asset_manager'      # Epic Games' Marketplace for Linux
    'com.heroicgameslauncher.hgl'                   # Epic Games and GOG launcher
    'com.valvesoftware.Steam'                       # Steam
    'net.lutris.Lutris'                             # Lutris
    'com.usebottles.bottles'                        # Bottles
    'org.phoenicis.playonlinux'                     # "PlayOnLinux's Designated Successor"
    'net.davidotek.pupgui2'                         # ProtonUp-Qt
    'com.github.Matoking.protontricks'              # Wrapper to make winetricks work with Proton
    'io.github.antimicrox.antimicrox'               # Graphical program used to map gamepad keys to keyboard, mouse, scripts and macros
    'nl.hjdskes.gcolor3'                            # Color Picker
#    ''         # 
)

for PKG in "${PKGZ[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    flatpak install flathub "$PKG" -y --or-update
    echo
    sleep 1s
done

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
