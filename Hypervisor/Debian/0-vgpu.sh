#!/usr/bin/env bash

echo
echo "TESTING STAGE, DON'T RUN THIS SCRIPT!"
echo
exit 0

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
    echo "Defaults insults" # Replace "Sorry, try again." with humorous insults.
    echo "Defaults rootpw" # Will require root password for sudo command
    echo "Defaults timestamp_type=global" # All terminals "share the same timeout" for sudo password
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

sudo -i

apt update && apt upgrade -y

apt install dkms python3 python3-pip

cd /opt

git clone https://github.com/rupansh/vgpu_unlock_5.12.git

chmod -R +x vgpu_unlock_5.12

if ! [[ -d /etc/modprobe.d ]]; then
    mkdir -p /etc/modprobe.d
fi

GRUB=`cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX_DEFAULT" | rev | cut -c 2- | rev`
grubgpu=""
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    touch /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    echo 'blacklist nouveau' > /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    echo 'blacklist lbm-nouveau' >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    echo 'options nouveau modeset=0' >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    echo 'alias nouveau off' >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    echo 'alias lbm-nouveau off' >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf
    echo 'options nouveau modeset=0' > /etc/modprobe.d/nouveau-kms.conf
    grubgpu=" nouveau.modeset=0 nvidia-drm.modeset=1"
    sleep 1s
fi
elif lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq amd; then
    grubgpu=" amdgpu.aspm=0"
    sleep 1s
fi

if grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
    GRUB+=" amd_iommu=on iommu=pt kvm_amd.npt=1 kvm_amd.avic=1 kvm_amd.nested=1 kvm_amd.sev=1 kvm.ignore_msrs=1 kvm.report_ignored_msrs=0 video=vesafb:off,efifb:off,simplefb:off$grubgpu pcie_acs_override=downstream,multifunction systemd.unified_cgroup_hierarchy=0\""
    sleep 1s
elif grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
    GRUB+=" intel_iommu=on iommu=pt kvm.ignore_msrs=1 kvm.report_ignored_msrs=0 video=vesafb:off,efifb:off,simplefb:off$grubgpu pcie_acs_override=downstream,multifunction systemd.unified_cgroup_hierarchy=0\""
    sleep 1s
fi

sed -ie "s|^GRUB_CMDLINE_LINUX_DEFAULT.*|${GRUB}|g" /etc/default/grub
sleep 1s

if ! grep "GRUB_TIMEOUT=" /etc/default/grub; then
    printf "GRUB_TIMEOUT=2\n" | tee -a /etc/default/grub
    sleep 1s
else
    sed -i "s|GRUB_TIMEOUT=.*|GRUB_TIMEOUT=2|g" /etc/default/grub
    sleep 1s
fi

if ! grep "GRUB_HIDDEN_TIMEOUT=" /etc/default/grub; then
    printf "GRUB_HIDDEN_TIMEOUT=2\n" | tee -a /etc/default/grub
    sleep 1s
else
    sed -i "s|GRUB_HIDDEN_TIMEOUT=.*|GRUB_HIDDEN_TIMEOUT=2|g" /etc/default/grub
    sleep 1s
fi

if ! grep "GRUB_RECORDFAIL_TIMEOUT=" /etc/default/grub; then
    printf "GRUB_RECORDFAIL_TIMEOUT=2\n" | tee -a /etc/default/grub
    sleep 1s
else
    sed -i "s|GRUB_RECORDFAIL_TIMEOUT=.*|GRUB_RECORDFAIL_TIMEOUT=2|g" /etc/default/grub
    sleep 1s
fi

if ! grep "GRUB_TIMEOUT_STYLE=" /etc/default/grub; then
    printf "GRUB_TIMEOUT_STYLE=menu\n" | tee -a /etc/default/grub
    sleep 1s
else
    sed -i "s|GRUB_TIMEOUT_STYLE=.*|GRUB_TIMEOUT_STYLE=menu|g" /etc/default/grub
    sleep 1s
fi

if ! grep "GRUB_SAVEDEFAULT=" /etc/default/grub; then
    printf "GRUB_SAVEDEFAULT=false\n" | tee -a /etc/default/grub
    sleep 1s
else
    sed -i "s|GRUB_SAVEDEFAULT=.*|GRUB_SAVEDEFAULT=false|g" /etc/default/grub
    sleep 1s
fi

echo
echo "Updating GRUB"
echo
update-grub
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
