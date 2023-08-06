#!/bin/bash

# To check for available keymaps use the command below
# localectl list-x11-keymap-layouts

KBLOCALE="pt"
VALIDPARTTWO=n
VALIDPARTTHREE=n
nvme0n1p2=null
nvme0n1p3=null

# Set your keyboard layout on X11
localectl set-x11-keymap $KBLOCALE

# Turn on swap
sudo swapon /swap/swapfile
sleep 1s

lsblk
while [[ ${VALIDPARTTWO,,} = n ]]; do
    read -p "Enter the name of the ROOT partition (eg. sda2, nvme0n1p2): " PARTTWO
    nvme0n1p2=$PARTTWO
    if [[ `lsblk | grep -w $nvme0n1p2` ]]; then
        VALIDPARTTWO=y
    else
        echo
        printf "Could not find /dev/$nvme0n1p2, try again"
        echo
    fi
done
while [[ ${VALIDPARTTHREE,,} = n ]]; do
    read -p "Enter the name of the HOME partition (eg. sda3, nvme0n1p3): " PARTTHREE
    nvme0n1p3=$PARTTHREE
    if [[ `lsblk | grep -w $nvme0n1p3` ]]; then
        VALIDPARTTHREE=y
    else
        echo
        printf "Could not find /dev/$nvme0n1p3, try again"
        echo
    fi
done

echo
echo "Enabling btrfs's automatic balance at 10% threshold"
echo
sudo bash -c "echo 10 > /sys/fs/btrfs/$(blkid -s UUID -o value /dev/$nvme0n1p2)/allocation/data/bg_reclaim_threshold"
sleep 1s
sudo bash -c "echo 10 > /sys/fs/btrfs/$(blkid -s UUID -o value /dev/$nvme0n1p3)/allocation/data/bg_reclaim_threshold"
sleep 1s

# Reboot to apply changes
shutdown -r now
exit 0
