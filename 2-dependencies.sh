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
    echo "Don't run this program as root."
    exit 1
fi

sleep 1s

echo
echo "These processes will take a long time to finish, make sudo loop."
echo "use 'paru --sudoloop --save' or 'sudo nano ~/.config/yay/config.json' and make sure that sudoloop is set to true 'sudoloop: true'"
echo "WARNING: THE ABOVE IS EXTREMELY DANGEROUS, SET TO FALSE AFTER EVERYTHING IS DONE"
echo "WARNING: DON'T LEAVE YOUR PC/LAPTOP UNATENDED"
echo "Type Y when you're ready"

read READY
if [ ${READY,,} = y ]; then
    echo
    echo "Post-install will start"
    echo "This will take a while, take a break, grab a coffee, come back later"
    echo
    sleep 1s
fi

if pacman -Q | grep 'yakuake'; then
    echo
    echo "Configuring Yakuake"
    echo

    sleep 1s

    if ! test -e /home/$(logname)/.config/yakuakerc; then
        touch /home/$(logname)/.config/yakuakerc;
    fi

    sleep 1s

    if grep -q -F "DefaultProfile=" /home/$(logname)/.config/yakuakerc; then
        sed -i -e "s|[#]*DefaultProfile=.*|DefaultProfile=$(logname).profile|g" /home/$(logname)/.config/yakuakerc
    elif ! grep -q -F "DefaultProfile=" /home/$(logname)/.config/yakuakerc && ! grep -q -F "[Desktop Entry]" /home/$(logname)/.config/yakuakerc; then
        sed -i "1 i\[Desktop Entry]\nDefaultProfile=$(logname).profile\n" /home/$(logname)/.config/yakuakerc
    fi

    sleep 1s

    echo
    echo "Add Yakuake to autostart"
    echo "Go to \"System Settings\" click on \"Startup and Shutdown\" then click on \"Autostart\""
    echo "Click the \"+ Add...\" button and search for \"Yakuake\""
    echo "Press any button when you're done"
    echo

    sleep 1s

    read ANYTTHINGG

    sleep 1s
fi

echo
echo "INSTALLING DEPENDENCIES/LIBRARIES STUFF"
echo

sleep 1s

echo
echo "Updating/Upgrading repos and apps"
sudo pacman -Syu --noconfirm --needed && paru -Syu --noconfirm --needed
echo

sleep 1s

PKGS=(
    'giflib'                                    # Wine Dependency Hell
    'lib32-giflib'                              # Wine Dependency Hell
    'libpng'                                    # Wine Dependency Hell
    'lib32-libpng'                              # Wine Dependency Hell
    'libldap'                                   # Wine Dependency Hell
    'lib32-libldap'                             # Wine Dependency Hell
    'gnutls'                                    # Wine Dependency Hell
    'lib32-gnutls'                              # Wine Dependency Hell
    'mpg123'                                    # Wine Dependency Hell
    'lib32-mpg123'                              # Wine Dependency Hell
    'openal'                                    # Wine Dependency Hell
    'lib32-openal'                              # Wine Dependency Hell
    'v4l-utils'                                 # Wine Dependency Hell
    'lib32-v4l-utils'                           # Wine Dependency Hell
    'libpulse'                                  # Wine Dependency Hell
    'lib32-libpulse'                            # Wine Dependency Hell
    'alsa-plugins'                              # Wine Dependency Hell
    'lib32-alsa-plugins'                        # Wine Dependency Hell
    'alsa-lib'                                  # Wine Dependency Hell
    'lib32-alsa-lib'                            # Wine Dependency Hell
    'libjpeg-turbo'                             # Wine Dependency Hell
    'lib32-libjpeg-turbo'                       # Wine Dependency Hell
    'libxcomposite'                             # Wine Dependency Hell
    'lib32-libxcomposite'                       # Wine Dependency Hell
    'libxinerama'                               # Wine Dependency Hell
    'lib32-libxinerama'                         # Wine Dependency Hell
    'ncurses'                                   # Wine Dependency Hell
    'lib32-ncurses'                             # Wine Dependency Hell
    'opencl-icd-loader'                         # Wine Dependency Hell
    'lib32-opencl-icd-loader'                   # Wine Dependency Hell
    'libxslt'                                   # Wine Dependency Hell
    'lib32-libxslt'                             # Wine Dependency Hell
    'libva'                                     # Wine Dependency Hell
    'lib32-libva'                               # Wine Dependency Hell
    'gtk3'                                      # Wine Dependency Hell
    'lib32-gtk3'                                # Wine Dependency Hell
    'gst-plugins-base-libs'                     # Wine Dependency Hell
    'lib32-gst-plugins-base-libs'               # Wine Dependency Hell
    'vulkan-icd-loader'                         # Wine Dependency Hell
    'lib32-vulkan-icd-loader'                   # Wine Dependency Hell
    'cups'                                      # Wine Dependency Hell
    'samba'                                     # Wine Dependency Hell
    'dosbox'                                    # Wine Dependency Hell
    'unrar'                                     # Requires to install some games in Lutris
    'opencl-headers'                            # Requires to enable OpenCL in Photoshop
    'opencl-nvidia'                             # Requires to enable OpenCL in Photoshop
    'opencl-clhpp'                              # Requires to enable OpenCL in Photoshop
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo pacman -S "$PKG" --noconfirm --needed
    sleep 1s
done

sleep 1s

PKGZ=(
    'opentabletdriver'                          # Tablet Driver ("-git" version not working)
    'gamemode-git'                              # Optimizations for games
    'lib32-gamemode-git'                        # 32-bit library for gamemode
    'lib32-glslang'                             # OpenGL and OGL ES front end and validator
    'mingw-w64-glslang'                         # OpenGL and OGL ES front end and validator
    'ttf-ms-fonts'                              # Core TTF fonts from Microsoft
    'ttf-vista-fonts'                           # TTF fonts from vista and office
    'adobe-base-14-fonts'                       # Adobe base 14 fonts (Courier, Helvetica, Times, Symbol, etc)
    'xboxdrv'                                   # Gamepad driver for Linux (Controller Support)
)

for PKG in "${PKGZ[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    paru -S "$PKG" --noconfirm --needed --sudoloop
    sleep 1s
done

#echo
#echo "Setting SDDM as owner of /var/lib/sddm/.config"
#echo
#sudo chown sddm:sddm /var/lib/sddm/.config

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
