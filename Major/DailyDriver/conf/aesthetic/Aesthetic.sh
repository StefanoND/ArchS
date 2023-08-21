#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
    exit 1
fi

echo
echo "You can change KDE Rounded Corner's settings in \"System Settings->Workspace Behavior->Desktop Effects->ShapeCorners\""
echo
echo "My recommended settings are:"
echo "ACTIVE"
echo "    Roundness: 9.00"
echo "    Outline thickness; 3,0"
echo "    Active Window Outline Color: #745bae"
echo "    Active Window Shadow Color: #745bae"
echo "    Active Window Shadow Size: 15.00"
echo
echo "INACTIVE"
echo "    Roundness: 9.00"
echo "    Outline thickness; 3,0"
echo "    Inactive Window Outline Color: #3b3155"
echo "    Inactive Window Shadow Color: #3b3155"
echo "    Inctive Window Shadow Size: 15.00"
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
echo "        All Outer Gaps: 8 px"
echo "        Inner Gaps: 4 px"
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
echo "Icons: Tela Circle Purple dark (https://store.kde.org/p/1359276)"
echo
echo "Cursors: Sweet-cursors (https://store.kde.org/p/1393084)"
echo
echo "Splash Screen: Arch Linux Splash Screen (https://store.kde.org/p/1711647)"
echo
echo "Boot Splash Screen: Default: Breeze (Text Mode)"
echo
echo "Login Screen (SDDM): Sugar Candy (https://store.kde.org/p/1312658)"
echo
echo "Window Management->Task Switcher: Thumbnail Grid (default)"
echo
sleep 1s

echo
echo "Top dock:"
echo "    Application Dashboard"
echo "    Separator"
echo "    Pager"
echo "    Spacer"
echo "    Digitcal Clock"
echo "    Spacer"
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
