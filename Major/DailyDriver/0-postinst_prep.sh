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

SRCPATH="$(cd $(dirname $0) && pwd)"
FFPATH="${SRCPATH}/aesthetic/ff"
APPSPATH="${HOME}/.apps"

if ! [[ -d "${APPSPATH}" ]]; then
    mkdir -p "${APPSPATH}"
fi
if ! [[ -d "${APPSPATH}"/archs ]]; then
    mkdir -p "${APPSPATH}"/archs
fi
if ! [[ `pacman -Q | grep -i 'kvantum'` ]]; then
    sudo pacman -S kvantum ttf-fira-code --noconfirm --needed
fi
if ! [[ -d "${HOME}"/.config/Kvantum ]]; then
    mkdir -p "${HOME}"/.config/Kvantum
fi
if ! [[ -d "${HOME}"/.config/gtk-3.0 ]]; then
    mkdir -p "${HOME}"/.config/gtk-3.0
fi
if ! [[ -d "${HOME}"/.config/gtk-4.0 ]]; then
    mkdir -p "${HOME}"/.config/gtk-4.0
fi
if ! [[ -d /usr/share/icons/Sweet-cursors ]] &&  \
     [[ -d "${HOME}"/.icons/Sweet-cursors ]]; then
    sudo ln -s "${HOME}"/.icons/Sweet-cursors /usr/share/icons
fi
if [[ -f "${HOME}"/.gtkrc-2.0 ]]; then
    mv "${HOME}"/.gtkrc-2.0 "${HOME}"/.gtkrc-2.0.old
fi
if ! [[ -f /etc/sddm.conf.d/avatars.conf ]]; then
    sudo touch /etc/sddm.conf.d/avatars.conf
    printf "[Theme]\nEnableAvatars=true\nDisableAvatarsThreshold=7" | sudo tee /etc/sddm.conf.d/avatars.conf
fi
if ! [[ -f /usr/share/sddm/scripts/Xsetup ]]; then
    sudo touch /usr/share/sddm/scripts/Xsetup
    printf "#!/bin/sh\n# Xsetup - run as root before the login dialog appears\n" | sudo tee /usr/share/sddm/scripts/Xsetup
fi

printf "setxkbmap pt\n" | sudo tee -a /usr/share/sddm/scripts/Xsetup

sudo sed -i '/^Current=.*/a CursorSize=36' /etc/sddm.conf.d/kde_settings.conf
sudo sed -i '/^Current=.*/a CursorTheme=Sweet-cursors' /etc/sddm.conf.d/kde_settings.conf
sudo sed -i "/^Current=.*/a Font='Fira Code'" /etc/sddm.conf.d/kde_settings.conf

cp "${FFPATH}"/.gtkrc-2.0 "${HOME}"/
cp "${FFPATH}"/settings.ini "${HOME}"/.config/gtk-3.0
cp "${FFPATH}"/settings.ini "${HOME}"/.config/gtk-4.0
cp -r "${FFPATH}"/Orchis-dark "${HOME}"/.config/Kvantum

if [[ -f "${HOME}"/.bashrc ]]; then
    mv "${HOME}"/.bashrc "${HOME}"/.bashrc.old
fi
if [[ -f "${HOME}"/.bash_aliases ]]; then
    mv "${HOME}"/.bash_aliases "${HOME}"/.bash_aliases.old
fi
if [[ -f "${HOME}"/.xinitrc ]]; then
    mv "${HOME}"/.xinitrc "${HOME}"/.xinitrc.old
fi

cp -f "${SRCPATH}"/home/.bashrc "${APPSPATH}"/archs
cp -f "${SRCPATH}"/home/.bash_aliases "${APPSPATH}"/archs
cp -f "${SRCPATH}"/home/.wezterm.lua "${APPSPATH}"/archs
cp -f "${SRCPATH}"/home/.xinitrc "${APPSPATH}"/archs

ln -svf "${APPSPATH}"/archs/.bashrc "${HOME}"/.bashrc
ln -svf "${APPSPATH}"/archs/.bash_aliases "${HOME}"/.bash_aliases
ln -svf "${APPSPATH}"/archs/.wezterm.lua "${HOME}"/.wezterm.lua
ln -svf "${APPSPATH}"/archs/.xinitrc "${HOME}"/.xinitrc

# sudo ln -s "${FFPATH}"/Sweet-cursors /usr/share/icons
clear
echo
printf "Change all your fonts to Fira Code."
echo
printf "Open kvantum manager and choose Orchis-dark in \"Change/Delete Theme\" section"
echo
printf "in \"Configure Active Theme\" section in \"Sizes & Delays\" change \"Tooltip delay\" to 150 ms and save"
echo

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
#echo "Splash Screen: Matrix (https://store.kde.org/p/1230011)"
#echo
#echo "Boot Splash Screen: TUX BOOT SPLASH (https://store.kde.org/p/1189328)"
#echo
#echo "Login Screen (SDDM): Chili for Plasma (https://store.kde.org/p/1214121)"
#echo "Login Screen (SDDM): Sugar Candy for SDDM (https://store.kde.org/p/1312658)"
#echo
#echo "Window Management->Task Switcher: Thumbnail Switcher (https://store.kde.org/p/2010367)"
#echo

exit 0
