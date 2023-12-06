#!/bin/bash

# DOWNLOAD AND EXTRACT THE LATEST VERSION OF EMACS http://mirrors.ibiblio.org/gnu/emacs/

mkdir -p ${HOME}/.apps
cd ${HOME}/.apps

wget -o- https://hub.unity3d.com/linux/keys/public
file public
gpg --no-default-keyring --keyring ./unity_keyring.gpg --import public
gpg --no-default-keyring --keyring ./unity_keyring.gpg --export > ./unity-archive-keyring.gpg

sudo mv ./unity-archive-keyring.gpg /etc/apt/trusted.gpg.d/
sudo bash -c 'echo "deb [signedby=/usr/share/keyrings/Unity_Technologies_ApS.gpg] https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list'

sudo add-apt-repository ppa:ubuntu-toolchain-r/ppa
sudo apt update

sudo apt install flatpak gnome-software-plugin-flatpak gcc build-essential unzip unrar p7zip libgccjit0 libgccjit-10-dev libgccjit-11-dev libgccjit-12-dev libjansson4 libjansson-dev apt-transport-https ca-certificates gnupg-agent software-properties-common libc6-dev libncurses5-dev libpng-dev xaw3dg-dev zlib1g-dev libice-dev libsm-dev libx11-dev libxext-dev libxi-dev libxmu-dev libxmuu-dev libxpm-dev libxrandr-dev libxt-dev libxtst-dev libxv-dev libc6-dev libncurses5-dev libpng-dev libtiff5-dev libgif-dev xaw3dg-dev zlib1g-dev libx11-dev libgtk-3-dev libwebkit2gtk-4.0-dev libjpeg-turbo8 fonts-firacode fonts-jetbrains-mono git curl wget autojump unityhub ripgrep fd-find python3-venv npm clang clang-format clangd make cmake cmake-extras python3-pip dotnet-sdk-7.0 aspnetcore-runtime-7.0 ninja-build gdb lldb -y

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

pip install cmake-language-server
dotnet tool install --global csharp-ls
sudo npm i -g bash-language-server
sudo npm i -g sql-language-server

git clone https://github.com/LuaLS/lua-language-server && cd lua-language-server
./make.sh

export PATH="$PATH:$HOME/.apps/lua-language-server/bin"
echo 'export PATH="$PATH:$HOME/.apps/lua-language-server/bin"' >> ${HOME}/.bashrc
echo '' >> ${HOME}/.bashrc

mkdir ${HOME}/.apps/fonts
cd ${HOME}/.apps/fonts

curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip

unzip -o FiraCode.zip
unzip -o JetBrainsMono.zip

cp -n *.ttf ~/.local/share/fonts/

fc-cache -f -v

cd ${HOME}/.apps

mkdir ${HOME}/.apps/config
cd ${HOME}/.apps/config

git clone https://github.com/StefanoND/nvchad_config.git nvim

cp -r ${HOME}/.apps/config/nvim ${HOME}/.config/

curl -LO https://github.com/wez/wezterm/releases/download/20230712-072601-f4abf8fd/wezterm-20230712-072601-f4abf8fd.Ubuntu22.04.deb
sudo apt install ./wezterm-20230712-072601-f4abf8fd.Ubuntu22.04.deb -y

curl -LO http://mirrors.ibiblio.org/gnu/emacs/emacs-29.1.tar.gz
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
tar -vfx nvim-linux64.tar.gz

export PATH="$PATH:$HOME/.apps/nvim-linux64/bin"
echo 'export PATH="$PATH:$HOME/.apps/nvim-linux64/bin"' >> ${HOME}/.bashrc
echo '' >> ${HOME}/.bashrc

curl -sS https://starship.rs/install.sh | sh

tar -xvf emacs-29.1.tar.gz

cd ${HOME}/.apps/emacs-29.1
sudo apt build-dep emacs -y

export CC="gcc-11"

./autogen.sh
./configure --with-cairo --with-xwidgets --with-x-toolkit=gtk3 --without-compress-install --with-native-compilation --with-json
make -j$(nproc)
sudo make install


# Binaries will be in /usr/local/bin

