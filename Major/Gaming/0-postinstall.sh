sudo pacman -S meson --asdep --noconfirm --needed

sudo pacman -S flatpak steam-devices gnome-keyring gamemode make cmake extra-cmake-modules git wget curl npm base-devel neovim ranger rustup --noconfirm --needed

systemctl --user enable --now gamemoded

flatpak install flathub com.valvesoftware.Steam flathub net.davidotek.pupgui2 com.github.tchx84.Flatseal com.github.Matoking.protontricks com.vysp3r.ProtonPlus com.discordapp.Discord org.mozilla.firefox com.bitwarden.desktop -y

echo
echo "Config Ranger"
echo
ranger --copy-config=all
export RANGER_LOAD_DEFAULT_RC=false
sudo bash -c "printf \"RANGER_LOAD_DEFAULT_RC=false\n\" >> /etc/environment"
sleep 1s

sed -i 's/set preview_images false/set preview_images true/g' "${HOME}"/.config/ranger/rc.conf
sleep 1s
sed -i 's/set draw_borders none/set draw_borders true/g' "${HOME}"/.config/ranger/rc.conf
sleep 1s

echo
echo "Installing stable version of Rustup"
echo
rustup install stable
sleep 1s

echo
echo "Adding i686 architecture support for Rustup"
echo
rustup target install i686-unknown-linux-gnu
sleep 1s

echo
echo "Setting stable as our default Rustup toolchain"
echo
rustup default stable
sleep 1s

echo
echo "Setting Cargo to run commands in parallel"
echo
cargo install async-cmd
sleep 1s

echo
echo "Installing Paru"
echo
cd ${HOME}/.apps && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg --noconfirm --needed -si
sleep 1s

cd ${HOME}/.apps

echo
echo "Setting ranger as paru's File Manager"
echo
sudo sed -i "s|\#\[bin]|[bin]|g" /etc/paru.conf
sleep 1s
sudo sed -i "s|#FileManager.*|FileManager = ranger|g" /etc/paru.conf
sleep 1s

paru -S kwin-bismuth --noconfirm --needed --sudoloop

mkdir ${HOME}/.apps
cd ${HOME}/.apps

git clone https://github.com/matinlotfali/KDE-Rounded-Corners.git && cd KDE-Rounded-Corners
mkdir build && cd build
cmake .. --install-prefix /usr
make
sudo make install

kwin_x11 --replace &
