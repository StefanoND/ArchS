#!/bin/bash

# To check for available keymaps use the command below
# localectl list-x11-keymap-layouts

KBLOCALE="pt"

# Set your keyboard layout on X11
localectl set-x11-keymap $KBLOCALE

# Turn on swap
sudo swapon /swap/swapfile

# Reboot to apply changes
shutdown -r now
exit 0
