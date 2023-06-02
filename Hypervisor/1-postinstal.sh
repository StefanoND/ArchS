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

echo
echo "Uninstalling KDE Connect"
echo
sleep 1s
sudo dnf autoremove kdeconnectd -y
sleep 1s
echo
echo "Updating System"
echo
sleep 1s
sudo dnf upgrade -y
sleep 1s

echo
echo "Making changes to GRUB"
echo
sleep 1s

GRUB=`cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX" | rev | cut -c 2- | rev`
sleep 1s
if sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
    sudo modprobe -r kvm_amd
    sleep 1s
    # Adds amd_iommu=on iommu=pt systemd.unified_cgroup_hierarchy=0 to the grub config
    # amd_iommu=on is supposed to be on by default in the kernel, but it doesn't hurt to have it here
    # removed "pcie_acs_override=downstream" for security reasons
    GRUB+=" amd_iommu=on iommu=pt video=efifb:off systemd.unified_cgroup_hierarchy=0\""
    sleep 1s
elif sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
    sudo modprobe -r kvm_intel
    sleep 1s
    # Adds intel_iommu=on iommu=pt systemd.unified_cgroup_hierarchy=0 to the grub config
    # removed "pcie_acs_override=downstream" for security reasons
    GRUB+=" intel_iommu=on iommu=pt video=efifb:off systemd.unified_cgroup_hierarchy=0\""
    sleep 1s
fi
sudo sed -i "s|^GRUB_CMDLINE_LINUX.*|${GRUB}|" /etc/default/grub

sleep 1s

echo
echo "Updating GRUB"
echo
sleep 1s
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sleep 1s
    
if ! test -e /etc/modprobe.d; then
    sudo mkdir -p /etc/modprobe.d
    sleep 1s
fi
if ! test -e /etc/modprobe.d/kvm.conf; then
    sudo touch /etc/modprobe.d/kvm.conf
    sleep 1s
    printf "options kvm ignore_msrs=1\noptions kvm report_ignored_msrs=0\noptions kvm_amd nested=1\n" | sudo tee /etc/modprobe.d/kvm.conf
    sleep 1s
elif test -e /etc/modprobe.d/kvm.conf; then
    if grep -q -F "options kvm ignore_msrs=" /etc/modprobe.d/kvm.conf; then
        sudo sed -i "s|options kvm ignore_msrs=.*|options kvm ignore_msrs=1|g" /etc/modprobe.d/kvm.conf
        sleep 1s
    fi
    if grep -q -F "options kvm report_ignored_msrs=" /etc/modprobe.d/kvm.conf; then
        sudo sed -i "s|options kvm report_ignored_msrs=.*|options kvm report_ignored_msrs=0|g" /etc/modprobe.d/kvm.conf
        sleep 1s
    fi
    if grep -qF "options kvm_intel nested=" /etc/modprobe.d/kvm.conf; then
        sudo sed -i "s|options kvm_intel nested=.*|options kvm_intel nested=1|g" /etc/modprobe.d/kvm.conf
        sleep 1s
    fi
fi


sleep 1s

PKGS=(
    'libvirt-daemon-kvm'
    'libvirt-client-qemu'
    'qemu-kvm'
    'virt-manager'
    'edk2-ovmf'
    #'dnsmasq-utils'
    #'nftables'
    #'bridge-utils'
    #'iptables-nft-services'
)
        
for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sleep 1s
    sudo dnf install "$PKG" -y
    sleep 1s
done

sleep 1s
        
sudo usermod -aG kvm,libvirt $(logname)
echo "usermod -aG kvm,libvirt $(logname)"
sudo systemctl enable --now libvirtd
sleep 1s
echo "Adding $(logname) to kvm and libvirt groups..."
sudo gpasswd -M $(logname) kvm
echo "gpasswd -M $(logname) kvm"
sudo gpasswd -M $(logname) libvirt
echo "gpasswd -M $(logname) libvirt"

echo
echo "Configuration complete"
echo
sleep 1s
echo
echo "Press Y to start VIRSH internal network automatically at boot (Recommended)"
echo
read AUTOSTART
if [ ${AUTOSTART,,} = y ]; then
    echo
    echo "Enabling VIRSH internal network automatically at boot"
    echo
    sleep 1s
    sudo virsh net-autostart default
fi

cpath=`pwd`

sleep 1s
if grep -qF "user=\"USERNAME\"" "$cpath"/Config/qemu.conf; then
    echo
    echo "Adding \"$(logname)\" to qemu.conf's user"
    echo
    sleep 1s
    sed -i "s|user=\"USERNAME\".*|user=\"$(logname)\"|g" "$cpath"/Config/qemu.conf
    sleep 1s
fi
if grep -qF "group=\"USERNAME\"" "$cpath"/Config/qemu.conf; then
    echo
    echo "Adding \"$(logname)\" to qemu.conf's group"
    echo
    sleep 1s
    sed -i "s|group=\"USERNAME\".*|group=\"$(logname)\"|g" "$cpath"/Config/qemu.conf
    sleep 1s
fi

echo
echo "Backing up \"/etc/libvirt/libvirtd.conf\" to \"/etc/libvirt/libvirtd.conf.old\""
echo
sleep 1s
sudo mv /etc/libvirt/libvirtd.conf /etc/libvirt/libvirtd.conf.old
sleep 1s
echo
echo "Copying \""$cpath"/Config/libvirtd.conf\" to \"/etc/libvirt\""
echo
sleep 1s
sudo cp "$cpath"/Config/libvirtd.conf /etc/libvirt
sleep 1s
echo
echo "Backing up \"/etc/libvirt/qemu.conf\" to \"/etc/libvirt/qemu.conf.old\""
echo
sleep 1s
sudo mv /etc/libvirt/qemu.conf /etc/libvirt/qemu.conf.old
sleep 1s
echo
echo "Copying \""$cpath"/Config/qemu.conf\" to \"/etc/libvirt\""
echo
sleep 1s
sudo cp "$cpath"/Config/qemu.conf /etc/libvirt
sleep 1s
echo
echo "Restarting libvirt"
echo
sleep 1s
sudo systemctl restart libvirtd

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
