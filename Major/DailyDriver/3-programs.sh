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
    'docker'                                        #
    'docker-buildx'                                 #
    'filelight'                                     # Show disk usage analyzer
    'gparted'                                       # Partitions Manager
    'neofetch'                                      # System Information tool
    'print-manager'
    'hplip'                                         # Driver for HP Deskjet (All-in-One) printers
    'skanlite'                                      # Image Scanning App (If you have a scanner or aio printer/scanner)
    'wine-staging'                                  # Compatibility Layer for running Windows programs (Staging Branch)
    'winetricks'                                    # Work around problems and install apps under Wine
    'wine-mono'                                     # Wine's built-in replacement for Microsoft's .NET Framework
    'wine-gecko'                                    # Wine's built-in replacement for Microsoft's Internet Explorer
    'dos2unix'                                      # Converting DOS stuff to unix
    'npm'                                           # Package manager for Javascript
    'lutris'                                        # Lutris
    'steam'                                         # Steam
    'distrobox'                                     #
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

# AUR
PKGY=(
    'ttf-ms-fonts'
    'qt5-tools'
    'vscodium-bin'                                  # VS Code without Microsoft's branding/telemetry/licensing
    'vscodium-bin-marketplace'                      # VS Codium market place
    'vscodium-bin-features'                         # Unblock some features blocked for non-MS's VSCode
    'deckboard-appimage'                            # Streamdeck alternative
    'hplip-plugin'                                  # Plugin for HP Deskjet (All-in-One) printers
    'protonup-qt'                                   # ProtonUp-Qt
    'eam-git'                                       # Epic Games' Marketplace for Linux
    'heroic-games-launcher-bin'                     # Epic Games and GOG launcher
    'bottles'                                       # Bottles
    'protontricks'                                  # Wrapper to make winetricks work with Proton enabled games
    'dxvk-bin'                                      # Vulkan-based compatibility layer for Direct3D 9/10/11
    'vkd3d-proton-mingw'                            # Vulkan-based compatibility layer for Direct3D 12
    'ventoy-bin'                                    # Multiboot USB Solution
    'jetbrains-toolbox'                             #
    'tdrop-git'                                     # Hide/Show terminal emulators
    'mullvad-vpn'                                   # VPN
    'davinci-resolve'                               # Video editing software
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

if lspci | grep -iq renesas; then
    echo
    echo "Found hardware that requires \"Renesas' USB 3.0 chipset firmware\""
    echo
    echo "Installing \"upd72020x-fw\""
    echo
    paru -S upd72020x-fw --noconfirm --needed --sudoloop
    sleep 1s
fi

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    echo
    echo "NVidia GPU found, downloading packages for it"
    echo
    PKGG=(
        'gwe'                                           # System Util for controlling NVidia GPUs
#        ''                                              #
    )

    for PKG in "${PKGG[@]}"; do
        echo
        echo "INSTALLING: ${PKG}"
        echo
        paru -S "$PKG" --noconfirm --needed --sudoloop
        echo
        sleep 1s
    done
fi

# FLATPAK
PKGZ=(
    'com.github.tchx84.Flatseal'                    # Flatpak permission manager
    'org.mozilla.firefox'                           # Firefox Browser
    'net.mullvad.MullvadBrowser'                    # Mullvad Browser
    'com.github.micahflee.torbrowser-launcher'      # Tor Browser
    'com.discordapp.Discord'                        # Discord
    'io.github.mimbrero.WhatsAppDesktop'            # Whatsapp
    'org.signal.Signal'                             # Signal
    'network.loki.Session'                          # Session
    'net.agalwood.Motrix'                           # Download Manager
    'org.libreoffice.LibreOffice'                   # FLOSS office suite ("replaces" MS Word, PowerPoint and Excel)
    'md.obsidian.Obsidian'                          # A knowledge base that works on local Markdown files
    'org.kde.okteta'                                # Hex Editor
    'org.kde.kleopatra'                             # Certificate Manager and Unified Crypto GUI
    'org.qbittorrent.qBittorrent'                   # Torrent app
    'io.mpv.Mpv'                                    # Media player
    'info.smplayer.SMPlayer'                        # SMPlayer
    'org.gimp.GIMP'                                 # GNU Image Manipulator
    'org.kde.krita'                                 # Digital Painting Software
    'org.inkscape.Inkscape'                         # Vector Graphics Editor
    'org.blender.Blender'                           # 3D Modelling Software
    'fr.handbrake.ghb'                              # Transcoder
    'io.github.Qalculate.qalculate-qt'              # Calculator
    'com.spotify.Client'                            # Spotify
    'com.obsproject.Studio'                         # Streaming software
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
echo "Running GIMP"
echo
org.gimp.GIMP &
sleep 5s
killall gimp-2.10

echo
echo "Installing PhotoGIMP"
echo
cd $HOME/Downloads
wget https://github.com/Diolinux/PhotoGIMP/releases/download/1.1/PhotoGIMP.zip
cp -rf PhotGIMP-master/.var $HOME
cp -rf PhotGIMP-master/.local $HOME

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
