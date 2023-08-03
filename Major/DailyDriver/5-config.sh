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

echo
echo "These processes will take a long time to finish, increase sudo timeout."
echo "use 'sudo EDITOR=vim visudo' or 'sudo EDITOR=nano visudo' and add 'Defaults passwd_timeout=-1'"
echo "WARNING: THE ABOVE IS EXTREMELY DANGEROUS, REMOVE THEM AFTER EVERYTHING IS DONE"
echo "WARNING: DON'T LEAVE YOUR PC/LAPTOP UNATENDED"
echo
echo "Press anything to continue"
echo
read READY

changetonvim=n
disablemouseaccel=n

echo
echo "Change alias VIM to NVIM? Y - Yes | N - No"
echo
read CHANGEAL
changetonvim=$CHANGEAL

echo
echo "Disable mouse acceleration?"
echo "Y - Disable | Anything else - Keep enabled"
echo
read DISMOUSACEL
disablemouseaccel=$DISMOUSACEL

sleep 1s

echo
echo "Removing install blocker, nothing was supposed to be installing anyway"
echo
sudo rm -f /var/lib/pacman/db.lck

sleep 1s

echo
echo "Removing leftover files that may exist"
echo
rm .b* .z*

sleep 1s

clear

echo
echo
echo
echo "Grab a coffee and come back later, it'll take some time"
echo

sleep 2s

echo
echo "Adding Valve aur repo to the mirror list"
echo
printf "[valveaur]\n" | sudo tee -a /etc/pacman.conf
printf "SigLevel = Optional TrustedOnly\n" | sudo tee -a /etc/pacman.conf
printf "Server = http://repo.steampowered.com/arch/valveaur\n" | sudo tee -a /etc/pacman.conf
sleep 2s
sudo pacman -Syy

sleep 1s

echo
echo "Enabling Color and ILoveCandy"
echo
sudo sed -i "s|#Color.*|Color\nILoveCandy|g" /etc/pacman.conf

sleep 1s

echo
echo "Updating mirrors with fast ones"
echo
sudo pacman-mirrors --fasttrack --api --protocols all --set-branch stable

sleep 1s

echo
echo "Updating system"
echo
sleep 1s
sudo pacman -Syyu --noconfirm --needed

sleep 2s

PKGZ=(
    'firefox'
    'linux-nvidia'
    'linux61-nvidia'
    'linux62-nvidia'
    'linux63-nvidia'
    'linux64-nvidia'
)

for PKG in "${PKGZ[@]}"; do
    echo
    echo "UNINSTALLING: ${PKG}"
    echo
    sudo pacman -Rsn "$PKG" --noconfirm
    sleep 1s
done

sudo pacman -S meson --asdep --noconfirm --needed
sleep 1s

PKGS=(
    # Tools
    'base-devel'                                # Basic tools
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
    'alsa-utils'                                # Better audio config
    'extra-cmake-modules'
    'gnome-keyring'                             # Required by some apps for authentication

    # Kernel
    'linux63'                                   # Kernel and modules
    'linux63-headers'                           # Header files
    'linux61'                                   # Kernel and modules (LTS)
    'linux61-headers'                           # Header files (LTS)
    'dkms'                                      # Dynamic Kernel Modules System

    # Packet Manager
    'flatpak'                                   # Flatpak
    'libpamac-flatpak-plugin'                   # Flathub plugin
    'discover'                                  # GUI Packet Manager

    # Fonts
    'noto-fonts-extra'                          # Additional variants of noto fonts
    'noto-fonts-cjk'                            # Chinese Japanese Korean (CJK) characters support
    'noto-fonts-emoji'                          # Support for emojis
    'ttf-fira-code'                             # My personal favorite font for programming
    'gnu-free-fonts'                            # Free family of scalable outline fonts
    'powerline-fonts'                           # Patched fonts for powerline
    'ttf-meslo-nerd-font-powerlevel10k'         # Meslo Nerd font patched for Powerlevel10k
    'ttf-nerd-fonts-symbols'                    #
    'ttf-nerd-fonts-symbols-common'             #
    'ttf-nerd-fonts-symbols-mono'               #
    'ttf-ubuntu-font-family'                    # Ubuntu font

    # Shell/Terminal
    'kitty'                                     # Terminal
    'yakuake'                                   # Dropdown Terminal

    # Misc
    'neovim'                                    #
    'cpupower'                                  # CPU tuning utility
    'vifm'                                      # Filemanager
    'lsd'
    'curl'
    'python-pyqt5'

    # Virtualbox
    'linux63-virtualbox-host-modules'           # For Manjaro
    #'virtualbox-host-dkms'                     # For Non-Manjaro
    'virtualbox'
    'virtualbox-ext-vnc'
    'virtualbox-guest-utils'
    'virtualbox-guest-iso'
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo pacman -S "$PKG" --noconfirm --needed
    echo
    sleep 1s
done

flatpak remote-add flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo

sleep 1s

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    echo
    echo "Installing NVidia dkms"
    echo
    sleep 1s
    sudo pacman -S nvidia-dkms --noconfirm --needed
fi

sleep 1s

if ! test -e $HOME/.bash_aliases; then
    touch $HOME/.bash_aliases
fi

if ! grep -q ".bash_aliases" $HOME/.bashrc; then
    printf "\nif [ -e $HOME/.bash_aliases ]; then\n    source $HOME/.bash_aliases\nfi\n" | tee -a $HOME/.bashrc
fi

if [ ${changetonvim,,} = y ]; then
    echo
    alias vim=nvim
    echo 'alias vim=nvim' >> $HOME/.bash_aliases
    sleep 1s
fi

echo
alias ls=lsd
echo 'alias ls=lsd' >> $HOME/.bash_aliases
sleep 1s

git clone --recursive https://github.com/akinomyoga/ble.sh.git
make -C ble.sh
printf "\nsource ble.sh/out/ble.sh\n" | tee -a $HOME/.bashrc

echo
echo "Setting CPU governor to Performance and setting min and max freq"
echo
sudo cpupower frequency-set -d 3.7GHz -u 4.2GHz -g performance
sudo sed -i "s|#governor=.*|governor=performance|g" /etc/default/cpupower
sudo sed -i "s|#min_freq=.*|min_freq=3.7GHz|g" /etc/default/cpupower
sudo sed -i "s|#max_freq=.*|max_freq=4.2GHz|g" /etc/default/cpupower
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
systemctl --user enable --now gnome-keyring-daem