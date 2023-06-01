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

sleep 1s
if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
    exit 1
fi

READY=n

echo
echo "Can this script increase sudo password timeout to 1 hour?"
echo "It'll be removed after this script is done"
echo "WARNING: ONLY ALLOW IF YOU KNOW WHAT YOU'RE DOING"
echo "Y - Allow | N - Deny (Recommended)"
echo
read ALLOW
READY=$ALLOW
if [ ${READY,,} = y ]; then
    echo
    echo "Increasing sudo password timeout to 1 hour"
    echo
    sleep 1s
    printf "Defaults passwd_timeout=60" | sudo EDITOR='tee -a' visudo
fi

sleep 1s

echo
echo "Post-install will start"
echo

sleep 1s

echo
echo "Change Keyboard layout to PT? Y - Yes | N - No"
echo
read CHANGEKB
if [ ${CHANGEKB,,} = y ]; then
    echo
    echo 'setxkbmap pt' | sudo tee -a /usr/share/sddm/scripts/Xsetup
    echo
    sleep 1s
    if ! test -e /etc/X11/xorg.conf.d/00-keyboard.conf; then
        sudo touch /etc/X11/xorg.conf.d/00-keyboard.conf
    fi
    printf "Section \"InputClass\"\n    Identifier \"keyboard\"\n    MatchIsKeyboard \"yes\"\n    Option \"XkbLayout\" \"pt\"\n    Option \"XkbVariant\" \"\"\nEndSection" | sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf
    echo
    sleep 1s
fi

echo
echo "Change alias VIM to NVIM? Y - Yes | N - No"
echo
read CHANGEAL
if [ ${CHANGEAL,,} = y ]; then
    echo
    alias vim=nvim
    echo 'alias vim=nvim' >> .zshrc
    sleep 1s
fi

sleep 1s

echo
echo "Removing install blocker, nothing was supposed to be installing anyway"
echo
sleep 1s
sudo rm -f /var/lib/pacman/db.lck

sleep 1s

echo
echo "Removing leftover files that may exist"
echo
sleep 1s
rm .b* .z*

sleep 1s

echo
echo "Adding Valve aur repo to the mirror list"
echo
sleep 1s
printf "[valveaur]\n" | sudo tee -a /etc/pacman.conf
sleep 1s
printf "SigLevel = Optional TrustedOnly\n" | sudo tee -a /etc/pacman.conf
sleep 1s
printf "Server = http://repo.steampowered.com/arch/valveaur\n" | sudo tee -a /etc/pacman.conf
sleep 2s
sudo pacman -Syy

sleep 1s

echo
echo "Enabling Color and ILoveCandy"
echo
sleep 1s
sudo sed -i "s|#Color.*|Color\nILoveCandy|g" /etc/pacman.conf

sleep 1s

echo
echo "Updating mirrors with fast ones"
echo
sleep 1s
sudo pacman -S pacman-contrib --noconfirm --needed
sleep 1s
echo
echo "Downloading mirrors"
echo
sleep 1s
curl -o "/home/$(logname)/Downloads/mirrorlist" 'https://archlinux.org/mirrorlist/?country=AT&country=BE&country=FR&country=DE&country=IE&country=IT&country=LU&country=NL&country=PT&country=ES&country=CH&country=GB&country=US&protocol=https&ip_version=4'
sleep 1s
echo
echo "Uncomenting \"#Server\" from mirrorlist"
echo
sleep 1s
sed -i "s/#S/S/g" "/home/$(logname)/Downloads/mirrorlist"
sleep 1s
echo
echo "Ranking mirrors, this will take a while"
echo
sleep 1s
rankmirrors "/home/$(logname)/Downloads/mirrorlist" > "/home/$(logname)/Downloads/mirrorlist.fastest"
sleep 1s
echo
echo "Moving them to /etc/pacman.d/mirrorlist"
echo
sleep 1s
sudo mv -v /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
sleep 1s
sudo mv -v "/home/$(logname)/Downloads/mirrorlist.fastest" /etc/pacman.d/mirrorlist

