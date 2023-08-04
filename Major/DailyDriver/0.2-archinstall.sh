#!/bin/bash

# To check for available keymaps use the command below
# localectl list-x11-keymap-layouts

KBLOCALE="pt"

# Set your keyboard layout on X11
localectl set-x11-keymap $KBLOCALE

# Turn on swap
sudo swapon /swap/swapfile

# Move repo to ~/
sudo mv /ArchS $HOME/

# Take ownership of ArchS
sudo chown $(logname):$(logname) $HOME/ArchS

# Reboot to apply changes
shutdown -r now
exit 0
