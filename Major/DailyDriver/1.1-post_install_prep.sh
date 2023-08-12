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

APPSPATH="${HOME}/.apps"
SRCPATH="$(cd $(dirname $0) && pwd)"

if ! [[ -d "${HOME}"/.config/nix ]]; then
    echo
    printf "mkdir -p \"${HOME}/.config/nix\""
    echo
    mkdir -p "${HOME}"/.config/nix
    sleep 1s
fi

if [[ -f "${HOME}"/.config/nix/nix.conf ]]; then
    echo
    printf "Backing up \"${HOME}/.config/nix/nix.conf\" to \"${HOME}/.config/nix/nix.conf.old\""
    echo
    mv "${HOME}"/.config/nix/nix.conf "${HOME}"/.config/nix/nix.conf.old
    sleep 1s
fi

cp -rf "${APPSPATH}"/archs/home-manager/nix/nix.conf "${HOME}"/.config/nix

# echo 'experimental-features = nix-command flakes' > "${HOME}"/.config/nix/nix.conf
# echo 'sandbox = true' >> "${HOME}"/.config/nix/nix.conf
# echo 'auto-optimise-store = true' >> "${HOME}"/.config/nix/nix.conf
# echo '' >> "${HOME}"/.config/nix/nix.conf
# sleep 1s

echo
printf "Adding $(logname) to Nix's trusted users to perform privileged commands without sudo"
echo
sudo bash -c "echo 'trusted-users = root $(logname)' >> /etc/nix/nix.conf"

echo
echo 'Restarting nix-daemon'
echo
sudo systemctl restart nix-daemon
sleep 1s

mkdir -p "${HOME}"/.local/state/home-manager/profiles
sleep 1s

sudo mkdir -p /nix/var/nix/profiles/per-user/$(logname)
sleep 1s

echo
echo 'Installing home-manager'
echo
nix run home-manager/release-23.11 -- init --switch
sleep 1s

echo
echo "Copying ${APPSPATH}/archs/home-manager to ${HOME}/.config/"
echo
ln -svf "${APPSPATH}"/archs/home-manager/* "${HOME}"/.config/home-manager

#if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
#elif lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq intel || lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq virtio; then
#fi

echo
echo 'Creating new generation'
echo
home-manager switch
sleep 1s

echo
echo 'Enabling cachix for nix-gaming'
echo
cachix use nix-gaming

echo
echo 'Syncing system'
echo
sync
sleep 1s

echo
printf "Change all your fonts to Fira Code.\n"
echo
printf "Change application style to kvantum-dark\n"
echo
printf "Open kvantum manager and choose Orchis-dark in \"Change/Delete Theme\" section\n"
echo
printf "in \"Configure Active Theme\" section in \"Sizes & Delays\" change \"Tooltip delay\" to 150 ms and save\n"
echo
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

#echo
#echo "Download themes"
#echo
#
#echo
#echo "Global Theme: Orchis-dark (https://store.kde.org/p/1458927)"
#echo
#echo "Application Style: kvantum-dark"
#echo "    GNOME/GTK Application Style: Orchis-Purple-Dark (https://store.kde.org/p/1357889)"
#echo
#echo "Plasma Style: Orchis-dark"
#echo
#echo "Colors: OrchisDark"
#echo
#echo "Window Decorations: Orchis-dark"
#echo "    Window border size: No Borders"
#echo "    Titlebar Buttons: Remove All, untick both \"Close windows by double click\" and \"Show titlebar tooltips\""
#echo "Note: Rounded Corners works best with Breeze. Other Window Decorations might give you either transparent triangles or black lines on the corners"
#echo "It depends how rounded/squared the Window Decoration is"
#echo
#echo "All Fira Code"
#echo "    Anti-Aliasing: Enable"
#echo "    Sub-pixel rendering: RGB"
#echo "    Hinting: Slight"
#echo "    Force font DPI: Disabled"
#echo
#echo "Icons: Tela Circle (Purple) (https://store.kde.org/p/1359276)"
#echo
#echo "Cursors: Sweet-cursors (https://store.kde.org/p/1393084)"
#echo
#echo "Splash Screen: Simple Tux Splash (https://store.kde.org/p/1258784)"
#echo
#echo "Boot Splash Screen: TUX BOOT SPLASH (https://store.kde.org/p/1189328)"
#echo
#echo "Login Screen (SDDM): Chili for Plasma (https://store.kde.org/p/1214121)"
#echo "Login Screen (SDDM): Sugar Candy for SDDM (https://store.kde.org/p/1312658)"
#echo
#echo "Window Management->Task Switcher: Thumbnail Switcher (https://store.kde.org/p/2010367)"
#echo
