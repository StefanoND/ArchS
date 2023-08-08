#!/bin/bash

# To check for available keymaps use the command below
# localectl list-x11-keymap-layouts

KBLOCALE="pt"
VALIDPARTTWO=n
VALIDPARTTHREE=n
nvme0n1p2=null
nvme0n1p3=null

APPSPATH="${HOME}/.apps"
SRCPATH="$(cd $(dirname $0) && pwd)"

if ! [[ -f "${APPSPATH}" ]]; then
    echo
    printf "Creating ${APPSPATH} path"
    echo
    mkdir -p "${APPSPATH}"
    sleep 1s
fi

echo
echo 'Enabling Chaotic AUR'
echo
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sleep 1s

sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
sleep 1s

sudo bash -c "echo '' >> /etc/pacman.conf"
sudo bash -c "echo '[chaotic-aur]' >> /etc/pacman.conf"
sudo bash -c "echo 'Include = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf"
sudo bash -c "echo '' >> /etc/pacman.conf"
sleep 1s

echo
echo 'Enabling Valve AUR'
echo
sudo bash -c "echo '[valveaur]' >> /etc/pacman.conf"
sudo bash -c "echo 'SigLevel = Optional TrustedOnly' >> /etc/pacman.conf"
sudo bash -c "echo 'Server = http://repo.steampowered.com/arch/valveaur' >> /etc/pacman.conf"
sudo bash -c "echo '' >> /etc/pacman.conf"
sleep 1s

sudo pacman -Syy

if [[ `pacman -Q | grep -i 'iptables'` ]] && \
 ! [[ `pacman -Q | grep -i 'iptables-nft'` ]]; then
    echo
    echo
    echo
    echo 'Replacing iptables with iptables-nft'
    echo 'Press Y when it asks to remove iptables'
    echo
    sudo pacman -S iptables-nft --needed
    sleep 1s
elif ! [[ `pacman -Q | grep -i 'iptables'` ]] && \
 ! [[ `pacman -Q | grep -i 'iptables-nft'` ]]; then
    echo
    echo
    echo
    echo 'Installing iptables-nft'
    echo
    sudo pacman -S iptables-nft --noconfirm --needed
    sleep 1s
fi

echo
echo "Installing meson as dependency"
echo
sudo pacman -S meson --asdep --noconfirm --needed
sleep 1s


PKGS=(
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
    'flatpak'
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
echo "Adding flathub"
echo
flatpak remote-add flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
sleep 1s

echo
echo "Config Ranger"
echo
ranger --copy-config=all
export RANGER_LOAD_DEFAULT_RC=false
printf "RANGER_LOAD_DEFAULT_RC=false\n" | sudo tee -a /etc/environment
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

echo
echo 'Setting locale'
echo
# Set your keyboard layout on X11
localectl set-x11-keymap $KBLOCALE

# Turn on swap
sudo swapon /swap/swapfile
sleep 1s

lsblk
while [[ ${VALIDPARTTWO,,} = n ]]; do
    read -p "Enter the name of the ROOT partition (eg. sda2, nvme0n1p2): " PARTTWO
    nvme0n1p2=$PARTTWO
    if [[ `lsblk | grep -w $nvme0n1p2` ]]; then
        VALIDPARTTWO=y
    else
        echo
        printf "Could not find /dev/$nvme0n1p2, try again"
        echo
    fi
done
while [[ ${VALIDPARTTHREE,,} = n ]]; do
    read -p "Enter the name of the HOME partition (eg. sda3, nvme0n1p3): " PARTTHREE
    nvme0n1p3=$PARTTHREE
    if [[ `lsblk | grep -w $nvme0n1p3` ]]; then
        VALIDPARTTHREE=y
    else
        echo
        printf "Could not find /dev/$nvme0n1p3, try again"
        echo
    fi
done

echo
echo "Enabling btrfs's automatic balance at 10% threshold"
echo
sudo bash -c "echo 10 > /sys/fs/btrfs/$(blkid -s UUID -o value /dev/$nvme0n1p2)/allocation/data/bg_reclaim_threshold"
sleep 1s
sudo bash -c "echo 10 > /sys/fs/btrfs/$(blkid -s UUID -o value /dev/$nvme0n1p3)/allocation/data/bg_reclaim_threshold"
sleep 1s

echo
echo 'Syncing system'
echo
sync
sleep 1s

echo
echo "Done..."
echo
echo "Press Y to reboot now or N if you plan to manually reboot later."
echo
read REBOOT
if [ ${REBOOT,,} = y ]; then
    shutdown -r now
fi
exit 0
