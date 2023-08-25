#!/bin/bash

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

# To check for available keymaps use the command below
# localectl list-x11-keymap-layouts

KBLOCALE="pt"
SRCPATH="$(cd $(dirname $0) && pwd)"
APPSPATH="${HOME}/.apps"

pacman -S xorg-xwayland plasma-wayland-session plasma-wayland-protocols --noconfirm --needed
sleep 1s

# NVIDIA ONLY
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    pacman -S egl-wayland --noconfirm --needed
    sleep 1s
fi

paru -S swhkd-git --noconfirm --needed --sudoloop

if ! [[ -d "${HOME}"/.config/swhkd ]]; then
    mkdir -p "${HOME}"/.config/swhkd
fi

sudo mv /etc/swhkd/swhkdrc /etc/swhkd/swhkdrc.old
sleep 1s

cp -f "${SRCPATH}"/conf/home/swhkdrc "${HOME}"/.config/swhkd
sleep 1s

sudo ln -svf "${HOME}"/.config/swhkd/swhkdrc /etc/swhkd
sleep 1s

echo
echo "Creating udev rule for AntiMicroX to avoid problems with wayland"
echo
sleep 1s
if test -e /usr/lib/udev/rules.d/60-antimicrox-uinput.rules; then
    sudo mv /usr/lib/udev/rules.d/60-antimicrox-uinput.rules /usr/lib/udev/rules.d/60-antimicrox-uinput.rules.old
    sleep 1s
fi

sudo touch /usr/lib/udev/rules.d/60-antimicrox-uinput.rules
sleep 1s

curl https://raw.githubusercontent.com/AntiMicroX/antimicrox/master/other/60-antimicrox-uinput.rules -o - | sudo tee /usr/lib/udev/rules.d/60-antimicrox-uinput.rules
sleep 1s

printf "XKB_DEFAULT_LAYOUT=$KBLOCALE\n" | sudo tee -a /etc/environment
sleep 1s

export XKB_DEFAULT_LAYOUT=$KBLOCALE
sleep 1s

sed -i 's/config.enable_wayland = false/config.enable_wayland = true/g' "${SRCPATH}"/conf/home/.wezterm.lua
sleep 1s

sudo bash -c "echo 'QT_QPA_PLATFORM=\"xcb;wayland\"' >> /etc/environment"
sudo bash -c "echo 'GTK_IM_MODULE=ibus' >> /etc/environment"
sudo bash -c "echo 'QT_IM_MODULE=ibus' >> /etc/environment"
sudo bash -c "echo 'XMODIFIERS=@im=ibus' >> /etc/environment"
#echo '' >> /etc/environment
sleep 1s

sed -i "s/111111/$(logname)/g" "${SRCPATH}"/conf/home/hotkeys.sh.desktop
sleep 1s

if ! [[ -d "${HOME}"/.config/autostart ]]; then
    mkdir -p "${HOME}"/.config/autostart
fi

cp -f "${SRCPATH}"/conf/home/hotkeys.sh "${APPSPATH}"/archs
sleep 1s
cp -f "${SRCPATH}"/conf/home/hotkeys.sh.desktop "${APPSPATH}"/archs
sleep 1s

cp "${APPSPATH}"/archs/hotkeys.sh.desktop "${HOME}"/.config/autostart/
sleep 1s

printf "# Restart swhkd\n" >> ${HOME}/.bash_aliases
printf "alias restartswhkd='killall -9 swhks && sudo killall -9 swhkd &&  notify \"swhks reloaded\" && notify \"swhkd reloaded\" && swhks & pkexec swhkd &'\n" >> ${HOME}/.bash_aliases

sudo bash -c "echo 'accel-profile=flat' >> /etc/libinput.conf"
sudo ln -sf ~/.config/swhkd/swhkdrc /etc/swhkd

exit 0
