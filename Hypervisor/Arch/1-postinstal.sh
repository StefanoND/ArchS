#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
    exit 1
fi

if ! groups | grep sudo>/dev/null && ! groups | grep wheel>/dev/null; then
    echo
    echo "You need to be a member of the sudo group to run this script!"
    echo
    echo
    echo "To add yourself to sudoers group, open a new tab and follow the guide below"
    echo
    echo "# Login to root session"
    echo "su -"
    echo
    echo "# Install sudo"
    echo "apt install sudo -y"
    echo
    echo "# Add yourself to sudoers group, change USERNAME to yours"
    echo "usermod -aG sudo USERNAME"
    echo
    echo "# Run visudo"
    echo "visudo"
    echo
    echo "Add these in visudo"
    echo "Defaults rootpw" # Will require root password for sudo command
    echo "Defaults timestamp_type=global" # All terminals "share the same timeout" for sudo password
    echo "Defaults passwd_timeout=0"
    echo
    echo "# Exit root session"
    echo "exit"
    echo
    echo "Reboot and run this script again"
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

nvme0n1p2=0
correctblk=0

lsblk
while [[ ${correctblk,,} == 0 ]]; do
    echo
    echo "What's your root revice?"
    echo
    read BLKUID
    nvme0n1p2=$BLKUID
    if `lsblk | grep -q $nvme0n1p2`; then
        correctblk=1
    else
        echo
        echo "The device '/dev/$nvme0n1p2' doesn't exist"
        echo
    fi
done

APPSPATH="${HOME}/.apps"

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

echo
echo "Enabling Color and ILoveCandy"
echo
sudo sed -i "s|#Color.*|Color\nILoveCandy|g" /etc/pacman.conf
sleep 1s

echo
echo "Updating System"
echo
sudo pacman -Syu --noconfirm --needed
sleep 1s

sudo pacman -S --asdeps swtpm --noconfirm --needed
sleep 1s

