#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
    exit 1
fi

if ! groups|grep wheel>/dev/null;then
    echo
    echo "You need to be a member of the wheel to run me!"
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

# Pacman
PKGS=(
    # Fonts
    'ttf-fira-code'                             # My personal favorite font for programming
    'noto-fonts-extra'                          # Additional variants of noto fonts
    'noto-fonts-cjk'                            # Chinese Japanese Korean (CJK) characters support
    'noto-fonts-emoji'                          # Support for emojis
    'gnu-free-fonts'                            # Free family of scalable outline fonts
    'powerline-fonts'                           # Patched fonts for powerline Powerlevel10k
    'ttf-nerd-fonts-symbols'                    #
    'ttf-nerd-fonts-symbols-common'             #
    'ttf-nerd-fonts-symbols-mono'               #
    'ttf-ubuntu-font-family'                    # Ubuntu font
    'ttf-jetbrains-mono'                        # Jetbrains' monospace

    # Compression utilities
    'tar'
    'gzip'
    'bzip3'
    'unzip'
    'p7zip'
    'unrar'
    'zip'

    # Misc
    'cpupower'                                  # CPU tuning utility
    'python-pyqt5'                              #
    'ntfs-3g'                                   # NTFS support
    'starship'
    'htop'
    'npm'                                       # Package manager for Javascript

    # QEMU
    'qemu-desktop'
    'libvirt'
    'virt-manager'
    'virt-viewer'
    'edk2-ovmf'
    'bridge-utils'
    'netctl'
    'dnsmasq'
    'vde2'
    'openbsd-netcat'
    'ebtables'
    'nftables'
    'swtpm'

    # Extras
    'dolphin'
    'dolphin-plugins'
    'baloo-widgets'
    'ffmpegthumbs'
    'kde-inotify-survey'
    'kdegraphics-thumbnailers'
    'kdenetwork-filesharing'
    'print-manager'
    'power-profiles-daemon'
    'xdg-desktop-portal-gtk'
    'xsettingsd'
    'kwalletmanager'
    'sxhkd'

    # i3
    #'i3blocks'
    'rofi'
    #'nitrogen'
    #'wmctrl'
    #'picom'

    # 3D/Hardware Acceleration/Gaming related/dependencies
    'vkd3d'                                     #
    'lib32-vkd3d'                               #
    'lib32-sqlite'                              # Lutris Dependency
    'vulkan-headers'                            # Vulkan Header Files
    'vulkan-validation-layers'                  # Vulkan Validation Layers
    'vulkan-tools'                              # Vulkan Utilities and Tools
    'opencl-headers'                            #
    'opencl-clhpp'                              #
    'libvdpau-va-gl'                            # Hardware Acceleration
    'gstreamer'                                 # Hardware Acceleration
    'gstreamer-vaapi'                           # Hardware Acceleration
    'lib32-libappindicator-gtk2'                # Tray Icon Support for Steam

    # i3 Depdendencies
    #'sysstat'
    #'acpi'
    #'alsa-utils'
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
)

# Paru
PKGA=(
    'hplip-plugin'                                  # Plugin for HP Deskjet (All-in-One) printers
    'ibus-autostart-kimpanel'
    'zram-generator'
    'timeshift-bin'
    'preload'
    'systemd-kcm'
    'kcm-polkit-kde-git'
    'kcm-uefi'
    'garuda-settings-manager-kcm-git'
    'autojump'
    'kwin-polonium'
    'kwin-effect-rounded-corners-git'
    'swhkd-git'
    'powerpill'
#    'i3-gaps-rounded-git'
    'spicetify-cli'
    'pamac-aur'
    'libpamac-aur'
    'pamac-tray-icon-plasma'
    'ttf-meslo-nerd-font-powerlevel10k'         # Meslo Nerd font patched for
    'opentabletdriver'                          # Tablet Driver ("-git" version not working)
    'gamemode-git'                              # Optimizations for games
    'lib32-gamemode-git'                        # 32-bit library for gamemode
    'lib32-glslang'                             # OpenGL and OGL ES front end and validator
    'mingw-w64-glslang'                         # OpenGL and OGL ES front end and validator
    'ttf-ms-fonts'                              # Core TTF fonts from Microsoft
    'ttf-vista-fonts'                           # TTF fonts from vista and office
    'adobe-base-14-fonts'                       # Adobe base 14 fonts (Courier, Helvetica, Times, Symbol, etc)
    'xboxdrv'                                   # Gamepad driver for Linux (Controller Support)
    'tdrop'
)

