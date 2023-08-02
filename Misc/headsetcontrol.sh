#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
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

echo
echo "Installing dependencies"
echo
sudo pacman -S libayatana-appindicator hidapi libnotify --noconfirm --needed
paru -S gnome-icon-theme --noconfirm --needed --sudoloop

echo
echo "Installing Headset Control"
echo
cd /opt
sudo git clone https://github.com/Sapd/HeadsetControl.git && cd HeadsetControl
sudo mkdir build && cd build
sudo cmake ..
sudo make
sudo make install

echo
echo "Installing Headset Control Notification"
echo
sudo git clone https://gitlab.com/devnore/headsetcontrol-notificationd.git && cd headsetcontrol-notificationd
sudo cp headsetcontrol-notifyd.service /etc/systemd/user/headsetcontrol-notificationd.service
sudo cp headsetcontrol-notificationd /usr/local/bin/
sudo chmod +x /usr/local/bin/headsetcontrol-notificationd

echo
echo "Installing Headset Control Indicator"
echo
sudo git clone https://github.com/centic9/headset-charge-indicator.git && cd headset-charge-indicator
sudo chmod +x install.sh
sudo ./install.sh

echo
echo "Applying final configurations"
echo
printf "\nalias hscontrol='python3 /opt/headset-charge-indicator/headset-charge-indicator.py --headsetcontrol-binary /usr/local/bin/headsetcontrol &'\n" | tee -a $HOME/.bash_aliases
printf "\nhscontrol\n" | tee -a $HOME/.bashrc
sudo systemctl daemon-reload
systemctl --user enable --now headsetcontrol-notificationd.service
sudo systemctl restart systemd-udevd.service

echo
echo "Done, reboot for changes to take effect"
echo
exit 0
