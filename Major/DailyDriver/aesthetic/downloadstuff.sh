#!/bin/bash

CURRDIR="$(cd $(dirname $0) && pwd)"

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

echo 'setxkbmap pt' | sudo tee -a /usr/share/sddm/scripts/Xsetup

sudo sed -i '/^Current=.*/a CursorSize=36' /etc/sddm.conf.d/kde_settings.conf
sudo sed -i '/^Current=.*/a CursorTheme=Sweet-cursors' /etc/sddm.conf.d/kde_settings.conf
sudo sed -i "/^Current=.*/a Font='Fira Code'" /etc/sddm.conf.d/kde_settings.conf

cp "${CURRDIR}"/ff/.gtkrc-2.0 "${HOME}"/
cp "${CURRDIR}"/ff/settings.ini "${HOME}"/.config/gtk-3.0
cp "${CURRDIR}"/ff/settings.ini "${HOME}"/.config/gtk-4.0
cp -r "${CURRDIR}"/ff/Orchis-dark "${HOME}"/.config/Kvantum
sudo cp -r "${CURRDIR}"/ff/Sweet-cursors /usr/share/icons
clear
echo
printf "Change all your fonts to Fira Code."
echo
printf "Open kvantum manager and choose Orchis-dark in \"Change/Delete Theme\" section"
echo
printf "in \"Configure Active Theme\" section in \"Sizes & Delays\" change \"Tooltip delay\" to 150 ms and save"
echo

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
#echo
#echo "Window Management->Task Switcher: Thumbnail Switcher (https://store.kde.org/p/2010367)"
#echo

exit 0
