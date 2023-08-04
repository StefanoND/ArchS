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

PKGS=(

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
echo "usermod -a -G kvm,libvirt $(logname)"
echo
sudo usermod -a -G kvm,libvirt $(logname)
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

if ! test -e "$HOME/.config/autostart/virt-manager.desktop"; then
    echo
    echo "Making Virt-manager autostart at log-in"
    echo
    ln -s /usr/share/applications/virt-manager.desktop "$HOME/.config/autostart"
    sleep 1s
fi

cpath=`pwd`

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
echo "Enabling nested kvm"
echo
if ! test -e /etc/modprobe.d; then
    echo
    echo "Creating \"/etc/modprobe.d\" folder"
    echo
    sudo mkdir -p /etc/modprobe.d
    sleep 1s
fi

sleep 1s
if sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
    if ! test -e /etc/modprobe.d/kvm-amd.conf; then
        sudo touch /etc/modprobe.d/kvm-amd.conf
    sleep 1s
    fi
    printf "options kvm ignore_msrs=1\noptions kvm report_ignored_msrs=0\noptions kvm-amd nested=1\n" | sudo tee /etc/modprobe.d/kvm-amd.conf
    sleep 1s
    sudo modprobe -r kvm_amd
    sleep 1s
    sudo modprobe kvm_amd
    sleep 1s
elif sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
    if ! test -e /etc/modprobe.d/kvm-intel.conf; then
        sudo touch /etc/modprobe.d/kvm-intel.conf
    sleep 1s
    fi
    printf "options kvm ignore_msrs=1\noptions kvm report_ignored_msrs=0\noptions kvm-intel nested=1\noptions kvm-intel enable_shadow_vmcs=1\noptions kvm-intel enable_apicv=1\noptions kvm-intel ept=1\n" | sudo tee /etc/modprobe.d/kvm-intel.conf
    sleep 1s
    sudo modprobe -r kvm_intel
    sleep 1s
    sudo modprobe kvm_intel
    sleep 1s
fi

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
