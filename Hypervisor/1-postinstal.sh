#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
    exit 1
fi

if ! groups | grep sudo>/dev/null; then
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

sleep 1s

echo
echo 'Adding 32-bit support'
echo
sudo dpkg --add-architecture i386 && sudo apt update
sleep 1s

if lspci -nn | egrep -i "3d|display|vga" | grep -iq 'nvidia'; then
    echo
    echo 'Enabling non-free and non-free-frimware components to sources.list'
    echo
    sudo sed -i 's/main non-free-firmware/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
    sudo sed -i 's/non-free non-free non-free-firmware/non-free non-free-firmware/g' /etc/apt/sources.list
    #sudo bash -c "echo 'deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware' >> /etc/apt/sources.list"
    sleep 1s
fi

echo
echo "Updating System"
echo
sudo apt update -y && sudo apt upgrade -y
sleep 1s

PKGZ=(
    'kdeconnect'
    'firefox'
    'firefox-esr'
)

for PKG in "${PKGZ[@]}"; do
    echo
    echo "UNINSTALLING: ${PKG}"
    echo
    sudo apt autoremove --purge "$PKG" -y
    sleep 1s
done

sudo apt update

PKGS=(
    # Kernel
    "linux-headers-$(uname -r)"
    'build-essential'
    'dkms'
    'firmware-linux'
    'firmware-linux-nonfree'
    'pkg-config'

    # QEMU
    #'qemu-system-x86'
    #'qemu-system'
    'qemu-kvm'
    'qemu-utils'
    'libvirt-daemon-system'
    'libvirt-clients'
    'bridge-utils'
    'virt-manager'
    'ovmf'
    #'libvirt-daemon'
    #'virtinst'
    #'virt-viewer'
    #'vde2'
    #'iptables'
    #'ebtables'
    #'nftables'
    #'swtpm'
    #'dnsmasq'

#    'netctl'
#    'openbsd-netcat'

    # NVidia Driver ()
    'nvidia-driver'
    'firmware-misc-nonfree'
    'nvidia-driver-libs:i386'

    # misc
    'gamemode'
    'flatpak'
    'gnome-software-plugin-flatpak'             # Flathub plugin
    'ntfs-3g'
    'git'
    'curl'
    'wget'
    'linux-cpupower'
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo apt install "$PKG" -y
    sleep 1s
done

echo
echo "Adding flathub repo to flatpak"
echo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sleep 1s

# echo
# echo "Installing NixOS Package Manager"
# echo
# sh <(curl -L https://nixos.org/nix/install) --daemon
# sleep 1s
#
# if ! [[ -d "${HOME}"/.config/nix ]]; then
#     mkdir -p "${HOME}"/.config/nix
# fi
#
# if ! [[ -f "${HOME}"/.config/nix/nix.conf ]]; then
#     touch "${HOME}"/.config/nix/nix.conf
# fi
#
# echo
# echo "Nix PM: Enabling nix-command and flakes"
# echo
# echo 'experimental-features = nix-command flakes' > "${HOME}"/.config/nix/nix.conf
# sleep 1s
#
# if ! [[ -d "${HOME}"/.config/nixpkgs ]]; then
#     mkdir -p "${HOME}"/.config/nixpkgs
# fi
#
# if ! [[ -f "${HOME}"/.config/nixpkgs/config.nix ]]; then
#     touch "${HOME}"/.config/nixpkgs/config.nix
# fi
#
# echo
# echo "Nix PM: Allowing \"Unfree\" packages, enabling sandboxing and enabling auto optimise store"
# echo
# printf "{\n  allowUnfree = true;\n  nix.settings.sandbox = true;\n  nix.settings.auto-optimise-store = true;\n}\n" > "${HOME}"/.config/nixpkgs/config.nix
# sleep 1s

echo
echo "Setting CPU governor to Performance and setting min and max freq"
echo
sudo cpupower frequency-set -d 3.7GHz
sudo cpupower frequency-set -u 4.2GHz
sudo cpupower frequency-set -g performance
sleep 1s
#sudo sed -i "s|#governor=.*|governor='performance'|g" /etc/default/cpupower
#sudo sed -i "s|#min_freq=.*|min_freq=\"3.7GHz\"|g" /etc/default/cpupower
#sudo sed -i "s|#max_freq=.*|max_freq=\"4.2GHz\"|g" /etc/default/cpupower

echo
echo "Enabling cpupower service"
echo
sudo update-rc.d ondemand disable
sudo systemctl disable ondemand
sudo systemctl mask power-profiles-daemon.service
sudo systemctl enable --now cpupower.service
sleep 1s

#sleep 1s

#echo
#echo "Set make to be multi-threaded by default"
#echo
#sudo sed -i "s|MAKEFLAGS=.*|MAKEFLAGS=\"-j$(expr $(nproc) \+ 1)\"|g" /etc/makepkg.conf
#sudo sed -i "s|COMPRESSXZ=.*|COMPRESSXZ=(xz -c -T $(expr $(nproc) \+ 1) -z -)|g" /etc/makepkg.conf

echo
echo "usermod -aG video qemu"
echo
sudo usermod -aG video qemu
sleep 1s

echo
echo "usermod -aG kvm,libvirt,video \"$(logname)\""
echo
sudo usermod -aG kvm,libvirt,video,operator "$(logname)"
sleep 1s

echo
echo "Enabling libvirtd"
echo
sudo systemctl enable --now libvirtd
sleep 1s

echo
echo "gpasswd -M \"$(logname)\" kvm"
echo
sudo gpasswd -M "$(logname)" kvm
sleep 1s

echo
echo "gpasswd -M \"$(logname)\" libvirt"
echo
sudo gpasswd -M "$(logname)" libvirt
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

grubgpu=""

if lspci -nn | egrep -i "3d|display|vga" | grep -iq 'nvidia'; then
    touch /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    sudo bash -c "echo 'blacklist nouveau' > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
    sudo bash -c "echo 'blacklist lbm-nouveau' >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
    sudo bash -c "echo 'options nouveau modeset=0' >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
    sudo bash -c "echo 'alias nouveau off' >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
    sudo bash -c "echo 'alias lbm-nouveau off' >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
    sudo bash -c "echo 'options nouveau modeset=0' > /etc/modprobe.d/nouveau-kms.conf"

    sed -i 's/\#    "\/dev\/nvidiactl", "\/dev\/nvidia0", "\/dev\/nvidia-modeset",/\    "\/dev\/nvidiactl", "\/dev\/nvidia0", "\/dev\/nvidia-modeset",/g' "$cpath"/Config/qemu.conf

    grubgpu=" nouveau.modeset=0 nvidia-drm.modeset=1"
    sleep 1s
elif lspci -nn | egrep -i "3d|display|vga" | grep -iq 'amd'; then
    grubgpu=" amdgpu.aspm=0"
    sleep 1s
fi

sleep 1s
if grep -qF "user=\"USERNAME\"" "$cpath"/Config/qemu.conf; then
    echo
    echo "Adding \"$(logname)\" to qemu.conf's user"
    echo
    sed -i "s|user=\"USERNAME\".*|user=\"$(logname)\"|g" "$cpath"/Config/qemu.conf
    sleep 1s
fi
if grep -qF "group=\"USERNAME\"" "$cpath"/Config/qemu.conf; then
    echo
    echo "Adding \"$(logname)\" to qemu.conf's group"
    echo
    sed -i "s|group=\"USERNAME\".*|group=\"$(logname)\"|g" "$cpath"/Config/qemu.conf
    sleep 1s
fi

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

echo
echo "Restarting libvirt"
echo
sudo systemctl restart libvirtd
sleep 1s

echo
echo "Configuring terminal profiles and setting Bash as default shell"
echo
touch "${HOME}"/.local/share/konsole/"$(logname)".profile
sleep 1s
printf "[Appearance]\nColorScheme=Breeze\n\n[General]\nCommand=/bin/bash\nName=$(logname)\nParent=FALLBACK/\n\n[Scrolling]\nHistoryMode=2\nScrollFullPage=1\n\n[Terminal Features]\nBlinkingCursorEnabled=true\n" | tee "${HOME}"/.local/share/konsole/"$(logname)".profile

if ! [[ -f "${HOME}"/.config/konsolerc ]]; then
    touch "${HOME}"/.config/konsolerc;
fi

sleep 1s

if grep -qF "DefaultProfile=" "${HOME}"/.config/konsolerc; then
    sed -i "s|DefaultProfile=.*|DefaultProfile=$(logname).profile|g" "${HOME}"/.config/konsolerc
elif ! grep -qF "DefaultProfile=" "${HOME}"/.config/konsolerc && ! grep -qF "[Desktop Entry]" "${HOME}"/.config/konsolerc; then
    sed -i "1 i\[Desktop Entry]\nDefaultProfile=$(logname).profile\n" "${HOME}"/.config/konsolerc
fi

sleep 1s

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
echo "Making Gamemode start on boot"
echo
systemctl --user enable --now gamemoded.service
sudo chmod +x /bin/gamemoded
sudo chmod +x /usr/bin/gamemoded
sleep 1s

if ! [[ -d /etc/X11/xorg.conf.d ]]; then
    sudo mkdir -p /etc/X11/xorg.conf.d
fi

if ! [[ -f /etc/X11/xorg.conf.d/50-mouse-acceleration.conf ]]; then
    sudo touch /etc/X11/xorg.conf.d/50-mouse-acceleration.conf
fi

printf "Section \"InputClass\"\n    Identifier \"My Mouse\"\n    Driver \"libinput\"\n    MatchIsPointer \"yes\"\n    Option \"AccelProfile\" \"-1\"\n    Option \"AccelerationScheme\" \"none\"\n    Option \"AccelSpeed\" \"-1\"\nEndSection" | sudo tee /etc/X11/xorg.conf.d/50-mouse-acceleration.conf
sleep 1s

GRUB=`cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX_DEFAULT" | rev | cut -c 2- | rev`

if sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
    GRUB+=" amd_iommu=on iommu=pt kvm_amd.npt=1 kvm_amd.avic=1 kvm_amd.nested=1 kvm_amd.sev=1 kvm.ignore_msrs=1 kvm.report_ignored_msrs=0 video=vesafb:off,efifb:off,simplefb:off$grubgpu systemd.unified_cgroup_hierarchy=0\""
    sleep 1s
elif sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
    GRUB+=" intel_iommu=on iommu=pt kvm.ignore_msrs=1 kvm.report_ignored_msrs=0 video=vesafb:off,efifb:off,simplefb:off$grubgpu systemd.unified_cgroup_hierarchy=0\""
    sleep 1s
fi

sudo sed -ie "s|^GRUB_CMDLINE_LINUX_DEFAULT.*|${GRUB}|g" /etc/default/grub
sleep 1s

if ! grep "GRUB_TIMEOUT=" /etc/default/grub; then
    printf "GRUB_TIMEOUT=2\n" | sudo tee -a /etc/default/grub
    sleep 1s
else
    sudo sed -i "s|GRUB_TIMEOUT=.*|GRUB_TIMEOUT=2|g" /etc/default/grub
    sleep 1s
fi

if ! grep "GRUB_HIDDEN_TIMEOUT=" /etc/default/grub; then
    printf "GRUB_HIDDEN_TIMEOUT=2\n" | sudo tee -a /etc/default/grub
    sleep 1s
else
    sudo sed -i "s|GRUB_HIDDEN_TIMEOUT=.*|GRUB_HIDDEN_TIMEOUT=2|g" /etc/default/grub
    sleep 1s
fi

if ! grep "GRUB_RECORDFAIL_TIMEOUT=" /etc/default/grub; then
    printf "GRUB_RECORDFAIL_TIMEOUT=2\n" | sudo tee -a /etc/default/grub
    sleep 1s
else
    sudo sed -i "s|GRUB_RECORDFAIL_TIMEOUT=.*|GRUB_RECORDFAIL_TIMEOUT=2|g" /etc/default/grub
    sleep 1s
fi

if ! grep "GRUB_TIMEOUT_STYLE=" /etc/default/grub; then
    printf "GRUB_TIMEOUT_STYLE=menu\n" | sudo tee -a /etc/default/grub
    sleep 1s
else
    sudo sed -i "s|GRUB_TIMEOUT_STYLE=.*|GRUB_TIMEOUT_STYLE=menu|g" /etc/default/grub
    sleep 1s
fi

if ! grep "GRUB_SAVEDEFAULT=" /etc/default/grub; then
    printf "GRUB_SAVEDEFAULT=false\n" | sudo tee -a /etc/default/grub
    sleep 1s
else
    sudo sed -i "s|GRUB_SAVEDEFAULT=.*|GRUB_SAVEDEFAULT=false|g" /etc/default/grub
    sleep 1s
fi

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

sleep 1s
if sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
    if ! [[ -f /etc/modprobe.d/kvm.conf ]]; then
        sudo touch /etc/modprobe.d/kvm.conf
        sleep 1s
    fi

    printf "options kvm-amd nested=1\noptions kvm ignore_msrs=1\noptions kvm report_ignored_msrs=0\n" | sudo tee /etc/modprobe.d/kvm.conf
    sudo modprobe -r kvm_amd
    sudo modprobe kvm_amd
    sleep 1s
elif sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
    if ! [[ -f /etc/modprobe.d/kvm.conf ]]; then
        sudo touch /etc/modprobe.d/kvm.conf
        sleep 1s
    fi

    printf "options kvm-intel nested=1\noptions kvm ignore_msrs=1\noptions kvm report_ignored_msrs=0\noptions kvm-intel enable_shadow_vmcs=1\noptions kvm-intel enable_apicv=1\noptions kvm-intel ept=1\n" | sudo tee /etc/modprobe.d/kvm.conf
    sudo modprobe -r kvm_intel
    sudo modprobe kvm_intel
    sleep 1s
fi

sudo modprobe iommufd
sudo modprobe vfio_iommu_type1
sudo modprobe vfio_virqfd
sudo modprobe vfio-pci

echo
echo "Updating initramfs"
echo
sudo update-initramfs -u
sleep 1s

echo
echo "Updating GRUB"
echo
sudo grub-mkconfig -o /boot/grub/grub.cfg
sleep 1s

echo
echo "Done..."
echo
echo "Press Y to reboot now or N if you plan to manually reboot later."
echo
read REBOOT
if [ ${REBOOT,,} = y ]; then
    systemctl reboot
fi
exit 0
