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

if ! [[ -d "${HOME}"/.config/nix ]]; then
    echo
    printf "mkdir -p \"${HOME}/.config/nix\""
    echo
    mkdir -p "${HOME}"/.config/nix
    sleep 1s
fi

if ! [[ -f "${HOME}"/.config/nix/nix.conf ]]; then
    echo
    printf "touch \"${HOME}/.config/nix/nix.conf\""
    echo
    touch "${HOME}"/.config/nix/nix.conf
    sleep 1s
fi

echo 'experimental-features = nix-command flakes' >> "${HOME}"/.config/nix/nix.conf
sleep 1s

if ! [[ -d "${HOME}"/.config/nixpkgs ]]; then
    echo
    printf "mkdir -p \"${HOME}/.config/nixpkgs\""
    echo
    mkdir -p "${HOME}"/.config/nixpkgs
    sleep 1s
fi

if ! [[ -f "${HOME}"/.config/nixpkgs/config.nix ]]; then
    echo
    printf "touch \"${HOME}/.config/nixpkgs/config.nix\""
    echo
    touch "${HOME}"/.config/nixpkgs/config.nix
    sleep 1s
fi

printf "{\n  allowUnfree = true;\n  nix.settings.sandbox = true;\n  nix.settings.auto-optimise-store = true;\n}\n" > "${HOME}"/.config/nixpkgs/config.nix

if [[ -f "${HOME}"/.profile ]]; then
    mv "${HOME}"/.profile "${HOME}"/.profile.old
    sleep 1s
fi

touch "${HOME}"/.profile
sleep 1s

echo '#!/bin/sh' > "${HOME}"/.profile
echo '' >> "${HOME}"/.profile
echo 'if [ -d $HOME/.nix-profile/etc/profile.d ]; then' >> "${HOME}"/.profile
echo '  for i in $HOME/.nix-profile/etc/profile.d/*.sh; do' >> "${HOME}"/.profile
echo '    if [ -r $i ]; then' >> "${HOME}"/.profile
echo '      . $i' >> "${HOME}"/.profile
echo '    fi' >> "${HOME}"/.profile
echo '  done' >> "${HOME}"/.profile
echo 'fi' >> "${HOME}"/.profile
echo '' >> "${HOME}"/.profile
sleep 1s

chmod +x "${HOME}"/.profile

if ! [[ "${HOME}"/.local/state/home-manager/profiles ]]; then
    mkdir -p "${HOME}"/.local/state/home-manager/profiles
fi
if ! [[ "${HOME}"/Projects/$(logname) ]]; then
    mkdir -p "${HOME}"/Projects/$(logname)
fi
if ! [[ /nix/var/nix/profiles/per-user/$(logname) ]]; then
    sudo mkdir -p /nix/var/nix/profiles/per-user/$(logname)
fi

echo
echo 'Syncing system'
echo
sync
sleep 1s

echo
printf "Change all your fonts to Fira Code."
echo
printf "Open kvantum manager and choose Orchis-dark in \"Change/Delete Theme\" section"
echo
printf "in \"Configure Active Theme\" section in \"Sizes & Delays\" change \"Tooltip delay\" to 150 ms and save"
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

exit 0
