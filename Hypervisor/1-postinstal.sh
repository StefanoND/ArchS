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

sleep 1s

sudo dnf autoremove kdeconnectd -y

sleep 1s

sudo dnf upgrade -y

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
