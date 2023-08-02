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
PKGZ=(
#    ''                                         #
)

for PKG in "${PKGZ[@]}"; do
        echo
        echo "INSTALLING: ${PKG}"
        echo
        sudo pacman -Rsn "$PKG" --noconfirm --needed
        echo
        sleep 1s
done

# PACMAN
PKGS=(
    'base-devel'
    'cmake'
    'extra-cmake-modules'
    'git'                                       # Git
    'kvantum'
    'npm'
    'zip'
#    ''                                         #
)

for PKG in "${PKGS[@]}"; do
        echo
        echo "INSTALLING: ${PKG}"
        echo
        sudo pacman -S "$PKG" --noconfirm --needed
        echo
        sleep 1s
done

# PARU
PKGS=(
    'qt5-tools'
    #'kwin-bismuth' # Using a up-to-date fork
#    ''                                          #
)

for PKG in "${PKGS[@]}"; do
        echo
        echo "INSTALLING: ${PKG}"
        echo
        paru -S "$PKG" --noconfirm --needed --sudoloop
        echo
        sleep 1s
done

echo
echo "Downloading Bismuth (Tiling Manager)"
echo
cd /opt
sudo git clone https://github.com/Elfahor/bismuth.git && cd bismuth
sudo mkdir build && cd build
sudo npm install typescript
sudo npm audit fix --force
sudo cmake ..
sudo make
sudo make install

# echo
# echo "Downloading Polonium (Tiling Manager)"
# echo
# cd /opt
# sudo git clone https://github.com/zeroxoneafour/polonium.git && cd polonium
# sudo make build
# sudo make install

echo
echo "Downloading KDE Rounded Corners"
echo
cd /opt
sudo git clone https://github.com/matinlotfali/KDE-Rounded-Corners.git && cd KDE-Rounded-Corners
sleep 1s
echo
printf "mkdir build && cd build"
echo
sudo mkdir build && cd build
sleep 1s
echo
echo "Installing KDE Rounded Corners"
echo
sudo make build
sudo make
sudo make install
sleep 1s
echo
echo "You can change KDE Rounded Corner's settings in \"System Settings->Workspace Behavior->Desktop Effects->ShapeCorners\""
echo
echo "My recommended settings are:"
echo "Roundness: 10 from left"
echo "Active Window Outline Color: #9dd9d6"
echo "Inactive Window Outline Color: #782323"
echo "Outline thickness; 3,0"
echo
echo "Active Window Shadow Color: #9dd9d6"
echo "Active Window Shadow Size: 14 from left"
echo "Inactive Window Shadow Color: #782323"
echo "Active Window Shadow Size: 14 from left"
echo
echo "Note: \"X from left\" means, drag the slider all the way to the left then press the right key X times"
echo
sleep 1s


echo
echo "You may need to change windows decorations and back to change take effects"
echo

echo
echo "You can enable Bismuth at \"System Settings->Workspace->Window Management->Window Tiling\""
echo
echo "System Settings->Window Management->Window Tiling"
echo "    Appearance Tab:"
echo "        All Outer Gaps: 11 px (So you have access to desktop on screen edges)"
echo "        Inner Gaps: 2x"
echo "        UNCHECK \"No broders around tiled windows\""
echo
echo "Checkout Bismuth-Forge's site for tweaking the Tile Manager"
echo "https://github.com/Bismuth-Forge/bismuth/blob/master/docs/TWEAKS.md"
echo

sleep 1s