# Pacman
PKGFP=(
    'com.github.tchx84.Flatseal'                    # Flatpak permission manager
    'org.gnu.emacs'                                 # "Family of text editors"
    'org.mozilla.firefox'                           # Firefox Browser
    'net.mullvad.MullvadBrowser'                    # Mullvad Browser
    'com.github.micahflee.torbrowser-launcher'      # Tor Browser
    'com.discordapp.Discord'                        # Discord
    'io.github.mimbrero.WhatsAppDesktop'            # Whatsapp
    'org.signal.Signal'                             # Signal
    'network.loki.Session'                          # Session
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

# Still not ready for daily-use
# # Nix home-manager
# PKGHM=(
#     'kate'
#     'qemu_full'
#     'qemu-utils'
#     'libvirt'
#     'virt-manager'
#     'virt-viewer'
#     'bridge-utils'
#     'OVMFFull'
#     'vde2'
# #    'ebtables' # Not needed. iptables have it
#     'iptables'
#     'nftables'
#     'swtpm'
#     'firefox-esr'
#     ''
#     ''
#     ''
#     ''
# #    ''
# )

APPSPATH="${HOME}/.apps"
SRCPATH="$(cd $(dirname $0) && pwd)"
sourcen=0
linkn=0
enablevb=n

echo
printf "If you haven't run 1-prep.sh yet, stop this script (CTRL + C) and run it first"
echo
printf "When you're done come back here. And press anykey"
echo
read ANYTING
clear
sleep 1s

echo
echo "These processes will take a long time to finish, increase sudo timeout."
echo "use 'sudo EDITOR=vim visudo' or 'sudo EDITOR=nano visudo' and add 'Defaults passwd_timeout=0'"
echo "WARNING: Even though \"The prompt timeout can [...] be disabled and [...] does not serve any reasonable security purpose [...]\""
echo "It's better to remove it when you're done"
echo
echo "WARNING: It's obvious but don't leave your pc/laptop unatended in a public place"
echo
echo "Press anything to continue"
echo
read READY
clear
sleep 1s

echo
echo "Do you want to install VirtualBox?"
echo "Y - Yes | Anything else - no"
echo
read VBENABLE
enablevb=$VBENABLE
sleep 1s

clear
sleep 1s

echo
echo "Removing install blocker"
echo
sudo rm -f /var/lib/pacman/db.lck
sleep 1s

clear

if ! [[ -d "${APPSPATH}" ]]; then
    echo
    printf "Creating ${APPSPATH} path"
    echo
    mkdir -p "${APPSPATH}"
    sleep 1s
fi

echo
echo "Updating system"
echo
sudo pacman -Syyu --noconfirm --needed
sleep 2s

echo
echo
echo
echo "Grab a coffee, it'll take some time"
echo
sleep 2s

# Pacman
for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo pacman -S "$PKG" --noconfirm --needed
    echo
    sleep 1s
done

# Flatpak
for PKG in "${PKGFP[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    flatpak install flathub "$PKG" -y
    echo
    sleep 1s
done

# Paru
for PKG in "${PKGA[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    paru -S "$PKG" --noconfirm --needed --sudoloop
    echo
    sleep 1s
done

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    echo
    echo "NVidia GPU found"
    echo
    sleep 1s

    if pacman -Q | grep -iq libva-vdpau-driver; then
        echo
        echo "Removing libva-vdpau-driver since it conflicts with nvidia's"
        echo
        sudo pacman -Rdd libva-vdpau-driver --noconfirm
        sleep 1s
    fi

    echo
    echo "Installing NVidia's Proprietary Vulkan Drivers"
    echo
    sudo pacman -S nvidia-utils lib32-nvidia-utils opencl-nvidia libva-nvidia-driver gwe --noconfirm --needed
    sleep 1s

    if ! [[ `pacman -Q | grep -i 'nvidia-dkms'` ]]; then
        echo
        echo "Installing NVidia dkms"
        echo
        sudo pacman -S nvidia-dkms --noconfirm --needed
        sleep 1s
    fi

    printf "LIBVA_DRIVER_NAME=nvidia\n" | sudo tee -a /etc/environment
    sleep 1s

    printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json\n" | sudo tee -a /etc/environment
    sleep 1s

    printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d\n" | sudo tee -a /etc/environment
    sleep 1s

    export LIBVA_DRIVER_NAME=nvidia
    sleep 1s

    export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d
    sleep 1s

    export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
    sleep 1s
fi
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq amd; then
    echo
    echo "AMD GPU found"
    echo
    sleep 1s
    echo
    echo "Installing AMD's Open-Source Vulkan Drivers"
    echo
    sudo pacman -S vulkan-radeon lib32-vulkan-radeon amdvlk lib32-amdvlk opencl-mesa --noconfirm --needed
    sleep 1s
    echo
    echo "Installing AMD's Proprietary Vulkan Drivers"
    echo
    paru -S amdgpu-pro-installer amd-vulkan-prefixes --noconfirm --needed --sudoloop
    sleep 1s
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
    sleep 1s

    printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json\n" | sudo tee -a /etc/environment
    sleep 1s

    printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nv_vulkan_wrapper.json\n" | sudo tee -a /etc/environment
    sleep 1s

    printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d\n" | sudo tee -a /etc/environment
    sleep 1s

    export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json
    sleep 1s

    export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nv_vulkan_wrapper.json
    sleep 1s

    export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d
    sleep 1s

fi

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq virtio; then
    echo
    echo "VirtIO vGPU found"
    echo
    sleep 1s
    sudo pacman -S vulkan-virtio lib32-vulkan-virtio --noconfirm --needed
    sleep 1s

    printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/virtio_icd.i686.json\n" | sudo tee -a /etc/environment
    sleep 1s

    printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/virtio_icd.x86_64.json\n" | sudo tee -a /etc/environment
    sleep 1s

    printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d\n" | sudo tee -a /etc/environment
    sleep 1s

    export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/virtio_icd.i686.json
    sleep 1s

    export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/virtio_icd.x86_64.json
    sleep 1s

    export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d
    sleep 1s
fi
if ! [[ `lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq virtio` ]] &&
   ! [[ `lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia` ]] &&
   ! [[ `lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq amd` ]] &&
   ! [[ `lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq intel` ]]; then
    echo
    echo "No GPU found"
    echo
    sudo pacman -S vulkan-swrast lib32-vulkan-swrast --noconfirm --needed
    sleep 1s

    printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.i686.json\n" | sudo tee -a /etc/environment
    sleep 1s

    printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json\n" | sudo tee -a /etc/environment
    sleep 1s

    printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d\n" | sudo tee -a /etc/environment
    sleep 1s

    export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.i686.json
    sleep 1s

    export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json
    sleep 1s

    export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d
    sleep 1s
fi

if lspci | grep -iq renesas; then
    echo
    echo "Found hardware that requires \"Renesas' USB 3.0 chipset firmware\""
    echo
    echo "Installing \"upd72020x-fw\""
    echo
    paru -S upd72020x-fw --noconfirm --needed --sudoloop
    sleep 1s
fi

# # Nix home-manager
# for PKG in "${PKGHM[@]}"; do
#     echo
#     echo "INSTALLING: ${PKG}"
#     echo
#     #sudo pacman -S "$PKG" --noconfirm --needed
#     sed -i "/^.*home.packages = with pkgs; \[.*/a \    $PKG" "${HOME}"/.config/home-manager/home.nix
#     echo
#     sleep 1s
# done
#
# echo
# echo 'Creating a new generation of home-manager with our config'
# echo
# home-manager switch
# sleep 1s

if [[ -f /etc/systemd/zram-generator.conf ]]; then
    sudo mv /etc/systemd/zram-generator.conf /etc/systemd/zram-generator.conf.old
    sleep 1s
fi

sudo touch /etc/systemd/zram-generator.conf
sleep 1s
sudo bash -c 'echo "[zram0]" >> /etc/systemd/zram-generator.conf'
sleep 1s
sudo bash -c 'echo "zram-size = ram / 2" >> /etc/systemd/zram-generator.conf'
sleep 1s

sudo mkdir -p /usr/local/bin/autojump
sleep 1s
sudo ln -s /etc/profile.d/autojump.sh /usr/share/autojump/autojump.sh
sleep 1s
sudo chmod +x /usr/share/autojump/autojump.sh
sleep 1s

if [[ -f "${HOME}"/.config/starship.toml ]]; then
    mv "${HOME}"/.config/starship.toml "${HOME}"/.config/starship.toml.old
    sleep 1s
fi
if ! [[ -d "${HOME}"/Pictures/Wallpapers ]]; then
    mkdir -p "${HOME}"/Pictures/Wallpapers
    sleep 1s
fi
if ! [[ -d "${HOME}"/.config/swhkd ]]; then
    mkdir -p "${HOME}"/.config/swhkd
fi
if ! [[ -d "${HOME}"/.config/sxhkd ]]; then
    mkdir -p "${HOME}"/.config/sxhkd
fi

sudo mv /etc/swhkd/swhkdrc /etc/swhkd/swhkdrc.old
sleep 1s

cp -f "${SRCPATH}"/conf/home/swhkdrc "${HOME}"/.config/swhkd
sleep 1s

cp -f "${SRCPATH}"/conf/home/sxhkdrc "${HOME}"/.config/sxhkd
sleep 1s

sudo ln -svf "${HOME}"/.config/swhkd/swhkdrc /etc/swhkd
sleep 1s
# if ! [[ -d "${HOME}"/.config/i3 ]]; then
#     mkdir -p "${HOME}"/.config/i3
#     sleep 1s
# fi
# if ! [[ -d "${HOME}"/.config/i3blocks ]]; then
#     mkdir -p "${HOME}"/.config/i3blocks
#     sleep 1s
# fi

cp -f "${SRCPATH}"/conf/home/starship.toml "${APPSPATH}"/archs
ln -svf "${APPSPATH}"/archs/starship.toml "${HOME}"/.config/starship.toml
sleep 1s

cp "${SRCPATH}"/wallpapers/* "${HOME}"/Pictures/Wallpapers
sleep 1s

# cd ${APPSPATH}
# echo
# echo "Downloading config files for i3, dunst, picom, ranger and rofi"
# echo
# git clone https://github.com/krstfz/i3wm.git && cd i3wm/i3wm/config
# sleep 1s
#
# sed -i 's/Papirus-Dark\/16x16/Tela-circle-dark\/16/g' dunst/dunstrc
# sleep 1s
# cp -r dunst "${HOME}"/.config/
#
# cp -r i3blocks "${HOME}"/.config/
#
# sed -i 's/fade-in-step = 0.045;/fade-in-step = 0.028;/g' picom/picom.conf
# sleep 1s
# sed -i 's/fade-out-step = 0.05;/fade-out-step = 0.03;/g' picom/picom.conf
# sleep 1s
# cp picom/picom.conf "${HOME}"/.config/
#
# sed -i 's/set preview_images false/set preview_images true/g' "${HOME}"/.config/ranger/rc.conf
# sleep 1s
# sed -i 's/set draw_borders none/set draw_borders true/g' "${HOME}"/.config/ranger/rc.conf
# sleep 1s
#
# sed -i 's/icon-theme: "Papirus";/icon-theme: "Tela-circle-dark";/g' rofi/config.rasi
# sleep 1s
# sed -i 's/terminal: "kitty";/terminal: "wezterm";/g' rofi/config.rasi
# sleep 1s
# sed -i 's/.*catppuccin-macchiato.rasi.*//g' rofi/config.rasi
# sleep 1s
# printf "@theme \"${HOME}/.config/rofi/themes/catppuccin-macchiato.rasi\"\n" >> rofi/config.rasi
# sleep 1s
#
# cp -r rofi "${HOME}"/.config/
# cp -r spicetify "${HOME}"/.config/


if ! [[ -d "${HOME}"/.config/rofi ]]; then
    mkdir -p "${HOME}"/.config/rofi
fi

if ! [[ -d "${HOME}"/.local/share/rofi/themes ]]; then
    mkdir -p "${HOME}"/.local/share/rofi/themes
fi

cp -r "${SRCPATH}"/conf/rofi "${APPSPATH}"
sleep 1s

ln -svf "${APPSPATH}"/rofi/config.rasi "${HOME}"/.config/rofi
sleep 1s

ln -svf "${APPSPATH}"/rofi/catppuccin-mocha.rasi "${HOME}"/.local/share/rofi/themes
sleep 1s

sed -i 's/set preview_images false/set preview_images true/g' "${HOME}"/.config/ranger/rc.conf
sleep 1s
sed -i 's/set draw_borders none/set draw_borders true/g' "${HOME}"/.config/ranger/rc.conf
sleep 1s

# cp "${SRCPATH}"/i3/config "${HOME}"/.config/i3
# cp -f "${SRCPATH}"/i3/configblocks "${HOME}"/.config/i3blocks/config
#
# if ! [[ -f /usr/share/xsessions/plasma-i3.desktop ]]; then
#     sudo touch /usr/share/xsessions/plasma-i3.desktop
#     sleep 1s
# fi
#
# printf "[Desktop Entry]\nType=XSession\nExec=env KDEWM=/usr/bin/i3 /usr/bin/startplasma-x11\nDesktopNames=KDE\nName=Plasma with i3 (X11)\nComment=Plasma with i3 (X11)\n" | sudo tee /usr/share/xsessions/plasma-i3.desktop
# sleep 1s

cd "${APPSPATH}"
#mkdir -p "${APPSPATH}"/bleh && cd ${APPSPATH}/bleh
echo
echo 'Installing ble'
echo
git clone --recursive https://github.com/akinomyoga/ble.sh.git
sleep 1s
make -C ble.sh
sleep 1s


echo
echo 'Installing Bismuth (Tiling Manager)'
echo
git clone https://github.com/Elfahor/bismuth.git
mkdir bismuth/build && cd bismuth/build
npm install typescript && npm audit fix --force
cmake ..
make
sudo make install

cd "${SRCPATH}"

# # Disable systemd startup
# echo
# echo "Disabling systemd startup"
# echo
# kwriteconfig5 --file startkderc --group General --key systemdBoot false
# sleep 1s

echo
echo "Disabling Show Activity Switcher's Meta+Q shortcut"
echo
sed -i 's/manage activities=Meta+Q,Meta+Q,Show Activity Switcher/manage activities=none,Meta+Q,Show Activity Switcher/g' $HOME/.config/kglobalshortcutsrc
sleep 1s

echo
echo "Setting CPU governor to Performance and setting min and max freq"
echo
sudo cpupower frequency-set -d 3.7GHz -u 4.2GHz -g performance
sleep 1s
sudo sed -i "s|#governor=.*|governor=performance|g" /etc/default/cpupower
sleep 1s
sudo sed -i "s|#min_freq=.*|min_freq=3.7GHz|g" /etc/default/cpupower
sleep 1s
sudo sed -i "s|#max_freq=.*|max_freq=4.2GHz|g" /etc/default/cpupower
sleep 1s

echo
echo "Set make to be multi-threaded by default"
echo
sudo sed -i "s|\#MAKEFLAGS=.*|MAKEFLAGS=\"-j$(expr $(nproc) \+ 1)\"|g" /etc/makepkg.conf
sleep 1s
sudo sed -i "s|COMPRESSXZ=.*|COMPRESSXZ=(xz -c -T $(expr $(nproc) \+ 1) -z -)|g" /etc/makepkg.conf
sleep 1s

echo
echo "Increasing file watcher count. This prevents a \"too many files\" error in VS Code(ium)"
echo
echo 'fs.inotify.max_user_watches=524288' | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system
sleep 1s

echo
echo "Decreasing swappiness"
echo
sudo sysctl -w vm.swappiness=10
sleep 1s
sudo bash -c 'echo "vm.swappiness = 10" > /etc/sysctl.d/99-swappiness.conf'

echo
echo "Setting up fq_pie queue discipline for TCP congestion control"
echo
echo 'net.core.default_qdisc = fq_pie' | sudo tee /etc/sysctl.d/90-override.conf
sleep 1s

echo
echo "Amending journald Logging to 200M"
echo
sudo sed -i "s|#SystemMaxUse=.*|SystemMaxUse=200M|g" /etc/systemd/journald.conf
sleep 1s

echo
echo "Disabling Coredump logging"
echo
sudo sed -i "s|#Storage=.*|Storage=none|g" /etc/systemd/coredump.conf
sleep 1s

echo
echo "Increasing open file limit"
echo
sudo sed -i "s|# End of file.*|$(logname)        hard    nofile          2097152\n\n# End of file\n|g" /etc/security/limits.conf
sudo sed -i "s|# End of file.*|$(logname)        soft    nofile          1048576\n\n# End of file\n|g" /etc/security/limits.conf
sudo sed -i "s|#DefaultLimitNOFILE=.*|DefaultLimitNOFILE=2097152|g" /etc/systemd/system.conf
sudo sed -i "s|#DefaultLimitNOFILE=.*|DefaultLimitNOFILE=1048576|g" /etc/systemd/user.conf
sleep 1s

echo
echo "Restricting Kernel Log Access"
echo
sudo sysctl -w kernel.dmesg_restrict=1
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

#if [[ -f /etc/pulse/daemon.conf ]]; then
#    echo
#    echo "Making a backup of \"/etc/pulse/daemon.conf\" to \"/etc/pulse/daemon.conf.old\""
#    echo
#    sudo mv /etc/pulse/daemon.conf /etc/pulse/daemon.conf.old
#    sleep 1s
#fi
#
#echo
#echo "Improving audio"
#echo
#sudo touch /etc/pulse/daemon.conf
#sleep 1s
#
#printf "default-sample-rate = 44100\nalternate-sample-rate = 48000\nresample-method = speex-float-10\nhigh-priority = yes\nnice-level = -11\nrealtime-scheduling = yes\nrealtime-priority = 5\n" | sudo tee /etc/pulse/daemon.conf
#sleep 1s
#
#echo
#echo "Backing up \"/etc/pulse/default.pa\" to \"/etc/pulse/default.pa.old\""
#echo
#sudo cp /etc/pulse/default.pa /etc/pulse/default.pa.old
#sleep 1s
#
#echo
#echo "Fixing sound delay when starting to play audio"
#echo
#sudo sed -i "s|load-module module-suspend-on-idle.*|#load-module module-suspend-on-idle|g" /etc/pulse/default.pa
#sudo sed -i "s|load-module module-udev-detect.*|load-module module-udev-detect tsched=0|g" /etc/pulse/default.pa
#sudo sed -i "s|.*load-module module-device-restore.*|#load-module module-device-restore|g" /etc/pulse/default.pa
#sudo sed -i "s|load-module module-detect.*|load-module module-detect tsched=0|g" /etc/pulse/default.pa
#sleep 1s

#if test -e /etc/modprobe.d/snd_hda_intel.conf; then
#    sudo mv /etc/modprobe.d/snd_hda_intel.conf /etc/modprobe.d/snd_hda_intel.conf.old
#    sleep 1s
#fi
#printf "options snd_hda_intel power_save=0\n" | sudo tee /etc/modprobe.d/snd_hda_intel.conf
#
#if [[ -f /etc/modprobe.d/sound.conf ]]; then
#    sudo mv /etc/modprobe.d/sound.conf /etc/modprobe.d/sound.conf.old
#    sleep 1s
#fi
#
#sudo touch /etc/modprobe.d/sound.conf
#printf "options snd-hda-intel vid=8086 pid=8ca0 snoop=0" | sudo tee /etc/modprobe.d/sound.conf
#sleep 1s
#
#if [[ -f /etc/modprobe.d/audio_powersave.conf ]]; then
#    sudo mv /etc/modprobe.d/audio_powersave.conf /etc/modprobe.d/audio_powersave.conf.old
#    sleep 1s
#fi
#
#sudo touch /etc/modprobe.d/audio_powersave.conf
#printf "options snd_hda_intel power_save=0\n" | sudo tee /etc/modprobe.d/audio_powersave.conf
#sudo touch /sys/module/snd_hda_intel/parameters/power_save_controller
#printf "N" | sudo tee /sys/module/snd_hda_intel/parameters/power_save_controller
#sleep 1s

if ! [[ -d /etc/X11/xorg.conf.d ]]; then
    sudo mkdir -p /etc/X11/xorg.conf.d
fi
if ! [[ -f /etc/X11/xorg.conf.d/50-mouse-acceleration.conf ]]; then
    sudo touch /etc/X11/xorg.conf.d/50-mouse-acceleration.conf
fi
printf "Section \"InputClass\"\n    Identifier \"My Mouse\"\n    Driver \"libinput\"\n    MatchIsPointer \"yes\"\n    Option \"AccelProfile\" \"-1\"\n    Option \"AccelerationScheme\" \"none\"\n    Option \"AccelSpeed\" \"-1\"\nEndSection" | sudo tee /etc/X11/xorg.conf.d/50-mouse-acceleration.conf
sleep 1s

echo
echo "Disabling built-in kernel modules of tablet so OpenTablerDriver can work"
echo
if ! test -e /etc/modprobe.d/blacklist.conf; then
    sudo touch /etc/modprobe.d/blacklist.conf
    printf "blacklist wacom\nblacklist hid_uclogic" | sudo tee /etc/modprobe.d/blacklist.conf
    sleep 1s
else
    printf "\nblacklist wacom\nblacklist hid_uclogic" | sudo tee -a /etc/modprobe.d/blacklist.conf
    sleep 1s
fi

echo
echo "Stopping Wacom kernel module (if present)"
echo
sudo rmmod wacom
sleep 1s

echo
echo "Stopping non-Wacom kernel module (if present)"
echo
sudo rmmod hid_uclogic
sleep 1s

echo
echo "Improving font rendering"
echo
if test -e /etc/fonts/local.conf; then
    sudo mv /etc/fonts/local.conf /etc/fonts/local.conf.old
    sleep 1s
fi

sudo touch /etc/fonts/local.conf
sleep 1s

curl https://raw.githubusercontent.com/StefanoND/ArchS/main/Misc/local.conf -o - | sudo tee /etc/fonts/local.conf
sleep 1s

if test -e /home/$(logname)/.Xresources; then
    sudo mv /home/$(logname)/.Xresources /home/$(logname)/.Xresources.bak;
    sleep 1s
fi

touch /home/$(logname)/.Xresources
sleep 1s

printf "Xft.antialias: 1\nXft.hinting: 1\nXft.rgba: rgb\nXft.hintstyle: hintslight\nXft.lcdfilter: lcddefault" | tee /home/$(logname)/.Xresources
sleep 1s

xrdb -merge /home/$(logname)/.Xresources
sleep 1s
if ! test -e /etc/fonts/conf.d/10-sub-pixel-rgb.conf; then
    sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
    sleep 1s
fi

if ! test -e /etc/fonts/conf.d/10-hinting-slight.conf; then
    sudo ln -s /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d
    sleep 1s
fi

if ! test -e /etc/fonts/conf.d/11-lcdfilter-default.conf; then
    sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
    sleep 1s
fi

if ! test -e /home/$(logname)/.config/fontconfig; then
    mkdir -p /home/$(logname)/.config/fontconfig
    sleep 1s
fi

if test -e /home/$(logname)/.config/fontconfig/fonts.conf; then
    mv /home/$(logname)/.config/fontconfig/fonts.conf /home/$(logname)/.config/fontconfig/fonts.conf.bak;
    sleep 1s
fi

touch /home/$(logname)/.config/fontconfig/fonts.conf
sleep 1s
curl https://raw.githubusercontent.com/StefanoND/ArchS/main/Misc/fonts.conf -o - | sudo tee /home/$(logname)/.config/fontconfig/fonts.conf
sleep 1s
sudo sed -i "s|#export FREETYPE_PROPERTIES=\"truetype:interpreter-version=|export FREETYPE_PROPERTIES=\"truetype:interpreter-version=|g" /etc/profile.d/freetype2.sh
sleep 1s
sudo fc-cache -fv
sleep 1s

echo
echo "Enabling CUPs service"
echo

cd /usr/bin
./cupsenable
sleep 1s

echo
echo "Creating udev rule for AntiMicroX to avoid problems with wayland"
echo
sleep 1s
if test -e /usr/lib/udev/rules.d/60-antimicrox-uinput.rules; then
    sudo mv /usr/lib/udev/rules.d/60-antimicrox-uinput.rules /usr/lib/udev/rules.d/60-antimicrox-uinput.rules.old
    sleep 1s
fi

sudo touch /usr/lib/udev/rules.d/60-antimicrox-uinput.rules
sleep 1s

curl https://raw.githubusercontent.com/AntiMicroX/antimicrox/master/other/60-antimicrox-uinput.rules -o - | sudo tee /usr/lib/udev/rules.d/60-antimicrox-uinput.rules
sleep 1s

if [[ `pacman -Q | grep -i 'virtualbox-host-dkms'` ]] && [[ ${enablevb,,} = y ]]; then
    PKGVB=(
        # Virtualbox
        'virtualbox-host-dkms'
        'virtualbox'
        'virtualbox-ext-vnc'
        'virtualbox-guest-iso'
    )

    for PKG in "${PKGVB[@]}"; do
        echo
        echo "INSTALLING: ${PKG}"
        echo
        sudo pacman -S "$PKG" --noconfirm --needed
        echo
        sleep 1s
    done

    echo
    echo "Modprobing vboxdrv, vboxnetadp and vboxnetflt"
    echo
    sudo usermod -aG vboxusers $(logname)
    sleep 1s
    sudo modprobe -a vboxdrv vboxnetadp vboxnetflt
    sleep 1s

    echo
    echo 'Reloading daemon'
    echo
    sudo systemctl daemon-reload
    sleep 1s

    echo
    echo "Enabling VirtualBox and web services"
    echo
    sudo systemctl enable vboxservice.service
    sleep 1s
    sudo systemctl enable vboxweb.service
    sleep 1s
fi

echo
echo 'Reloading daemon'
echo
sudo systemctl daemon-reload
sleep 1s

echo
echo 'Enabling zram'
echo
sudo systemctl start /dev/zram0
sleep 1s

echo
echo "Enabling cpupower service"
echo
sudo update-rc.d ondemand disable
sudo systemctl disable ondemand
sudo systemctl mask power-profiles-daemon.service
sudo systemctl enable --now cpupower.service
sleep 1s

echo
echo "Enabling gnome-keyring service"
echo
systemctl --user enable --now gnome-keyring-daemon.service
sleep 1s

echo
echo "Enabling gamemode service"
echo
systemctl --user enable --now gamemoded.service
sleep 1s
sudo chmod +x /usr/bin/gamemoderun
sleep 1s

echo
echo "Enabling opentrabletdriver service"
echo
systemctl --user enable --now opentabletdriver.service
sleep 1s

# SSH
echo
echo 'Enaling sshd service'
echo
sudo systemctl enable --now sshd.service
# CUPS service
echo
echo 'Enabling cups service'
echo
sudo systemctl enable --now cups.service

echo
echo "Updating initramfs/initrd"
echo
sudo mkinitcpio -P

echo
echo 'Syncing system'
echo
sync
sleep 1s

echo
echo 'Done...'
echo
echo "Don't forget to check https://github.com/StefanoND/ArchS/blob/main/Misc/vulkandrivers.sh for dealing with loading Vulkan Drivers"
echo
echo 'Press Y to reboot now or N if you plan to manually reboot later.'
echo
read REBOOT
if [ ${REBOOT,,} = y ]; then
    shutdown -r now
fi
exit 0