sleep 1s

echo
echo "Update/upgrade our mirrors"
echo
sleep 1s
sudo pacman -Syu --noconfirm --needed

sleep 2s

echo
echo "Grab a coffee and come back later, it'll take some time"
echo

sleep 2s

PKGS=(
    # Tools
    'base-devel'                                # Basic tools
    'rustup'                                    # Rust toolchain
    'meson'                                     # High productivity build system
    'mingw-w64'                                 # MinGW Cross-compiler pack (binutils, crt, gcc, headers and winpthreads)
    'libconfig'                                 # C/C++ Configuration file library
    'gdb'                                       # GNU Debugger
    'lldb'                                      # High performance debugger
    'qemu-guest-agent'                          # Helper Daemon

    # Kernel
    'dkms'                                      # Dynamic Kernel Modules System
    'linux'                                     # Kernel and modules
    'linux-headers'                             # Header files
    'linux-lts'                                 # Kernel and modules (LTS)
    'linux-lts-headers'                         # Header files (LTS)

    # Packet Manager
    'flatpak'                                   # Flatpak

    # Fonts
    'noto-fonts-extra'                          # Additional variants of noto fonts
    'noto-fonts-cjk'                            # Chinese Japanese Korean (CJK) characters support
    'noto-fonts-emoji'                          # Support for emojis
    'ttf-fira-code'                             # My personal favorite font for programming
    'gnu-free-fonts'                            # Free family of scalable outline fonts
    'powerline-fonts'                           # Patched fonts for powerline
    'ttf-ubuntu-font-family'                    # Ubuntu font

    # Shell/Terminal
    'fish'                                      # Shell
    'kitty'                                     # Terminal
    'yakuake'                                   # Dropdown Terminal
    
    # Misc
    'cpupower'                                  # CPU tuning utility
    'vifm'                                      # Filemanager
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo pacman -S "$PKG" --noconfirm --needed
    echo
    sleep 1s
done

sleep 1s

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    echo
    echo "Installing NVidia dkms"
    echo
    sleep 1s
    sudo pacman -S nvidia-dkms --noconfirm --needed
fi

sleep 1s

echo
echo "Setting CPU governor to Performance"
echo
sleep 1s
sudo sed -i "s|#governor=.*|governor='performance'|g" /etc/default/cpupower
sleep 1s
echo
echo "Setting minimum and maximum CPU Frequencies"
echo
sleep 1s
sudo sed -i "s|#min_freq=.*|min_freq=\"3.7GHz\"|g" /etc/default/cpupower
sleep 1s
sudo sed -i "s|#max_freq=.*|max_freq=\"4.2GHz\"|g" /etc/default/cpupower
sleep 1s
echo
echo "Enabling cpupower service"
echo
sleep 1s
sudo systemctl enable cpupower.service

sleep 1s

echo
echo "Set make to be multi-threaded by default"
echo
sleep 1s
sudo sed -i "s|\#MAKEFLAGS=.*|MAKEFLAGS=\"-j$(expr $(nproc) \+ 1)\"|g" /etc/makepkg.conf
sleep 1s
sudo sed -i "s|COMPRESSXZ=.*|COMPRESSXZ=(xz -c -T $(expr $(nproc) \+ 1) -z -)|g" /etc/makepkg.conf

sleep 1s

echo
echo "Increasing file watcher count. This prevents a \"too many files\" error in VS Code(ium)"
echo
sleep 1s
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system

sleep 1s

echo
echo "Installing stable version of Rustup"
echo
sleep 1s
rustup install stable

sleep 1s

echo
echo "Setting stable as our default Rustup toolchain"
echo
sleep 1s
rustup default stable

sleep 1s

echo
echo "Adding i686 architecture support for Rustup"
echo
sleep 1s
rustup target install i686-unknown-linux-gnu

sleep 1s

echo
echo "Setting Cargo to run commands in parallel"
echo
sleep 1s
cargo install async-cmd

sleep 1s

echo
echo "Installing Paru"
echo
sleep 1s
cd ~
git clone https://aur.archlinux.org/paru.git && cd paru
sleep 1s
makepkg -si --noconfirm
sleep 1s
cd ~
sleep 1s
rm -rf paru

sleep 1s

echo
echo "Setting vifm as paru's File Manager"
echo
sleep 1s
sudo sed -i "s|\#\[bin]|[bin]|g" /etc/paru.conf
sleep 1s
sudo sed -i "s|#FileManager|FileManager|g" /etc/paru.conf

sleep 1s

echo
echo "Configuring terminal profiles and setting Fish as default shell"
echo
sleep 1s
touch "/home/$(logname)/.local/share/konsole/$(logname).profile"
sleep 1s
printf "[Appearance]\nColorScheme=Breeze\n\n[General]\nCommand=/bin/fish\nName=$(logname)\nParent=FALLBACK/\n\n[Scrolling]\nHistoryMode=2\nScrollFullPage=1\n\n[Terminal Features]\nBlinkingCursorEnabled=true\n" | tee /home/$(logname)/.local/share/konsole/$(logname).profile

if ! test -e "/home/$(logname)/.config/konsolerc"; then
    touch "/home/$(logname)/.config/konsolerc";
fi

sleep 1s

if grep -qF "DefaultProfile=" "/home/$(logname)/.config/konsolerc"; then
    sed -i "s|DefaultProfile=.*|DefaultProfile=$(logname).profile|g" "/home/$(logname)/.config/konsolerc"
elif ! grep -qF "DefaultProfile=" "/home/$(logname)/.config/konsolerc" && ! grep -qF "[Desktop Entry]" "/home/$(logname)/.config/konsolerc"; then
    sed -i "1 i\[Desktop Entry]\nDefaultProfile=$(logname).profile\n" "/home/$(logname)/.config/konsolerc"
fi

sleep 1s

if pacman -Q | grep 'yakuake'; then
    echo
    echo "Configuring Yakuake"
    echo
    sleep 1s
    if ! test -e "/home/$(logname)/.config/yakuakerc"; then
        touch "/home/$(logname)/.config/yakuakerc";
    fi

    sleep 1s
    
    if grep -qF "DefaultProfile=" "/home/$(logname)/.config/yakuakerc"; then
        sed -i "s|DefaultProfile=.*|DefaultProfile=$(logname).profile|g" "/home/$(logname)/.config/yakuakerc"
    elif ! grep -qF "DefaultProfile=" "/home/$(logname)/.config/yakuakerc" && ! grep -qF "[Desktop Entry]" "/home/$(logname)/.config/yakuakerc"; then
        sed -i "1 i\[Desktop Entry]\nDefaultProfile=$(logname).profile\n" "/home/$(logname)/.config/yakuakerc"
    fi
    
    sleep 1s

    if ! test -e "/home/$(logname)/.config/autostart"; then
        mkdir "/home/$(logname)/.config/autostart"
    fi
    
    if ! test -e "/home/$(logname)/.config/autostart/org.kde.yakuake.desktop"; then
        echo
        echo "Making Yakuake autostart at log-in"
        echo
        sleep 1s
        ln -s /usr/share/applications/org.kde.yakuake.desktop "/home/$(logname)/.config/autostart"
        sleep 1s
    fi
fi

sleep 1s
if [ ${READY,,} = y ]; then
    echo
    echo "Reseting sudo passwod timeout to default"
    echo
    sleep 1s
    sudo sed -i "s|Defaults passwd_timeout=60||g" /etc/sudoers
fi
sleep 1s

echo
echo "Add/Create a new tab/session in the terminal"
echo "Run these commands"
echo "curl -L https://get.oh-my.fish | fish"
echo "omf install bang-bang"
echo
sleep 1s
echo
echo "When you're done. Press any button to continue"
echo
read ANYTHING

sleep 1s
echo
echo "Done..."
echo
sleep 1s
echo
echo "Press Y to reboot now or N if you plan to manually reboot later."
echo
read REBOOT
if [ ${REBOOT,,} = y ]; then
    reboot
fi
exit 0