PKGS=(
    # Tools
    'base-devel'                                # Basic tools to build Arch Linux packages
    'rustup'                                    # Rust toolchain

    # Kernel
    'linux-lts'
    'linux-lts-headers'
    'linux-xanmod-lts'
    'linux-xanmod-lts-headers'
    'dkms'                                      # Dynamic Kernel Modules System
    'nvidia-dkms'                               # NVidia Module

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

    # misc
    'flatpak'
    'ntfs-3g'
    'git'
    'curl'
    'neovim'
    'ranger'
    'cpupower'
    'tuned'
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo pacman -S "$PKG" --noconfirm --needed
    sleep 1s
done

sudo bash -c 'printf "default arch-xanmod-lts.conf\ntimeout 2\nconsole-mode max\n" > /boot/loader/loader.conf'
sudo bash -c 'printf "title Arch (Xanmod RT)\nlinux /vmlinuz-linux-xanmod-lts\ninitrd /initramfs-linux-xanmod-lts.img\n" > /boot/loader/entries/arch-xanmod-lts.conf'
sudo bash -c "printf 'options root=UUID=$(blkid -s UUID -o value /dev/$nvme0n1p2) zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs\n' >> /boot/loader/entries/arch-xanmod-lts.conf"
sleep 1s

echo
echo "Adding flathub"
echo
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sleep 1s

echo
echo "Setting CPU governor to Performance and setting min and max freq"
echo
sudo cpupower frequency-set -d 3.7GHz
sudo cpupower frequency-set -u 4.2GHz
sudo cpupower frequency-set -g performance
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
echo "Enabling tuned"
echo
sudo systemctl enable --now tuned.service
sleep 1s
sudo tuned-adm profile virtual-host
sleep 1s

echo
printf "Linking /usr/share/fonts to $HOME/.fonts"
echo
ln -svf /usr/share/fonts $HOME/.fonts

if ! [[ -d /etc/modprobe.d ]]; then
    sudo mkdir -p /etc/modprobe.d
fi

echo
echo "Making bash completion ignore (Upper/Lower)Cases"
echo
echo '$include /etc/inputrc' >> "${HOME}"/.inputrc
echo 'set completion-ignore-case On' >> "${HOME}"/.inputrc
echo '' >> "${HOME}"/.inputrc
sleep 1s

echo
echo "Set make to be multi-threaded by default"
echo
sudo sed -i "s|MAKEFLAGS=.*|MAKEFLAGS=\"-j$(expr $(nproc) \+ 1)\"|g" /etc/makepkg.conf
sudo sed -i "s|COMPRESSXZ=.*|COMPRESSXZ=(xz -c -T $(expr $(nproc) \+ 1) -z -)|g" /etc/makepkg.conf
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

echo
echo "Addidng i686 architecture support for Rustup"
echo
rustup target install i686-unknown-linux-gnu

echo
echo "Setting stable as our default Rustup toolchain"
echo
rustup default stable

echo
echo "Setting Cargo to run commands in parallel"
echo
cargo install async-cmd

sleep 1s

echo
echo "Installing Paru"
echo
cd "${APPSPATH}" && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg --noconfirm --needed -si
cd ~
sleep 1s

echo
echo "Setting ranger as paru's File Manager"
echo
sudo sed -i "s|\#\[bin]|[bin]|g" /etc/paru.conf
sleep 1s
sudo sed -i "s|#FileManager.*|FileManager = ranger|g" /etc/paru.conf
sleep 1s

echo
echo "usermod -aG video qemu"
echo
sudo usermod -aG video qemu
sleep 1s

echo
echo "usermod -aG kvm,libvirt,video \"$(logname)\""
echo
sudo usermod -aG kvm,libvirt,video "$(logname)"
sleep 1s

echo
echo "Enabling libvirtd"
echo
sudo systemctl enable --now libvirtd
sleep 1s

echo
echo "gpasswd -M $(logname) kvm"
echo
sudo gpasswd -M $(logname) kvm
sleep 1s
echo
echo "gpasswd -M $(logname) libvirt"
echo
sudo gpasswd -M $(logname) libvirt
sleep 1s

echo
echo "Enabling VIRSH internal network automatically at boot"
echo
sudo virsh net-autostart default
sleep 1s

if ! [[ -d "${HOME}"/.config/autostart ]]; then
    mkdir -p "${HOME}"/.config/autostart
    sleep 1s
fi

if ! [[ -f "${HOME}"/.config/autostart/virt-manager.desktop ]]; then
    echo
    echo "Making Virt-manager autostart at log-in"
    echo
    ln -s /usr/share/applications/virt-manager.desktop "${HOME}"/.config/autostart
    sleep 1s
fi

cpath=`pwd`

echo
echo "Backing up \"/etc/libvirt/libvirtd.conf\" to \"/etc/libvirt/libvirtd.conf.old\""
echo
sudo mv /etc/libvirt/libvirtd.conf /etc/libvirt/libvirtd.conf.old
sleep 1s
echo
echo "Copying \""$cpath"/Config/libvirtd.conf\" to \"/etc/libvirt\""
echo
sudo cp "$cpath"/Config/libvirtd.conf /etc/libvirt
sleep 1s
echo
echo "Backing up \"/etc/libvirt/qemu.conf\" to \"/etc/libvirt/qemu.conf.old\""
echo
sudo mv /etc/libvirt/qemu.conf /etc/libvirt/qemu.conf.old
sleep 1s
echo
echo "Copying \""$cpath"/Config/qemu.conf\" to \"/etc/libvirt\""
echo
sudo cp "$cpath"/Config/qemu.conf /etc/libvirt
sleep 1s

if grep -qF "user=\"USERNAME\"" /etc/libvirt/qemu.conf; then
    echo
    echo "Adding \"$(logname)\" to qemu.conf's user"
    echo
    sudo sed -i "s|user=\"USERNAME\".*|user=\"$(logname)\"|g" /etc/libvirt/qemu.conf
    sleep 1s
fi

grubgpu=""
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    sudo bash -c "echo 'blacklist nouveau' > /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo 'blacklist lbm-nouveau' >> /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo 'options nouveau modeset=0' >> /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo 'alias nouveau off' >> /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo 'alias lbm-nouveau off' >> /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo '' >> /etc/modprobe.d/blacklist-nvidia-nouveau-conf"
    sudo bash -c "echo 'options nouveau modeset=0' > /etc/modprobe.d/nouveau-kms.conf"

    sudo sed -i 's/\#    "\/dev\/nvidiactl", "\/dev\/nvidia0", "\/dev\/nvidia-modeset",/\    "\/dev\/nvidiactl", "\/dev\/nvidia0", "\/dev\/nvidia-modeset",/g' /etc/libvirt/qemu.conf

    grubgpu=" nouveau.modeset=0 nvidia-drm.modeset=1"
    sleep 1s
elif lspci -nn | egrep -i "3d|display|vga" | grep -iq 'amd'; then
    grubgpu=" amdgpu.aspm=0"
    sleep 1s
fi

echo
echo "Restarting libvirt"
echo
sudo systemctl restart libvirtd

echo
echo "Configuring terminal profiles"
echo
touch "$HOME/.local/share/konsole/$(logname).profile"
sleep 1s
printf "[Appearance]\nColorScheme=Breeze\n\n[General]\nCommand=/bin/bash\nName=$(logname)\nParent=FALLBACK/\n\n[Scrolling]\nHistoryMode=2\nScrollFullPage=1\n\n[Terminal Features]\nBlinkingCursorEnabled=true\n" | tee $HOME/.local/share/konsole/$(logname).profile

if ! [[ -f "${HOME}"/.config/konsolerc ]]; then
    touch "${HOME}"/.config/konsolerc;
    sleep 1s
fi

if grep -qF "DefaultProfile=" "${HOME}"/.config/konsolerc; then
    sed -i "s|DefaultProfile=.*|DefaultProfile=$(logname).profile|g" "${HOME}"/.config/konsolerc
    sleep 1s
elif ! grep -qF "DefaultProfile=" "${HOME}"/.config/konsolerc && ! grep -qF "[Desktop Entry]" "${HOME}"/.config/konsolerc; then
    sed -i "1 i\[Desktop Entry]\nDefaultProfile=$(logname).profile\n" "${HOME}"/.config/konsolerc
    sleep 1s
fi

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
echo "Setting MinimumVT to 7"
echo
sudo sed -i "s|MinimumVT=.*|MinimumVT=7|g" /usr/lib/sddm/sddm.conf.d/default.conf
sleep 1s

echo
echo "Restricting Kernel Log Access"
echo
sudo sysctl -w kernel.dmesg_restrict=1
sleep 1s

#GRUB=`cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX_DEFAULT" | rev | cut -c 2- | rev`

#if sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
#    GRUB+=" amd_iommu=on iommu=pt kvm_amd.npt=1 kvm_amd.avic=1 kvm_amd.nested=1 kvm_amd.sev=1 kvm.ignore_msrs=1 kvm.report_ignored_msrs=0 video=vesafb:off,efifb:off,simplefb:off$grubgpu systemd.unified_cgroup_hierarchy=0\""
#    sleep 1s
#elif sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
#    GRUB+=" intel_iommu=on iommu=pt kvm.ignore_msrs=1 kvm.report_ignored_msrs=0 video=vesafb:off,efifb:off,simplefb:off$grubgpu systemd.unified_cgroup_hierarchy=0\""
#    sleep 1s
#fi

#sudo sed -ie "s|^GRUB_CMDLINE_LINUX_DEFAULT.*|${GRUB}|g" /etc/default/grub
#sleep 1s

sudo cp /boot/loader/entries/linux-xanmod-lts.conf /boot/loader/entries/linux-xanmod-lts.conf.old

BOOTENTRY=`cat /boot/loader/entries/linux-xanmod-lts.conf | grep "options root" | rev | cut -c 1- | rev`
sleep 1s

if sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
    BOOTENTRY+=" amd_iommu=on iommu=pt kvm_amd.npt=1 kvm_amd.avic=1 kvm_amd.nested=1 kvm_amd.sev=1 kvm.ignore_msrs=1 kvm.report_ignored_msrs=0 video=vesafb:off,efifb:off,simplefb:off$grubgpu systemd.unified_cgroup_hierarchy=0"
    sleep 1s
elif sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
    BOOTENTRY+=" intel_iommu=on iommu=pt kvm.ignore_msrs=1 kvm.report_ignored_msrs=0 video=vesafb:off,efifb:off,simplefb:off$grubgpu systemd.unified_cgroup_hierarchy=0"
    sleep 1s
fi

sudo sed -ie "s|^options root.*|${BOOTENTRY}|g" /boot/loader/entries/linux-xanmod-lts.conf
sleep 1s

echo
echo "Enabling nested kvm"
echo

if ! [[ -d /etc/modprobe.d ]]; then
    echo
    echo "Creating \"/etc/modprobe.d\" folder"
    echo
    sudo mkdir -p /etc/modprobe.d
    sleep 1s
fi

if sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
    if ! [[ -f /etc/modprobe.d/kvm.conf ]]; then
        sudo touch /etc/modprobe.d/kvm.conf
        sleep 1s
    fi

    printf "options kvm-amd nested=1\noptions kvm ignore_msrs=1\noptions kvm report_ignored_msrs=0\n" | sudo tee /etc/modprobe.d/kvm.conf
    sudo modprobe -r kvm-amd
    sudo modprobe kvm-amd
    sleep 1s
elif sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
    if ! [[ -f /etc/modprobe.d/kvm.conf ]]; then
        sudo touch /etc/modprobe.d/kvm.conf
        sleep 1s
    fi

    printf "options kvm-intel nested=1\noptions kvm ignore_msrs=1\noptions kvm report_ignored_msrs=0\noptions kvm-intel enable_shadow_vmcs=1\noptions kvm-intel enable_apicv=1\noptions kvm-intel ept=1\n" | sudo tee /etc/modprobe.d/kvm.conf
    sudo modprobe -r kvm-intel
    sudo modprobe kvm-intel
    sleep 1s
fi

sudo modprobe vfio
sudo modprobe vfio-pci
sudo modprobe vfio-virqfd
sudo modprobe iommu_v2
sleep 1s

sudo bash -c "echo 'blacklist iTCO_wdt' > /etc/modprobe.d/nowatchdog.conf"
sudo bash -c "sudo echo 'net.ipv4.conf.all.arp_filter = 1' > /etc/sysctl.d/30-arpflux.conf"
sleep 1s

echo
echo 'Updatin initramfs'
echo
sudo mkinitcpio -P
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
