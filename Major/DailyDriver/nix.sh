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

# if ! [[ -d "${HOME}"/.config/nix ]]; then
#     echo
#     printf "mkdir -p \"${HOME}/.config/nix\""
#     echo
#     mkdir -p "${HOME}"/.config/nix
#     sleep 1s
# fi
#
# if ! [[ -f "${HOME}"/.config/nix/nix.conf ]]; then
#     echo
#     printf "touch \"${HOME}/.config/nix/nix.conf\""
#     echo
#     touch "${HOME}"/.config/nix/nix.conf
#     sleep 1s
# fi
#
# echo '' >> "${HOME}"/.config/nix/nix.conf
# echo 'experimental-features = nix-command flakes' >> "${HOME}"/.config/nix/nix.conf
# echo '' >> "${HOME}"/.config/nix/nix.conf
# echo 'sandbox = true' >> "${HOME}"/.config/nix/nix.conf
# echo 'auto-optimise-store = true' >> "${HOME}"/.config/nix/nix.conf
# echo '' >> "${HOME}"/.config/nix/nix.conf
# sleep 1s
#
# sudo systemctl restart nix-daemon
# sleep 1s
#
# if ! [[ "${HOME}"/.local/state/home-manager/profiles ]]; then
#     mkdir -p "${HOME}"/.local/state/home-manager/profiles
#     sleep 1s
# fi
# if ! [[ /nix/var/nix/profiles/per-user/$(logname) ]]; then
#     sudo mkdir -p /nix/var/nix/profiles/per-user/$(logname)
#     sleep 1s
# fi
#
# nix run home-manager/release-23.05 -- init --switch
# sleep 1s
#
# home-manager switch
# sleep 1s
#
# #sed -i 's/, ... } :/, lib, ... } :/g' "${HOME}"/.config/home-manager/home.nix
# #sed -i 's///g' "${HOME}"/.config/home-manager/home.nix
# sed -i 's/\  home.packages = \[/\  home.packages = with pkgs; [/g' "${HOME}"/.config/home-manager/home.nix
# sed -i '/^\  home.homeDirectory.*/a \  nixpkgs.config.allowUnfree = true;' "${HOME}"/.config/home-manager/home.nix
# sed -i '/^\  home.homeDirectory.*/a \  targets.genericLinux.enable = true;' "${HOME}"/.config/home-manager/home.nix
# sed -i '/^\  home.homeDirectory.*/a \ ' "${HOME}"/.config/home-manager/home.nix
#
# if [[ -f "${HOME}"/.profile ]]; then
#     mv "${HOME}"/.profile "${HOME}"/.profile.old
#     sleep 1s
# fi
#
# touch "${HOME}"/.profile
# sleep 1s
#
# echo '#!/bin/sh' > "${HOME}"/.profile
# echo '' >> "${HOME}"/.profile
# echo 'if [ -d $HOME/.nix-profile/etc/profile.d ]; then' >> "${HOME}"/.profile
# echo '  for i in $HOME/.nix-profile/etc/profile.d/*.sh; do' >> "${HOME}"/.profile
# echo '    if [ -r $i ]; then' >> "${HOME}"/.profile
# echo '      . $i' >> "${HOME}"/.profile
# echo '    fi' >> "${HOME}"/.profile
# echo '  done' >> "${HOME}"/.profile
# echo 'fi' >> "${HOME}"/.profile
# echo '' >> "${HOME}"/.profile
# sleep 1s
#
# chmod +x "${HOME}"/.profile
#
# echo
# echo 'Restarting nix-daemon'
# echo
# sudo systemctl restart nix-daemon
#
# echo
# echo 'Creating new generation'
# echo
# home-manager switch
# sleep 1s
