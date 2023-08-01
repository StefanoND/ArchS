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

if [[ apt list --installed | grep -i 'snap' ]]; then
    echo
    echo "Uninstalling Snap"
    echo

    PKGZ=(
        'firefox'
        'snap-store'
        'gnome-3-38-2004'
        'gtk-common-themes'
        'snapd-desktop-integration'
        'bare'
        'lxd'
        'core20'
        'snapd'
    )

    for PKG in "${PKGZ[@]}"; do
        echo
        echo "INSTALLING: ${PKG}"
        echo
        sudo snap remove --purge "$PKG"
        echo
        sleep 1s
    done
    sudo apt autoremove --purge snapd gnome-software-plugin-snap -y
    sleep 1s
fi

if [[ -d $HOME/snap ]]; then
    printf "rm -rf $HOME/snap"
    rm -rf $HOME/snap
fi
if [[ -d /snap ]]; then
    printf "sudo rm -rf /snap"
    sudo rm -rf /snap
fi
if [[ -d /var/snap ]]; then
    printf "sudo rm -rf /var/snap"
    sudo rm -rf /var/snap
fi
if [[ -d /var/lib/snapd ]]; then
    printf "sudo rm -rf /var/lib/snapd"
    sudo rm -rf /var/lib/snapd
fi
if [[ -d /var/cache/snapd ]]; then
    printf "sudo rm -rf /var/cache/snapd"
    sudo rm -rf /var/cache/snapd
fi

echo
echo "Stopping snap to auto-reinstall"
echo
sudo apt-mark hold snapd
sleep 1s

if ! [[ -d /etc/apt/preferences.d ]]; then
    sudo mkdir -p /etc/apt/preferences.d
fi
if ! [[ -f /etc/apt/preferences.d/nosnap ]]; then
    sudo touch /etc/apt/preferences.d/nosnap
fi
printf "Package: snapd\nPin: release a=*\nPin-Priority: -10\n" | sudo tee /etc/apt/preferences.d/nosnap
sleep 1s

if ! [[ -f /etc/apt/preferences.d/mozilla-firefox ]]; then
    sudo touch /etc/apt/preferences.d/mozilla-firefox
fi
printf "Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n" | sudo tee /etc/apt/preferences.d/mozilla-firefox
sleep 1s

if ! [[ -f /etc/apt/apt.conf.d/51unattended-upgrades-firefox ]]; then
    sudo touch /etc/apt/apt.conf.d/51unattended-upgrades-firefox
fi
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
sleep 1s

echo
echo "Uninstalling KDE Connect"
echo
sudo apt autoremove --purge kdeconnect -y
sleep 1s

echo
echo "Updating System"
echo
sudo apt update -y && sudo apt upgrade -y
sleep 1s

PKGS=(
    # Packet Manager
    'flatpak'

    # Misc
    'yakuake'
    'neovim'
    'curl'
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "INSTALLING: ${PKG}"
    echo
    sudo apt install "$PKG" -y
    echo
    sleep 1s
done

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sleep 1s

echo
echo "Configuring terminal profiles"
echo
touch "$HOME/.local/share/konsole/$(logname).profile"
sleep 1s

printf "[Appearance]\nColorScheme=Breeze\n\n[General]\nCommand=/bin/bash\nName=$(logname)\nParent=FALLBACK/\n\n[Scrolling]\nHistoryMode=2\nScrollFullPage=1\n\n[Terminal Features]\nBlinkingCursorEnabled=true\n" | tee $HOME/.local/share/konsole/$(logname).profile
sleep 1s

if ! [[ -f "$HOME/.config/konsolerc" ]]; then
    touch "$HOME/.config/konsolerc";
fi

if grep -qF "DefaultProfile=" "$HOME/.config/konsolerc"; then
    sed -i "s|DefaultProfile=.*|DefaultProfile=$(logname).profile|g" "$HOME/.config/konsolerc"
elif ! grep -qF "DefaultProfile=" "$HOME/.config/konsolerc" && ! grep -qF "[Desktop Entry]" "$HOME/.config/konsolerc"; then
    sed -i "1 i\[Desktop Entry]\nDefaultProfile=$(logname).profile\n" "$HOME/.config/konsolerc"
fi

sleep 1s

if [[ apt list --installed | grep -i 'yakuake' ]]; then
    echo
    echo "Configuring Yakuake"
    echo
    sleep 1s
    if ! test -e "$HOME/.config/yakuakerc"; then
        touch "$HOME/.config/yakuakerc";
    fi

    sleep 1s

    if grep -qF "DefaultProfile=" "$HOME/.config/yakuakerc"; then
        sed -i "s|DefaultProfile=.*|DefaultProfile=$(logname).profile|g" "$HOME/.config/yakuakerc"
    elif ! grep -qF "DefaultProfile=" "$HOME/.config/yakuakerc" && ! grep -qF "[Desktop Entry]" "$HOME/.config/yakuakerc"; then
        sed -i "1 i\[Desktop Entry]\nDefaultProfile=$(logname).profile\n" "$HOME/.config/yakuakerc"
    fi

    sleep 1s

    if ! test -e "$HOME/.config/autostart"; then
        mkdir "$HOME/.config/autostart"
    fi

    if ! test -e "$HOME/.config/autostart/org.kde.yakuake.desktop"; then
        echo
        echo "Making Yakuake autostart at log-in"
        echo
        sleep 1s
        ln -s /usr/share/applications/org.kde.yakuake.desktop "$HOME/.config/autostart"
        sleep 1s
    fi
fi

echo
echo "Done."
echo
sleep 1s
echo
echo "Press Y to reboot now or N if you plan to manually reboot later."
echo
read REBOOT
if [[ ${REBOOT,,} = y ]]; then
    reboot
fi
exit 0
