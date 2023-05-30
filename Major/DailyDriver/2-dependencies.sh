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

sleep 1s

echo
echo "INSTALLING DEPENDENCIES/LIBRARIES STUFF"
echo

sleep 1s

echo
echo "This will take a while, take a break, grab a coffee, come back later"
echo

sleep 1s

echo
echo "Updating/Upgrading repos and apps"
paru
echo

sleep 1s

# PACMAN
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
    'vulkan-headers'                            # Vulkan Header Files
    'vulkan-validation-layers'                  # Vulkan Validation Layers
    'vulkan-tools'                              # Vulkan Utilities and Tools
    'unrar'                                     # Requires to install some games in Lutris
    'opencl-headers'                            # Requires to enable OpenCL in Photoshop
    'opencl-clhpp'                              # Requires to enable OpenCL in Photoshop
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo pacman -S "$PKG" --noconfirm --needed
    sleep 1s
done

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    echo
    echo "NVidia GPU found"
    echo
    sleep 1s
    echo
    echo "Installing NVidia's Proprietary Vulkan Drivers"
    echo
    sleep 1s
    sudo pacman -S nvidia-utils lib32-nvidia-utils opencl-nvidia --noconfirm --needed
fi
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq amd; then
    echo
    echo "AMD GPU found"
    echo
    sleep 1s
    echo
    echo "Installing AMD's Open-Source Vulkan Drivers"
    echo
    sleep 1s
    sudo pacman -S vulkan-radeon lib32-vulkan-radeon amdvlk lib32-amdvlk opencl-mesa --noconfirm --needed
    echo
    echo "Installing AMD's Proprietary Vulkan Drivers"
    echo
    sleep 1s
    paru -S amdgpu-pro-installer amd-vulkan-prefixes --noconfirm --needed --sudoloop
fi
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq intel; then
    echo
    echo "Intel GPU found"
    echo
    sleep 1s
    echo
    echo "Installing Intel's Proprietary Vulkan Drivers"
    echo
    sudo pacman -S vulkan-intel lib32-vulkan-intel opencl-mesa --noconfirm --needed
fi
# Not needed for us, will leave them here for testing purposes in the future
#if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq virtio; then
#    echo
#    echo "VirtIO vGPU found"
#    echo
#    sleep 1s
#    sudo pacman -S vulkan-virtio lib32-vulkan-virtio --noconfirm --needed
#fi
#if
#    echo
#    echo "No GPU found"
#    echo
#    sleep 1s
#    sudo pacman -S vulkan-swrast lib32-vulkan-swrast --noconfirm --needed
#fi

sleep 1s

# AUR
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

echo
echo "Done!"
echo "Don't forget to check https://github.com/StefanoND/ArchS/blob/main/Misc/vulkandrivers.sh for dealing with loading Vulkan Drivers"
echo
echo "Press Y to reboot now or N if you plan to manually reboot later."
echo

read REBOOT
if [ ${REBOOT,,} = y ]; then
    reboot
fi
exit 0
