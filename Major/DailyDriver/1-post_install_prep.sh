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

echo
echo "Removing install blocker"
echo
sudo rm -f /var/lib/pacman/db.lck
sleep 1s

clear

echo
echo 'Make a change in sddm, you can change to something else and back to the default one'
echo "Press any key when you're done"
echo
read ANYKEY
echo
sleep 1s

# To check for available keymaps use the command below
# localectl list-x11-keymap-layouts

KBLOCALE="pt"
VALIDPARTTWO=n
VALIDPARTTHREE=n

APPSPATH="${HOME}/.apps"
SRCPATH="$(cd $(dirname $0) && pwd)"
FFPATH="${SRCPATH}/conf/aesthetic/ff"

echo
echo "Installing Nix Package Manager"
echo
sh <(curl -L https://nixos.org/nix/install) --daemon
sleep 1s

echo
echo 'Setting locale'
echo
# Set your keyboard layout on X11
localectl set-x11-keymap $KBLOCALE
sleep 1s

sudo pacman -Syy
sleep 1s

if pacman -Q | grep -i 'iptables' && ! pacman -Q | grep -i 'iptables-nft'; then
    echo
    echo 'Uninstalling iptables'
    echo
    sudo pacman -Rdd iptables --noconfirm
    sleep 1s
fi

echo
echo 'Installing iptables-nft'
echo
sudo pacman -S iptables-nft --noconfirm --needed
sleep 1s

if ! [[ -d "${APPSPATH}" ]]; then
    echo
    printf "Creating ${APPSPATH} path"
    echo
    mkdir -p "${APPSPATH}"
    sleep 1s
fi

if ! [[ -d "${HOME}"/.local/bin ]]; then
    echo
    printf "Creating ${HOME}/.local/bin"
    echo
    mkdir -p "${HOME}"/.local/bin
    sleep 1s
fi

echo
echo 'Installing flatpak'
echo
sudo pacman -S flatpak --noconfirm --needed
sleep 1s

echo
echo "Adding flathub"
echo
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sleep 1s

echo
printf "Linking /usr/share/fonts to $HOME/.fonts"
echo
ln -svf /usr/share/fonts $HOME/.fonts

echo
echo 'Applying themes and fonts to Flatpak and its apps'
echo
ln -svf "${HOME}"/.local/share/icons/Tela-circle-purple-dark "${HOME}"/.icons/

flatpak override --user --filesystem="${HOME}"/.themes
flatpak override --user --filesystem="${HOME}"/.icons
flatpak override --user --env=GTK_THEME=Orchis-Purple-Dark
flatpak override --user --env=ICON_THEME=Tela-circle-dark
flatpak override --user --filesystem=/usr/share/fonts/:ro
flatpak override --user --filesystem=$HOME/.fonts/:ro
sudo flatpak override --system --filesystem="${HOME}"/.themes
sudo flatpak override --system --filesystem="${HOME}"/.icons
sudo flatpak override --system --env=GTK_THEME=Orchis-Purple-Dark
sudo flatpak override --system --env=ICON_THEME=Tela-circle-dark
sudo flatpak override --system --filesystem=/usr/share/fonts/:ro
sudo flatpak override --system --filesystem=$HOME/.fonts/:ro

echo
echo 'Enabling Chaotic AUR Repo'
echo
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sleep 1s

sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
sleep 1s

sudo bash -c "echo '[chaotic-aur]' >> /etc/pacman.conf"
sudo bash -c "echo 'Include = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf"
sudo bash -c "echo '' >> /etc/pacman.conf"
sleep 1s

echo
echo 'Enabling Valve AUR Repo'
echo
sudo bash -c "echo '[valveaur]' >> /etc/pacman.conf"
sudo bash -c "echo 'Server = http://repo.steampowered.com/arch/valveaur' >> /etc/pacman.conf"
sudo bash -c "echo '' >> /etc/pacman.conf"
sleep 1s

# echo
# echo 'Enabling Garuda Repo'
# echo
# sudo bash -c "echo '[garuda]' >> /etc/pacman.conf"
# sudo bash -c "echo 'SigLevel = Required DatabaseOptional' >> /etc/pacman.conf"
# sudo bash -c "echo 'Include = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf"
# sudo bash -c "echo '' >> /etc/pacman.conf"
# sleep 1s

echo
echo 'Syncing repo'
echo
sudo pacman -Syy

echo
echo "Installing meson as dependency"
echo
sudo pacman -S meson --asdep --noconfirm --needed
sleep 1s


PKGS=(
    # Kernel
    'linux-xanmod-rt'
    'linux-xanmod-rt-headers'

    # Tools
    'rustup'                                    # Rust toolchain
    'mingw-w64'                                 # MinGW Cross-compiler pack (binutils, crt, gcc, headers and winpthreads)
    'libconfig'                                 # C/C++ Configuration file library
    'gdb'                                       # GNU Debugger
    'lldb'                                      # High performance debugger
    'clang'
    'lib32-clang'
    'llvm'
    'llvm-libs'
    'lib32-llvm'
    'lib32-llvm-libs'
    'make'
    'cmake'
    'extra-cmake-modules'
    'gnome-keyring'                             # Required by some apps for authentication
    'libgnome-keyring'                          # Required by some apps for authentication
    'libasyncns'
    'lib32-libasyncns'
    'patch'
    'ranger'
    'tree-sitter'
    'tree-sitter-cli'
    'luarocks'

    # Dependencies
    'lib32-acl'
    'lib32-attr'
    'lib32-gettext'
    'lib32-libnl'
    'lib32-libpcap'
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
    #'wine-staging'
    #'wine-mono'
    #'wine-gecko'
    #'winetricks'
    'gst-plugins-base'
    'gst-plugins-good'
    'gst-plugins-ugly'
    'gst-plugins-bad'
    'ttf-jetbrains-mono-nerd'                   # Nerdfonts
    'emacs-nativecomp'
    'ripgrep'
    'fd'
    'tldr'
    'shfmt'
    'shellcheck'
    'lazygit'
    'omnisharp-roslyn'
    'vscode-json-languageserver'
    'lua-language-server'
    'rust-analyzer'
    'yaml-language-server'
    'bash-language-server'
    'aspell'
    'enchant'
    'hunspell'
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo pacman -S "$PKG" --noconfirm --needed
    echo
    sleep 1s
done

echo
echo 'Installing DOOM Emacs'
echo
git clone https://github.com/hlissner/doom-emacs "${HOME}"/.emacs.d
"${HOME}"/.emacs.d/bin/doom install

emacs
sleep 5s
sudo killall -9 emacs

"${HOME}"/.emacs.d/bin/doom sync
sleep 1s

rm -rf "${HOME}"/.local/share/nvim
mv "${HOME}"/.config/nvim "${HOME}"/.config/nvim.old

# Interesting https://www.youtube.com/watch?v=w7i4amO_zaE
# NvChad https://www.youtube.com/watch?v=lsFoZIg-oDs
# Copilot https://www.youtube.com/watch?v=eMnZBaOs4vM

echo
echo ''
echo
git clone https://github.com/NvChad/NvChad "${HOME}"/.config/nvim --depth 1

#echo
#echo 'Initializing wine'
#echo
#wineboot
#sleep 1s

echo
echo 'Making xanmod-rt the default kernel to boot'
echo
sudo sed -i 's/default arch.conf/default arch-xanmod-rt.conf/g' /boot/loader/loader.conf
sleep 1s

if ! [[ -d /etc/modprobe.d ]]; then
    sudo mkdir -p /etc/modprobe.d
fi

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    sudo bash -c "echo 'blacklist nouveau' > /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo 'blacklist lbm-nouveau' >> /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo 'options nouveau modeset=0' >> /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo 'alias nouveau off' >> /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo 'alias lbm-nouveau off' >> /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo '' >> /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo 'options nouveau modeset=0' > /etc/modprobe.d/nouveau-kms.conf"
fi

echo
echo 'Updatin initramfs'
echo
sudo mkinitcpio -P
sleep 1s

echo
echo "Config Ranger"
echo
ranger --copy-config=all
export RANGER_LOAD_DEFAULT_RC=false
sudo bash -c "printf \"RANGER_LOAD_DEFAULT_RC=false\n\" >> /etc/environment"
sleep 1s

sed -i 's/set preview_images false/set preview_images true/g' "${HOME}"/.config/ranger/rc.conf
sleep 1s
sed -i 's/set draw_borders none/set draw_borders true/g' "${HOME}"/.config/ranger/rc.conf
sleep 1s

echo
echo "Installing stable version of Rustup"
echo
rustup install stable
sleep 1s

echo
echo "Adding i686 architecture support for Rustup"
echo
rustup target install i686-unknown-linux-gnu
sleep 1s

echo
echo "Setting stable as our default Rustup toolchain"
echo
rustup default stable
sleep 1s

echo
echo "Setting Cargo to run commands in parallel"
echo
cargo install async-cmd
sleep 1s

echo
echo "Installing Paru"
echo
cd "${APPSPATH}" && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg --noconfirm --needed -si
sleep 1s

cd "${SRCPATH}"

echo
echo "Setting ranger as paru's File Manager"
echo
sudo sed -i "s|\#\[bin]|[bin]|g" /etc/paru.conf
sleep 1s
sudo sed -i "s|#FileManager.*|FileManager = ranger|g" /etc/paru.conf
sleep 1s

# Turn on swap
echo
echo 'Turning swapfile on'
echo
sudo swapon /swap/swapfile
sleep 1s

echo
echo "Enabling btrfs's automatic balance at 10% threshold"
echo
sudo bash -c "echo 10 > /sys/fs/btrfs/$(sudo blkid -s UUID -o value /dev/mapper/root)/allocation/data/bg_reclaim_threshold"
sleep 1s
sudo bash -c "echo 10 > /sys/fs/btrfs/$(sudo blkid -s UUID -o value /dev/mapper/home)/allocation/data/bg_reclaim_threshold"
sleep 1s

if ! [[ -f "${HOME}"/.config/kxkbrc ]]; then
    touch "${HOME}"/.config/kxkbrc
fi

echo '' >> "${HOME}"/.config/kxkbrc
sleep 1s
echo '[Layout]' >> "${HOME}"/.config/kxkbrc
sleep 1s
printf "LayoutList=$KBLOCALE\n" >> "${HOME}"/.config/kxkbrc
sleep 1s
echo 'Use=true' >> "${HOME}"/.config/kxkbrc
sleep 1s
echo '' >> "${HOME}"/.config/kxkbrc
sleep 1s

echo '$include /etc/inputrc' >> "${HOME}"/.inputrc
echo 'set completion-ignore-case On' >> "${HOME}"/.inputrc
echo '' >> "${HOME}"/.inputrc

if ! [[ -d "${APPSPATH}" ]]; then
    echo
    printf "mkdir -p \"${APPSPATH}\""
    echo
    mkdir -p "${APPSPATH}"
    sleep 1s
fi
if ! [[ -d "${APPSPATH}"/archs ]]; then
    echo
    printf "mkdir -p \"${APPSPATH}\"/archs"
    echo
    mkdir -p "${APPSPATH}"/archs
    sleep 1s
fi
if ! [[ `pacman -Q | grep -i 'kvantum'` ]]; then
    sudo pacman -S kvantum ttf-fira-code --noconfirm --needed
    sleep 1s
fi
if ! [[ -d "${HOME}"/.config/Kvantum ]]; then
    echo
    printf "mkdir -p "${HOME}"/.config/Kvantum"
    echo
    mkdir -p "${HOME}"/.config/Kvantum
    sleep 1s
fi
if ! [[ -d "${HOME}"/.config/gtk-3.0 ]]; then
    echo
    printf "mkdir -p "${HOME}"/.config/gtk-3.0"
    echo
    mkdir -p "${HOME}"/.config/gtk-3.0
    sleep 1s
fi
if ! [[ -d "${HOME}"/.config/gtk-4.0 ]]; then
    echo
    printf "mkdir -p "${HOME}"/.config/gtk-4.0"
    echo
    mkdir -p "${HOME}"/.config/gtk-4.0
    sleep 1s
fi
if ! [[ -d /usr/share/icons/Sweet-cursors ]] && [[ -d "${HOME}"/.icons/Sweet-cursors ]]; then
    echo
    printf "sudo cp -r "${HOME}"/.icons/Sweet-cursors /usr/share/icons"
    echo
    sudo cp -r "${HOME}"/.icons/Sweet-cursors /usr/share/icons
    sleep 1s
fi
if [[ -f "${HOME}"/.gtkrc-2.0 ]]; then
    echo
    printf "mv "${HOME}"/.gtkrc-2.0 "${HOME}"/.gtkrc-2.0.old"
    echo
    mv "${HOME}"/.gtkrc-2.0 "${HOME}"/.gtkrc-2.0.old
    sleep 1s
fi
if ! [[ -f /etc/sddm.conf.d/avatars.conf ]]; then
    echo
    printf "sudo touch /etc/sddm.conf.d/avatars.conf"
    echo
    sudo touch /etc/sddm.conf.d/avatars.conf
    printf "[Theme]\nEnableAvatars=true\nDisableAvatarsThreshold=7" | sudo tee /etc/sddm.conf.d/avatars.conf
    sleep 1s
fi
if ! [[ -f /usr/share/sddm/scripts/Xsetup ]]; then
    echo
    printf "sudo touch /usr/share/sddm/scripts/Xsetup"
    echo
    sudo touch /usr/share/sddm/scripts/Xsetup
    printf "#!/bin/sh\n# Xsetup - run as root before the login dialog appears\n" | sudo tee /usr/share/sddm/scripts/Xsetup
    sleep 1s
fi

echo
printf "setxkbmap $KBLOCALE\n" | sudo tee -a /usr/share/sddm/scripts/Xsetup
echo
sleep 1s

echo
echo 'Applying theme to /etc/sddm.conf.d/kde_settings.conf'
echo
sudo sed -i '/^Current=.*/a CursorSize=36' /etc/sddm.conf.d/kde_settings.conf
sleep 1s
sudo sed -i '/^Current=.*/a CursorTheme=Sweet-cursors' /etc/sddm.conf.d/kde_settings.conf
sleep 1s
sudo sed -i "/^Current=.*/a Font='Fira Code'" /etc/sddm.conf.d/kde_settings.conf
sleep 1s

echo
echo 'Applying theme to /usr/lib/sddm/sddm.conf.d/default.conf'
echo
sudo sed -i 's/Current=.*/Current=sugar-candy/g' /usr/lib/sddm/sddm.conf.d/default.conf
sleep 1s
sudo sed -i 's/CursorSize=.*/CursorSize=36/g' /usr/lib/sddm/sddm.conf.d/default.conf
sleep 1s
sudo sed -i 's/CursorTheme=.*/CursorTheme=Sweet-cursors/g' /usr/lib/sddm/sddm.conf.d/default.conf
sleep 1s
sudo sed -i "s/Font=.*/Font='Fira Code'/g" /usr/lib/sddm/sddm.conf.d/default.conf
sleep 1s

echo
echo 'Copying .gtkrc-2.0, gkt-3.0, gtk-4.0, Kvantum config files'
echo
cp "${FFPATH}"/.gtkrc-2.0 "${HOME}"/
cp "${FFPATH}"/settings.ini "${HOME}"/.config/gtk-3.0
cp "${FFPATH}"/settings.ini "${HOME}"/.config/gtk-4.0
cp -r "${FFPATH}"/Orchis-dark "${HOME}"/.config/Kvantum
sleep 1s

if [[ -f "${HOME}"/.bashrc ]]; then
    echo
    echo 'Backing up .bashrc'
    echo
    mv "${HOME}"/.bashrc "${HOME}"/.bashrc.old
    sleep 1s
fi
if [[ -f "${HOME}"/.bash_aliases ]]; then
    echo
    echo 'Backing up .bash_aliases'
    echo
    mv "${HOME}"/.bash_aliases "${HOME}"/.bash_aliases.old
    sleep 1s
fi
if [[ -f "${HOME}"/.xinitrc ]]; then
    echo
    echo 'Backing up .xinitrc'
    echo
    mv "${HOME}"/.xinitrc "${HOME}"/.xinitrc.old
    sleep 1s
fi
if [[ -f "${HOME}"/.bash_profile ]]; then
    echo
    echo 'Backing up .bash_profile'
    echo
    mv "${HOME}"/.bash_profile "${HOME}"/.bash_profile.old
    sleep 1s
fi
if ! [[ -d "${HOME}"/.config/autostart ]]; then
    echo
    printf "Creating autostart folder in "${HOME}"/.config"
    echo
    mkdir -p "${HOME}"/.config/autostart
fi

sed -i "s/111111/$(logname)/g" "${SRCPATH}"/conf/home-manager/*

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    mv "${SRCPATH}"/conf/home-manager/helpersNVIDIA.nix "${SRCPATH}"/conf/home-manager/helpers.nix
elif lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq intel || lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq virtio; then
    mv "${SRCPATH}"/conf/home-manager/helpersINTEL.nix "${SRCPATH}"/conf/home-manager/helpers.nix
    sed -i 's/nixGLVulkanNvidiaWrap/nixGLVulkanMesaWrap/g' "${SRCPATH}"/conf/home-manager/*
    sed -i 's/auto.nixGLNvidia/nixGLIntel/g' "${SRCPATH}"/conf/home-manager/*
    sed -i 's/auto.nixVulkanNvidia/nixVulkanIntel/g' "${SRCPATH}"/conf/home-manager/*
    sed -i 's/nixGLNvidia/nixGLIntel/g' "${SRCPATH}"/conf/home-manager/*
fi

echo
printf "Copying config files to a permanent place at: "
printf "\"${APPSPATH}/archs\""
echo
cp -f "${SRCPATH}"/conf/home/.bashrc "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/.bash_profile "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/.bash_aliases "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/.dir_colors "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/.profile "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/.wezterm.lua "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/.xinitrc "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/sxhkd.desktop "${APPSPATH}"/archs
cp -rf "${SRCPATH}"/conf/home-manager "${APPSPATH}"/archs
cp -rf "${SRCPATH}"/conf/nix "${APPSPATH}"/archs
rm -f "${APPSPATH}"/archs/home-manager/helpersNVIDIA.nix
rm -f "${APPSPATH}"/archs/home-manager/helpersINTEL.nix
sleep 1s

printf "Copying/Symlinking config files to ${HOME} and ${HOME}/.config/autostart"
ln -svf "${APPSPATH}"/archs/.bashrc "${HOME}"
ln -svf "${APPSPATH}"/archs/.bash_profile "${HOME}"
ln -svf "${APPSPATH}"/archs/.bash_aliases "${HOME}"
ln -svf "${APPSPATH}"/archs/.dir_colors "${HOME}"
ln -svf "${APPSPATH}"/archs/.profile "${HOME}"
ln -svf "${APPSPATH}"/archs/.wezterm.lua "${HOME}"
ln -svf "${APPSPATH}"/archs/.xinitrc "${HOME}"
cp -f "${APPSPATH}"/archs/sxhkd.desktop "${HOME}"/.config/autostart
sleep 1s

if ! [[ -d /etc/wireplumber/main.lua.d ]]; then
    echo
    echo 'Creating "/etc/wireplumber/main.lua.d" folder'
    echo
    sudo mkdir -p /etc/wireplumber/main.lua.d
fi

echo
echo 'Disabling sound suspension (Gets rid of starting audio delay)'
echo
sudo cp -rf "${SRCPATH}"/conf/pipewire/51-disable-suspension.lua /etc/wireplumber/main.lua.d/

#cd ${HOME}
#curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > .git-completion.bash
#curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh > .git-prompt.sh
#chmod +x .git-completion.bash
#chmod +x .git-prompt.sh

#echo
#echo 'Copying Sweet-cursors to /usr/share/icons'
#echo
#sudo cp -r "${FFPATH}"/Sweet-cursors /usr/share/icons

if ! [[ -d "${HOME}"/.icons/default ]]; then
    mkdir -p "${HOME}"/.icons/default
fi

echo
echo 'Making cursor use Sweet-cursors'
echo
echo '[Icon THeme]' > "${HOME}"/.icons/default/index.theme
echo 'Inherits=Sweet-cursors' >> "${HOME}"/.icons/default/index.theme
sleep 1s

bash -l "${SRCPATH}"/1.1-post_install_prep.sh

#echo
#echo "Download themes"
#echo
#
#echo
#echo "Global Theme: Orchis-dark (https://store.kde.org/p/1458927)"
#echo
#echo "Application Style: kvantum-dark"
#echo "    GNOME/GTK Application Style: Orchis-Purple-Dark (https://store.kde.org/p/1357889)"
#echo
#echo "Plasma Style: Orchis-dark"
#echo
#echo "Colors: OrchisDark"
#echo
#echo "Window Decorations: Orchis-dark"
#echo "    Window border size: No Borders"
#echo "    Titlebar Buttons: Remove All, untick both \"Close windows by double click\" and \"Show titlebar tooltips\""
#echo "Note: Rounded Corners works best with Breeze. Other Window Decorations might give you either transparent triangles or black lines on the corners"
#echo "It depends how rounded/squared the Window Decoration is"
#echo
#echo "All Fira Code"
#echo "    Anti-Aliasing: Enable"
#echo "    Sub-pixel rendering: RGB"
#echo "    Hinting: Slight"
#echo "    Force font DPI: Disabled"
#echo
#echo "Icons: Tela Circle (Purple) (https://store.kde.org/p/1359276)"
#echo
#echo "Cursors: Sweet-cursors (https://store.kde.org/p/1393084)"
#echo
#echo "Splash Screen: Simple Tux Splash (https://store.kde.org/p/1258784)"
#echo
#echo "Boot Splash Screen: TUX BOOT SPLASH (https://store.kde.org/p/1189328)"
#echo
#echo "Login Screen (SDDM): Chili for Plasma (https://store.kde.org/p/1214121)"
#echo "Login Screen (SDDM): Sugar Candy for SDDM (https://store.kde.org/p/1312658)"
#echo
#echo "Window Management->Task Switcher: Thumbnail Switcher (https://store.kde.org/p/2010367)"
#echo
