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
echo 'Make a change in sddm, you can change to something else and back to the default one'
echo "Press any key when you're done"
echo
read ANYKEY
echo
sleep 1s

clear

KBLOCALE="pt"
SRCPATH="$(cd $(dirname $0) && pwd)"
FFPATH="${SRCPATH}/conf/aesthetic/ff"
APPSPATH="${HOME}/.apps"

if ! [[ -d "${APPSPATH}" ]]; then
    echo
    printf "mkdir -p \"${APPSPATH}\""
    echo
    mkdir -p "${APPSPATH}"
    sleep 1s
fi
if ! [[ -d "${APPSPATH}"/archs ]]; then
    echo
    printf "mkdir -p \"${APPSPATH}\"/archs"
    echo
    mkdir -p "${APPSPATH}"/archs
    sleep 1s
fi
if ! [[ `pacman -Q | grep -i 'kvantum'` ]]; then
    sudo pacman -S kvantum ttf-fira-code --noconfirm --needed
    sleep 1s
fi
if ! [[ -d "${HOME}"/.config/Kvantum ]]; then
    echo
    printf "mkdir -p "${HOME}"/.config/Kvantum"
    echo
    mkdir -p "${HOME}"/.config/Kvantum
    sleep 1s
fi
if ! [[ -d "${HOME}"/.config/gtk-3.0 ]]; then
    echo
    printf "mkdir -p "${HOME}"/.config/gtk-3.0"
    echo
    mkdir -p "${HOME}"/.config/gtk-3.0
    sleep 1s
fi
if ! [[ -d "${HOME}"/.config/gtk-4.0 ]]; then
    echo
    printf "mkdir -p "${HOME}"/.config/gtk-4.0"
    echo
    mkdir -p "${HOME}"/.config/gtk-4.0
    sleep 1s
fi
if ! [[ -d /usr/share/icons/Sweet-cursors ]] && [[ -d "${HOME}"/.icons/Sweet-cursors ]]; then
    echo
    printf "sudo cp -r "${HOME}"/.icons/Sweet-cursors /usr/share/icons"
    echo
    sudo cp -r "${HOME}"/.icons/Sweet-cursors /usr/share/icons
    sleep 1s
fi
if [[ -f "${HOME}"/.gtkrc-2.0 ]]; then
    echo
    printf "mv "${HOME}"/.gtkrc-2.0 "${HOME}"/.gtkrc-2.0.old"
    echo
    mv "${HOME}"/.gtkrc-2.0 "${HOME}"/.gtkrc-2.0.old
    sleep 1s
fi
if ! [[ -f /etc/sddm.conf.d/avatars.conf ]]; then
    echo
    printf "sudo touch /etc/sddm.conf.d/avatars.conf"
    echo
    sudo touch /etc/sddm.conf.d/avatars.conf
    printf "[Theme]\nEnableAvatars=true\nDisableAvatarsThreshold=7" | sudo tee /etc/sddm.conf.d/avatars.conf
    sleep 1s
fi
if ! [[ -f /usr/share/sddm/scripts/Xsetup ]]; then
    echo
    printf "sudo touch /usr/share/sddm/scripts/Xsetup"
    echo
    sudo touch /usr/share/sddm/scripts/Xsetup
    printf "#!/bin/sh\n# Xsetup - run as root before the login dialog appears\n" | sudo tee /usr/share/sddm/scripts/Xsetup
    sleep 1s
fi

echo
printf "setxkbmap $KBLOCALE\n" | sudo tee -a /usr/share/sddm/scripts/Xsetup
echo
sleep 1s

echo
echo 'Applying theme to /etc/sddm.conf.d/kde_settings.conf'
echo
sudo sed -i '/^Current=.*/a CursorSize=36' /etc/sddm.conf.d/kde_settings.conf
sleep 1s
sudo sed -i '/^Current=.*/a CursorTheme=Sweet-cursors' /etc/sddm.conf.d/kde_settings.conf
sleep 1s
sudo sed -i "/^Current=.*/a Font='Fira Code'" /etc/sddm.conf.d/kde_settings.conf
sleep 1s

