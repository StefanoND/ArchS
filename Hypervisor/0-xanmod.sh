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

PKGS=(
    # Xanmod
    'curl'
    'software-properties-common'
    'apt-transport-https'
    'ca-certificates'
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo apt install "$PKG" -y
    sleep 1s
done

echo
echo "Importing xanmod's GPG key"
echo
curl -fSsL https://dl.xanmod.org/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/xanmod.gpg > /dev/null
sleep 1s

echo
echo "Importing xanmod's repository"
echo
echo 'deb [signed-by=/usr/share/keyrings/xanmod.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
sleep 1s

sudo apt update

echo
echo "Installing xanmod kernel"
echo
sudo apt install linux-xanmod-lts-x64v3 -y
sleep 1s

echo
echo "Updating initramfs"
echo
sudo update-initramfs -u -k all
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

