#!/bin/bash

echo
echo 'Stopping and disabling nix-daemon'
echo
sudo systemctl stop nix-daemon.service
sudo systemctl disable nix-daemon.socket nix-daemon.service
sudo systemctl daemon-reload
sleep 1s

echo
echo 'Removing nix files and folders'
echo
sudo rm -rf /etc/nix /etc/profile.d/nix.sh /etc/tmpfiles.d/nix-daemon.conf /nix ~root/.nix-channels ~root/.nix-defexpr ~root/.nix-profile
rm -rf "$HOME"/.nix-defexpr "$HOME"/.nix-profile "$HOME"/.config/nix "$HOME"/.config/nixpkgs "$HOME"/.config/home-manager
sleep 1s

for i in $(seq 1 32); do
    echo
    printf "Removing nixblkd$i user out of 32"
    echo
    sudo userdel nixbld$i
    sleep 1s
done

echo
echo 'Removing nixbld group'
echo
sudo groupdel nixbld
sleep 1s

echo
echo 'Check out your bash.bashrc, bashrc, profile, zshrc files in /etc and zshrc file in /etc/zsh'
echo 'And remove everything nix-related'
echo

echo
echo 'Done'
echo

exit 0