echo
echo "Global Theme: Orchis-dark (https://store.kde.org/p/1458927)"
echo
echo "Application Style: kvantum-dark"
echo "    GNOME/GTK Application Style: Orchis-Purple-Dark (https://store.kde.org/p/1357889)"
echo
echo "Plasma Style: Orchis-dark"
echo
echo "Colors: OrchisDark"
echo
echo "Window Decorations: Orchis-dark"
echo "    Window border size: No Borders"
echo "    Titlebar Buttons: Remove All, untick both \"Close windows by double click\" and \"Show titlebar tooltips\""
echo "Note: Rounded Corners works best with Breeze. Other Window Decorations might give you either transparent triangles or black lines on the corners"
echo "It depends how rounded/squared the Window Decoration is"
echo
echo "All Fira Code"
echo "    Anti-Aliasing: Enable"
echo "    Sub-pixel rendering: RGB"
echo "    Hinting: Slight"
echo "    Force font DPI: Disabled"
echo
echo "Icons: Tela Circle (Purple) (https://store.kde.org/p/1359276)"
echo
echo "Cursors: Sweet-cursors (https://store.kde.org/p/1393084)"
echo
echo "Splash Screen: Simple Tux Splash (https://store.kde.org/p/1258784)"
echo
echo "Boot Splash Screen: nibar-plymouth-theme (https://store.kde.org/p/1784844)"
echo
echo "Login Screen (SDDM): Chili for Plasma (https://store.kde.org/p/1214121)"
echo
echo "Window Management->Task Switcher: Thumbnail Switcher (https://store.kde.org/p/2010367)"
echo

sleep 1s

echo
echo "Top dock:"
echo "    Better Application Dashboard: https://store.kde.org/p/1897990"
echo "    Margins Separator"
echo "    Digital Clock"
echo "    Spacer"
echo "    Minimal Desktop Indicator: https://store.kde.org/p/1878511"
echo "    Spacer"
echo "    Plasma Active Application: https://store.kde.org/p/1269296"
echo "    Margins Separator"
echo "    System-Tray"
echo

sleep 1s

echo
echo "Bottom dock:"
echo "    Popup Launchers: https://store.kde.org/p/1084934"
echo "        System: System Settings, Add/Remove Software, Timeshift, Filelight, GParted"
echo "        Office: Only Office, Obsidian, "
echo "        Development: VSCodium, Unreal Engine, Unity Hub, Rider, Jetbrains Toolbox"
echo "        Graphics: Blender, DaVinci Resolve, Kirta, GIMP, Inkscape"
echo "        Social: Discord, Whatsapp, Signal, Session"
echo "        Multimedia: OBS Studio, Spotify, MPV, Handbrake"
echo "        \"Game\" Launchers: Steam, Lutris, Heroic Games Launcher, Bottles, Phoenicis PlayOnLinux, Epic Asset Manager, DosBox, ProtonUp-QT"
echo "        Games: Neverwinter Nights: Enhanced Edition"
echo "        Utilities: qBitTorrent, OpenTabletDriver, AntiMicroX, HP Device Manager"
echo "    Latte Separator: https://store.kde.org/p/1295376"
echo "    Icons-Only Task Manager"
echo "        Pinned:"
echo "            Dolphin, Firefox, VirtualBox, Kate, Deckeboard"
echo

sleep 1s

echo
echo "Workspace Behavior:"
echo "    Desktop Effects:"
echo "        Kinetic Animations - Popup Menu Fade (https://store.kde.org/p/1915783)"
echo "        Kinetic Animations - Open/Close (https://store.kde.org/p/1915781)"
echo "        Kinetic Animations - Minimize (https://store.kde.org/p/1915780)"
echo "        Kinetic Animations - Maximize (https://store.kde.org/p/1915750)"
echo "        Snap Helper"
echo "        Background Contrast"
echo "        Blur (Both sliders in the middle)"
echo "        Mouse Mark"
echo "        Screen Edge (Disabled)"
echo "        Translucency (Default)"
echo "        Dim Inactive (Strength: 5)"
echo "        Dim Screen for Administrator Mode"
#echo "        "
echo

sleep 1s

echo
echo "KRunner:"
echo "    Plugins:"
echo "        VBox Runner (https://store.kde.org/p/1080708)"
echo "        Symbols (https://store.kde.org/p/1419376)"
echo

echo
echo "KVantum"
echo "    Orchis (https://www.pling.com/p/1458909/)"
echo "        Find this section and lines and replace with the ones below"
echo "        [GeneralColors]"
echo "            highlight.color=#926ee4"
echo "            inactive.highlight.color=#604c8e"
echo "            link.color=#e040fb"
echo "            link.visited.color=#3700ae"
echo

echo
echo "Done!"
echo
echo
echo "Some changes will be applied after reboot, do you want to reboot now?"
echo "Y - yes | N - No"
echo

read REBOOT
if [ ${REBOOT,,} = y ]; then
    sudo reboot now
fi
exit 0
