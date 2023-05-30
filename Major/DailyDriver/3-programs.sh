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

# PACMAN
PKGX=(
    'filelight'                                     # Show disk usage and delete unused files
    'gparted'                                       # Create, reorganize and delete partitions
    'ventoy'                                        # Multiboot USB Solution
    ''                                              # Description
    ''                                              # Description
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
    'vscodium-bin'                                  # VS Code without Microsoft's branding/telemetry/licensing
    'vscodium-bin-marketplace'                      # VS Codium market place
    'vscodium-bin-features'                         # Unblock some features blocked for non-MS's VSCode
    'davinci-resolve'                               # Video editing software
    'deckboard-appimage'                            # Streamdeck alternative
    'hplip'                                         # Driver for HP Deskjet (All-in-One) printers
    'hplip-plugin'                                  # Plugin for HP Deskjet (All-in-One) printers
    'mullvad-vpn'                                   # VPN
    ''                                              # Description
)

for PKG in "${PKGY[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    paru -S "$PKG" --noconfirm --needed
    echo
    sleep 1s
done

# FLATPAK
PKGZ=(
    'org.mozilla.firefox'                           # Firefox Browser
    'net.mullvad.MullvadBrowser'                    # Mullvad Browser
    'com.github.micahflee.torbrowser-launcher'      # Tor Browser
    'org.onlyoffice.desktopeditors'                 # Open-source office suite ("replaces" MS Word, PowerPoint and Excel)
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
    'com.valvesoftware.Steam'                       # Steam
    'net.lutris.Lutris'                             # Lutris
    'com.usebottles.bottles'                        # Bottles
    'org.phoenicis.playonlinux'                     # "PlayOnLinux's Designated Successor"
    'nl.hjdskes.gcolor3'                            # Color Picker
    ''         # 
    ''         # 
    ''         # 
    ''         # 
    ''         # 
    ''         # 
    ''         # 
    ''         # 
    ''         # 
    ''         # 
    ''         # 
    ''         # 
    ''         # 
    ''         # 
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
