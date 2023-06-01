#!/usr/bin/env bash

echo
echo "      _        _                                     ___                               "
echo "     / \   ___| |_ ___ _ __ _ __  _   _ _ __ ___    / _ \ _ __ ___   ___  __ _  __ _   "
echo "    / _ \ / _ \ __/ _ \ '__| '_ \| | | | '_ ' _ \  | | | | '_ ' _ \ / _ \/ _' |/ _' |  "
echo "   / ___ \  __/ ||  __/ |  | | | | |_| | | | | | | | |_| | | | | | |  __/ (_| | (_| |  "
echo "  /_/   \_\___|\__\___|_|  |_| |_|\__,_|_| |_| |_|  \___/|_| |_| |_|\___|\__, |\__,_|  "
echo "                                                                         |___/         "
echo "                        Archlinux Post-Install Setup and Config"
echo

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    exit 1
fi

sleep 1s

echo
echo "CONFIGURING SYSTEM"
echo

sleep 1s

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    echo
    echo "Set Vulkan ICD to NVidia's. Y - Yes | N - No"
    echo
    sleep 1s
    read VULKANPATH
    if [ ${VULKANPATH,,} = y ]; then
        echo
        echo "Setting Vulkan ICD for NVIDIA"
        echo
        printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json\n" | sudo tee -a /etc/environment
        printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d\n" | sudo tee -a /etc/environment
        
        sleep 1s

        echo
        echo "Uninstalling non-NVIDIA vulkan stuff to prevent issues with other apps"
        echo "If you get target not found errors it means they're not installed, which is good"
        echo
        sleep 1s
        sudo pacman -Rsn vulkan-radeon lib32-vulkan-radeon vulkan-intel lib32-vulkan-intel vulkan-amdgpu-pro amf-amdgpu-pro --noconfirm
    fi
    sleep 1s
fi

# Enabling TRIM
sudo systemctl enable --now fstrim.timer
# SSH
#sudo systemctl enable --now sshd.service
# Mullvad VPN
#sudo systemctl enable --now mullvad-daemon.service
# CUPS service
sudo systemctl enable --now cups.service
# Enable OpenTabletDriver service
systemctl --user enable --now opentabletdriver.service
# Reloading systemctl daemon
sudo systemctl daemon-reload

sleep 1s

echo
echo "Setting up fq_pie queue discipline for TCP congestion control"
echo
echo 'net.core.default_qdisc = fq_pie' | sudo tee /etc/sysctl.d/90-override.conf

sleep 1s

PKGS=(
    'ostree'                        # Dependency
    'cmake'                         # Required
    'ninja'                         # Required
    'meson'                         # Required
    'mingw-w64-environment'         # I use
    'mingw-w64-pkg-config'          # I use
    'mingw-w64-cmake'               # I use
    'opencl-headers'                # Dependency
    'npm'                           # I use
    'node-gyp'                      # Used by npm
    'semver'                        # Used by npm
    'nodejs-nopt'                   # Used by npm
    'libmysofa'                     # Dependency
)

for PKG in "${PKGS[@]}"; do
    echo
    echo "Marking ${PKG} as explicitly installed so it doesn't get removed by mistake as a dependency"
    echo
    sudo pacman -D --asexplicit "$PKG"
    sleep 1s
done

sleep 1s

echo
echo "Amending journald Logging to 200M"
echo
sudo sed -i "s|#SystemMaxUse=.*|SystemMaxUse=200M|g" /etc/systemd/journald.conf

sleep 1s

echo
echo "Disabling Coredump logging"
echo
sudo sed -i "s|#Storage=.*|Storage=none|g" /etc/systemd/coredump.conf

sleep 1s

echo
echo "Setting MinimumVT to 7"
echo
sudo sed -i "s|MinimumVT=.*|MinimumVT=7|g" /usr/lib/sddm/sddm.conf.d/default.conf

sleep 1s

echo
echo "Increasing open file limit"
echo
sudo sed -i "s|# End of file.*|$(logname)        hard    nofile          2097152\n\n# End of file\n|g" /etc/security/limits.conf
sudo sed -i "s|# End of file.*|$(logname)        soft    nofile          1048576\n\n# End of file\n|g" /etc/security/limits.conf
sleep 1s
sudo sed -i "s|#DefaultLimitNOFILE=.*|DefaultLimitNOFILE=2097152|g" /etc/systemd/system.conf
sleep 1s
sudo sed -i "s|#DefaultLimitNOFILE=.*|DefaultLimitNOFILE=1048576|g" /etc/systemd/user.conf

sleep 1s