echo
echo 'Applying theme to /usr/lib/sddm/sddm.conf.d/default.conf'
echo
sudo sed -i 's/Current=.*/Current=sugar-candy/g' /usr/lib/sddm/sddm.conf.d/default.conf
sleep 1s
sudo sed -i 's/CursorSize=.*/CursorSize=36/g' /usr/lib/sddm/sddm.conf.d/default.conf
sleep 1s
sudo sed -i 's/CursorTheme=.*/CursorTheme=Sweet-cursors/g' /usr/lib/sddm/sddm.conf.d/default.conf
sleep 1s
sudo sed -i "s/Font=.*/Font='Fira Code'/g" /usr/lib/sddm/sddm.conf.d/default.conf
sleep 1s

echo
echo 'Copying .gtkrc-2.0, gkt-3.0, gtk-4.0, Kvantum config files'
echo
cp "${FFPATH}"/.gtkrc-2.0 "${HOME}"/
cp "${FFPATH}"/settings.ini "${HOME}"/.config/gtk-3.0
cp "${FFPATH}"/settings.ini "${HOME}"/.config/gtk-4.0
cp -r "${FFPATH}"/Orchis-dark "${HOME}"/.config/Kvantum
sleep 1s

if [[ -f "${HOME}"/.bashrc ]]; then
    echo
    echo 'Backing up .bashrc'
    echo
    mv "${HOME}"/.bashrc "${HOME}"/.bashrc.old
    sleep 1s
fi
if [[ -f "${HOME}"/.bash_aliases ]]; then
    echo
    echo 'Backing up .bash_aliases'
    echo
    mv "${HOME}"/.bash_aliases "${HOME}"/.bash_aliases.old
    sleep 1s
fi
if [[ -f "${HOME}"/.xinitrc ]]; then
    echo
    echo 'Backing up .xinitrc'
    echo
    mv "${HOME}"/.xinitrc "${HOME}"/.xinitrc.old
    sleep 1s
fi

sed -i "s/111111/$(logname)/g" "${SRCPATH}"/conf/home/hotkeys.sh.desktop
sleep 1s

if [[ `echo $XDG_SESSION_TYPE | grep -iq x11` ]]; then
    sed -i 's/config.enable_wayland = true/config.enable_wayland = false/g' "${SRCPATH}"/conf/home/.wezterm.lua
    sleep 1s
fi

if ! [[ -d "${HOME}"/.config/autostart ]]; then
    mkdir -p "${HOME}"/.config/autostart
fi

echo
printf "Copying config files to a permanent place at: "
printf "\"${APPSPATH}/archs\""
echo
cp -f "${SRCPATH}"/conf/home/.bashrc "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/.bash_aliases "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/.wezterm.lua "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/.xinitrc "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/hotkeys.sh "${APPSPATH}"/archs
cp -f "${SRCPATH}"/conf/home/hotkeys.sh.desktop "${APPSPATH}"/archs
sleep 1s

printf "Symlinking config files to ${HOME}"
ln -svf "${APPSPATH}"/archs/.bashrc "${HOME}"/.bashrc
ln -svf "${APPSPATH}"/archs/.bash_aliases "${HOME}"/.bash_aliases
ln -svf "${APPSPATH}"/archs/.wezterm.lua "${HOME}"/.wezterm.lua
ln -svf "${APPSPATH}"/archs/.xinitrc "${HOME}"/.xinitrc
cp "${APPSPATH}"/archs/hotkeys.sh.desktop "${HOME}"/.config/autostart/
sleep 1s

sudo cp -r "${FFPATH}"/Sweet-cursors /usr/share/icons
sleep 1s

echo
echo 'Reloading daemon'
echo
sudo systemctl daemon-reload

#echo
#echo "Installinx Nix Package Manager"
#echo
#sh <(curl -L https://nixos.org/nix/install) --daemon

cd "${SRCPATH}"
exec bash ./1.1-prep.sh
