#!/bin/bash

# Pacman
pkgs=(
    'base'
    'base-devel'
    'btrfs-progs'
    'efibootmgr'
    'linux'
    'linux-firmware'
    'linux-headers'
    'linux-lts'
    'linux-lts-headers'
    'dkms'
    'hyprland'
    'qt5-wayland'
    'qt5ct'
    'qt6-wayland'
    'qt6ct'
    'qt5-svg'
    'qt5-quickcontrols2'
    'qt5-graphicaleffects'
    'gtk3'
    'wl-clipboard'
    'cliphist'
    'pipewire'
    'pipewire-audio'
    'pipewire-alsa'
    'pipewire-pulse'
    'pipewire-jack'
    'pipewire-zeroconf'
    'gst-plugin-pipewire'
    'wireplumber'
    'qpwgraph'
    'pulsemixer'
    'pciutils'
    'usbutils'
    'networkmanager'
    'network-manager-applet'
    'dhcpcd'
    'neofetch'
    'dialog'
    'wpa_supplicant'
    'ibus'
    'mtools'
    'dosfstools'
    'xdg-user-dirs'
    'xdg-utils'
    'nfs-utils'
    'inetutils'
    'bind'
    'rsync'
    'sof-firmware'
    'ipset'
    'nss-mdns'
    'os-prober'
    'terminus-font'
    'exa'
    'bat'
    'gparted'
    'filelight'
    'brightnessctl'
    'neovim'
    'nano'
    'git'
    'curl'
    'pacman-contrib'
    'bash-completion'
    'wezterm'
    'wezterm-shell-integration'
    'wezterm-terminfo'
    'cups'
    'ntp'
    'openssh'
    'acpi'
    'acpi_call'
    'acpid'
    'avahi'
    'bluez'
    'bluez-utils'
    'hplip'
    'reflector'
    'wget'
    'jq'
    'mako'
    'wofi'
    'xdg-desktop-portal-hyprland'
    'swappy'
    'grim'
    'slurp'
    'python-requests'
    'pamixer'
    'pavucontrol'
    'polkit'
    'blueman'
    'btop'
    'starship'
    'autojump'
    'ttf-fira-code'
    'ttf-fira-sans'
    'ttf-jetbrains-mono-nerd'
    'noto-fonts-emoji'
    'noto-fonts-extra'
    'noto-fonts-cjk'
    'lxappearance'
    'xfce4-settings'
    'ttf-nerd-fonts-symbols'
    'ttf-nerd-fonts-symbols-common'
    'ttf-nerd-fonts-symbols-mono'
    'ttf-ubuntu-font-family'
    'ttf-jetbrains-mono'
    'ttf-meslo-nerd-font-powerlevel10k'
    'ttf-ms-fonts'
    'ttf-dejavu'
)

for pkg in "${pkgs[@]}"; do
    echo
    echo "Installing: $pkg"
    echo
    sudo pacman -S "$pkg" --noconfirm --needed
    sleep 1s
done

paru -Rdd hyprland --noconfirm
paru -S hyprland-nvidia --noconfirm

# Paru
pkgz=(
    'sddm-sugar-candy-git'
    'waybar-hyprland'
    'swww'
    'swaylock-effects'
    'wlogout'
    'polkit-gnome'
    'gvfs'
    'file-roller'
    'papirus-icon-theme'
    'nwg-look-bin'
    'ttf-vista-fonts'
)

for pkg in "${pkgz[@]}"; do
    echo
    echo "Installing: $pkg"
    echo
    paru -S "$pkg" --noconfirm --needed --sudoloop
    sleep 1s
done

sudo ln -svf /usr/share/fontconfig/conf.avail/10-nerd-font-symbols.conf /etc/fonts/conf.d/

sudo timedatectl set-ntp 1
sudo hwclock --systohc

sudo systemctl enable --now bluetooth.service

ln -svf ~/.apps/hypr/hyprland.conf ~/.config/hypr/
ln -svf ~/.apps/hypr/env_var.conf ~/.config/hypr/
ln -svf ~/.apps/hypr/media-binds.conf ~/.config/hypr/
ln -svf ~/.apps/hypr/xdg-portal-hyprland ~/.config/hypr/

mkdir -p ~/.config/mako
mkdir -p ~/.config/swaylock
mkdir -p ~/.config/waybar
mkdir -p ~/.config/wlogout
mkdir -p ~/.config/wofi
ln -svf ~/.apps/mako/conf/config-dark ~/.config/mako/config
ln -svf ~/.apps/swaylock/config ~/.config/swaylock/config
ln -svf ~/.apps/waybar/conf/v4-config.jsonc ~/.config/waybar/config.jsonc
ln -svf ~/.apps/waybar/style/v4-style-dark.css ~/.config/waybar/style.css
ln -svf ~/.apps/wlogout/layout ~/.config/wlogout/layout
ln -svf ~/.apps/wofi/config ~/.config/wofi/config
ln -svf ~/.apps/wofi/style/v4-style-dark.css ~/.config/wofi/style.css

sudo cp -R Extras/sdt /usr/share/sddm/themes/
sudo chown -R $USER:$USER /usr/share/sddm/themes/sdt
sudo mkdir /etc/sddm.conf.d

sudo bash -c 'echo "[Theme]" > /etc/sddm.conf.d/10-theme.conf'
sudo bash -c 'echo "Current=sdt" >> /etc/sddm.conf.d/10-theme.conf'

if ! [ -d /usr/share/wayland-sessions ]; then
    echo -e "/usr/share/wayland-sessions NOT found, creating..."
    sudo mkdir -p /usr/share/wayland-sessions
fi

if ! [ -f /usr/share/wayland-sessions/hyprland.desktop ]
    sudo cp Extras/hyprland.desktop /usr/share/wayland-sessions/
fi

xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
cp -f ~/.apps/backgrounds/v4-background-dark.jpg /usr/share/sddm/themes/sdt/wallpaper.jpg
