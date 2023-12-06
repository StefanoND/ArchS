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

ramkib=0
ramgib=0
ramcalc=0
confirmram=n

while [[ ${confirmram,,} = n ]]; do
    echo
    echo "How many GB you're giving your VM? Numbers only"
    echo "You should leave at least 4GB for your Host VM"
    echo
    read VMRAM
    ramcalc=$VMRAM
    echo
    echo
    echo "Is \"$ramcalc\" GB right? Y - Yes | Anything else - no"
    echo
    read RAMCONF
    if [[ ${RAMCONF,,} = y ]]; then
        confirmram=$RAMCONF
        ramkib=`expr $ramcalc \* 1024 \* 1024`
        ramgib=`expr $ramcalc \* 1024 \* 1024 \/ 2048`
    fi
done

if ! [[ -d /hugepages ]]; then
    echo "mkdir -p /hugepages"
    sudo mkdir -p /hugepages
    sleep 1s
fi

echo "mount -t hugetlbfs hugetlbfs /hugepages"
sudo mount -t hugetlbfs hugetlbfs /hugepages
sleep 1s

if grep -iq "hugetlbfs" /etc/fstab; then
    sudo sed -i "s|.*hugetlbfs.*|hugetlbfs    /hugepages    hugetlbfs    defaults    0 0|g" /etc/fstab
    sleep 1s
else
    printf "hugetlbfs    /hugepages    hugetlbfs    defaults    0 0\n" | sudo tee -a /etc/fstab
    sleep 1s
fi

if ! grep -i "$(logname)" /etc/security/limits.conf; then
    printf "\n$(logname)        hard    nofile          $ramkib\n" | sudo tee -a /etc/security/limits.conf
    sleep 1s
    printf "\n$(logname)        soft    nofile          $ramkib\n" | sudo tee -a /etc/security/limits.conf
    sleep 1s
fi

sudo sed -i "s|.*DefaultLimitNOFILE=.*|DefaultLimitNOFILE=$ramkib|g" /etc/systemd/system.conf
sudo sed -i "s|.*DefaultLimitNOFILE=.*|DefaultLimitNOFILE=$ramkib|g" /etc/systemd/user.conf

if ! [[ -f /etc/sysctl.d/10-kvm.conf ]]; then
    sudo touch /etc/sysctl.d/10-kvm.conf
    sleep 1s
fi

if grep -i "vm.nr_hugepages" /etc/sysctl.d/10-kvm.conf; then
    sudo sed -i "s|.*vm.nr_hugepages.*|vm.nr_hugepages = $ramgib|g" /etc/sysctl.d/10-kvm.conf
    sleep 1s
else
    printf "\nvm.nr_hugepages = $ramgib\n" | sudo tee -a /etc/sysctl.d/10-kvm.conf
    sleep 1s
fi

if grep -i "vm.hugetlb_shm_group" /etc/sysctl.d/10-kvm.conf; then
    sudo sed -i "s|.*vm.hugetlb_shm_group.*|vm.hugetlb_shm_group = 36|g" /etc/sysctl.d/10-kvm.conf
    sleep 1s
else
    printf "\nvm.hugetlb_shm_group = 36\n" | sudo tee -a /etc/sysctl.d/10-kvm.conf
    sleep 1s
fi

BOOTENTRY=`cat /boot/loader/entries/linux-xanmod.conf | grep "options root" | rev | cut -c 1- | rev`
if ! grep -i "hugepages=" /boot/loader/entries/linux-xanmod.conf; then
    echo
    echo "Updating /boot/loader/entries/linux-xanmod.conf"
    echo
    BOOTENTRY+=" hugepages=$ramgib"
    sudo sed -ie "s|^options root.*|${BOOTENTRY}|g" /boot/loader/entries/linux-xanmod.conf
    sleep 1s
fi
BOOTENTRYTWO=`cat /boot/loader/entries/linux-xanmod-lts.conf | grep "options root" | rev | cut -c 1- | rev`
if ! grep -i "hugepages=" /boot/loader/entries/linux-xanmod-lts.conf; then
    echo
    echo "Updating /boot/loader/entries/linux-xanmod-lts.conf"
    echo
    BOOTENTRYTWO+=" hugepages=$ramgib"
    sudo sed -ie "s|^options root.*|${BOOTENTRYTWO}|g" /boot/loader/entries/linux-xanmod-lts.conf
    sleep 1s
fi
BOOTENTRYTHREE=`cat /boot/loader/entries/linux-xanmod-rt.conf | grep "options root" | rev | cut -c 1- | rev`
if ! grep -i "hugepages=" /boot/loader/entries/linux-xanmod-rt.conf; then
    echo
    echo "Updating /boot/loader/entries/linux-xanmod-rt.conf"
    echo
    BOOTENTRYTHREE+=" hugepages=$ramgib"
    sudo sed -ie "s|^options root.*|${BOOTENTRYTHREE}|g" /boot/loader/entries/linux-xanmod-rt.conf
    sleep 1s
fi

if ! [[ -f /etc/default/qemu-kvm ]]; then
    sudo touch /etc/default/qemu-kvm
    sleep 1s
fi

if grep -i "KVM_HUGEPAGES"; then
    echo
    echo "Enabling KVM_HUGEPAGES for qemu-kvm"
    echo
    sudo sed -i "s|.*KVM_HUGEPAGES.*|KVM_HUGEPAGES=1|g" /etc/default/qemu-kvm
    sleep 1s
else
    echo 'KVM_HUGEPAGES=1' | sudo tee -a /etc/default/qemu-kvm
    sleep 1s
fi

echo
echo "Restarting libvirtd service"
echo
sudo systemctl restart libvirtd
sleep 1s

echo
echo 'Updatin initramfs'
echo
sudo mkinitcpio -P
sleep 1s

echo
echo "Done, restart your system for changes to take effect"
echo
echo "Restart now? Y - Yes | Anything else - No"
read REBOOT
if [[ ${REBOOT,,} = y ]]; then
    systemctl reboot
fi