echo
echo "Disabling built-in kernel modules of tablet so OpenTablerDriver can work"
echo
sleep 1s
if ! test -e /etc/modprobe.d/blacklist.conf; then
    sudo touch /etc/modprobe.d/blacklist.conf
    printf "blacklist wacom\nblacklist hid_uclogic" | sudo tee /etc/modprobe.d/blacklist.conf
else
    printf "\nblacklist wacom\nblacklist hid_uclogic" | sudo tee -a /etc/modprobe.d/blacklist.conf
fi
sleep 1s
echo
echo "Stopping Wacom kernel module (if present)"
echo
sleep 1s
sudo rmmod wacom
sleep 1s
echo
echo "Stopping non-Wacom kernel module (if present)"
echo
sleep 1s
sudo rmmod hid_uclogic

sleep 1s

echo
echo "Improving font rendering"
echo
if test -e /etc/fonts/local.conf; then
    sudo mv /etc/fonts/local.conf /etc/fonts/local.conf.old
    sleep 1s
fi
sudo touch /etc/fonts/local.conf
sleep 1s
curl https://raw.githubusercontent.com/StefanoND/Manjaro/main/Misc/local.conf -o - | sudo tee /etc/fonts/local.conf
sleep 1s
if test -e /home/$(logname)/.Xresources; then
    sudo mv /home/$(logname)/.Xresources /home/$(logname)/.Xresources.bak;
fi
touch /home/$(logname)/.Xresources
sleep 1s
printf "Xft.antialias: 1\nXft.hinting: 1\nXft.rgba: rgb\nXft.hintstyle: hintslight\nXft.lcdfilter: lcddefault" | tee /home/$(logname)/.Xresources
sleep 1s
xrdb -merge /home/$(logname)/.Xresources
sleep 1s
if ! test -e /etc/fonts/conf.d/10-sub-pixel-rgb.conf; then
    sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
fi
sleep 1s
if ! test -e /etc/fonts/conf.d/10-hinting-slight.conf; then
    sudo ln -s /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d
fi
sleep 1s
if ! test -e /etc/fonts/conf.d/11-lcdfilter-default.conf; then
    sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
fi
sleep 1s
if ! test -e /home/$(logname)/.config/fontconfig; then
    mkdir -p /home/$(logname)/.config/fontconfig
fi
sleep 1s
if test -e /home/$(logname)/.config/fontconfig/fonts.conf; then
    mv /home/$(logname)/.config/fontconfig/fonts.conf /home/$(logname)/.config/fontconfig/fonts.conf.bak;
fi
sleep 1s
touch /home/$(logname)/.config/fontconfig/fonts.conf
sleep 1s
curl https://raw.githubusercontent.com/StefanoND/Manjaro/main/Misc/fonts.conf -o - | sudo tee /home/$(logname)/.config/fontconfig/fonts.conf
sleep 1s
sudo sed -i "s|#export FREETYPE_PROPERTIES=\"truetype:interpreter-version=|export FREETYPE_PROPERTIES=\"truetype:interpreter-version=|g" /etc/profile.d/freetype2.sh
sleep 1s
sudo fc-cache -fv

sleep 1s

echo
echo "Enabling CUPs service"
echo
sleep 1s
cd /usr/bin
./cupsenable

sleep 1s

echo
echo "Creating udev rule for AntiMicroX to avoid problems with wayland"
echo
sleep 1s
if test -e /usr/lib/udev/rules.d/60-antimicrox-uinput.rules; then
    sudo mv /usr/lib/udev/rules.d/60-antimicrox-uinput.rules /usr/lib/udev/rules.d/60-antimicrox-uinput.rules.old
fi
sudo touch /usr/lib/udev/rules.d/60-antimicrox-uinput.rules
sleep 1s
curl https://raw.githubusercontent.com/AntiMicroX/antimicrox/master/other/60-antimicrox-uinput.rules -o - | sudo tee /usr/lib/udev/rules.d/60-antimicrox-uinput.rules

sleep 1s

echo
echo "Making Gamemode start on boot"
echo
sleep 1s
sudo systemctl --user enable --now gamemoded.service
sleep 1s
sudo chmod +x /usr/bin/gamemoderun

sleep 1s

echo
echo "Restricting Kernel Log Access"
echo
sleep 1s
sudo sysctl -w kernel.dmesg_restrict=1

sleep 1s

echo
echo "Reset sudo password timeout to default"
echo "use 'sudo EDITOR=vim visudo' or 'sudo EDITOR=nano visudo' and remove 'Defaults passwd_timeout=-1'"
echo "Ignore if you haven't changed visudo"
echo
echo "Press any button to continue"
echo
read ANYTHING

sleep 1s

echo
echo " Done!"
echo

sleep 1s

echo
echo "press Y to reboot now or N if you plan to manually reboot later."
echo

read REBOOT
if [ ${REBOOT,,} = y ]; then
    sudo reboot now
fi
exit 0
