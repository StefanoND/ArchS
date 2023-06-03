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
echo "Open a new tab/window and remove snap apps manually"
echo
echo "To remove type \"sudo snap remove APPNAME\""
echo
echo "To check installed snap apps type \"snap list\""
echo
echo "Usually the order is from first to last:"
echo "gnome-x-xx-xxxx, gtk-common-themes, firefox, core20, bare, snapd"
echo
echo "You'll have removed everything when you use \"snap list\" and it shows \"No snaps are installed yet.(...)\""
echo
echo "When you're done, press any key to continue"
echo
read ANYKEYTC
sleep 1s
echo
echo "Uninstalling Snap"
echo
sleep 1s
sudo apt autoremove --purge snapd gnome-software-plugin-snap -y
sleep 1s
echo
echo "Stopping snap to auto-reinstall"
echo
sleep 1s
rm -rf ~/snap
sudo rm -rf /snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd
sudo rm -rf /var/cache/snapd/
sleep 1s
sudo apt-mark hold snapd

sleep 1s

echo
echo "Uninstalling KDE Connect"
echo
sleep 1s
sudo apt autoremove --purge kdeconnect -y
sleep 1s
echo
echo "Stopping kdeconnect to auto-reinstall"
echo
sleep 1s
sudo apt-mark hold kdeconnect

sleep 1s

echo
echo "Updating System"
echo
sleep 1s
sudo apt update -y && sudo apt upgrade -y
sleep 1s

if ! test -e /etc/modprobe.d; then
    echo
    echo "Creating \"/etc/modprobe.d\" folder"
    echo
    sleep 1s
    sudo mkdir -p /etc/modprobe.d
    sleep 1s
fi
if ! test -e /etc/modprobe.d/kvm.conf; then
    echo
    echo "Creating \"/etc/modprobe.d/kvm.conf\" file"
    echo
    sleep 1s
    sudo touch /etc/modprobe.d/kvm.conf
    sleep 1s
fi

GRUB=`cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX_DEFAULT" | rev | cut -c 2- | rev`
sleep 1s
if sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
    #sudo modprobe -r kvm_amd
    sudo rmmod kvm-amd
    sleep 1s
    printf "options kvm ignore_msrs=1\noptions kvm report_ignored_msrs=0\noptions kvm_amd nested=1\n" | sudo tee /etc/modprobe.d/kvm.conf
    sleep 1s
    sudo modprobe kvm-amd
    sleep 1s
    # Adds amd_iommu=on iommu=pt systemd.unified_cgroup_hierarchy=0 to the grub config
    # amd_iommu=on is supposed to be on by default in the kernel, but it doesn't hurt to have it here
    # removed "pcie_acs_override=downstream" for security reasons
    GRUB+=" amd_iommu=on iommu=pt video=efifb:off systemd.unified_cgroup_hierarchy=0\""
    sleep 1s
elif sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
    sudo modprobe -r kvm_intel
    sleep 1s
    printf "options kvm ignore_msrs=1\noptions kvm report_ignored_msrs=0\noptions kvm-intel nested=1\noptions kvm-intel enable_shadow_vmcs=1\noptions kvm-intel enable_apicv=1\noptions kvm-intel ept=1\n" | sudo tee /etc/modprobe.d/kvm.conf
    sleep 1s
    modprobe -r kvm_intel
    sleep 1s
    modprobe -a kvm_intel
    sleep 1s
    # Adds intel_iommu=on iommu=pt systemd.unified_cgroup_hierarchy=0 to the grub config
    # removed "pcie_acs_override=downstream" for security reasons
    GRUB+=" intel_iommu=on iommu=pt video=efifb:off systemd.unified_cgroup_hierarchy=0\""
    sleep 1s
fi
sudo sed -ie "s|^GRUB_CMDLINE_LINUX_DEFAULT.*|${GRUB}|g" /etc/default/grub

sleep 1s

if ! grep "GRUB_TIMEOUT=" /etc/default/grub; then
    sudo tee -a "GRUB_TIMEOUT=5" /etc/default/grub
    sleep 1s
else
    sed -i -e "s|GRUB_TIMEOUT=.*|GRUB_TIMEOUT=5|g" /etc/default/grub
    sleep 1s
fi
if ! grep "GRUB_HIDDEN_TIMEOUT=" /etc/default/grub; then
    sudo tee -a "GRUB_HIDDEN_TIMEOUT=5" /etc/default/grub
    sleep 1s
else
    sed -i -e "s|GRUB_HIDDEN_TIMEOUT=.*|GRUB_HIDDEN_TIMEOUT=5|g" /etc/default/grub
    sleep 1s
fi
if ! grep "GRUB_RECORDFAIL_TIMEOUT=" /etc/default/grub; then
    sudo tee -a "GRUB_RECORDFAIL_TIMEOUT=5" /etc/default/grub
    sleep 1s
else
    sed -i -e "s|GRUB_RECORDFAIL_TIMEOUT=.*|GRUB_RECORDFAIL_TIMEOUT=5|g" /etc/default/grub
    sleep 1s
fi
if ! grep "GRUB_TIMEOUT_STYLE=" /etc/default/grub; then
    sudo tee -a "GRUB_TIMEOUT_STYLE=menu" /etc/default/grub
    sleep 1s
else
    sed -i -e "s|GRUB_TIMEOUT_STYLE=.*|GRUB_TIMEOUT_STYLE=menu|g" /etc/default/grub
    sleep 1s
fi
if ! grep "GRUB_SAVEDEFAULT=" /etc/default/grub; then
    sudo tee -a "GRUB_SAVEDEFAULT=false" /etc/default/grub
    sleep 1s
else
    sed -i -e "s|GRUB_SAVEDEFAULT=.*|GRUB_SAVEDEFAULT=false|g" /etc/default/grub
    sleep 1s
fi

echo
echo "Updating GRUB"
echo
sleep 1s
sudo update-grub
sleep 1s

PKGS=(
    'qemu-kvm'
    'qemu-utils'
    'libvirt-daemon-system'
    'libvirt-clients'
    'bridge-utils'
    'virt-manager'
    'ovmf'
    'netctl'
    'cpuset'
)
        
for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sleep 1s
    sudo apt install "$PKG" -y
    sleep 1s
done

sleep 1s

echo
echo "usermod -aG kvm,libvirt $(logname)"
echo
sleep 1s
sudo usermod -aG kvm,libvirt $(logname)
sleep 1s
echo
echo "Enabling libvirtd"
echo
sudo systemctl enable --now libvirtd
sleep 1s
echo
echo "gpasswd -M $(logname) kvm"
echo
sleep 1s
sudo gpasswd -M $(logname) kvm
echo
echo "gpasswd -M $(logname) libvirt"
echo
sleep 1s
sudo gpasswd -M $(logname) libvirt

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
