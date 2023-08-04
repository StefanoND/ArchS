#!/bin/bash

SPCACHE=",space_cache=v2"
sleep 1s
if [[ `pacman -Q | grep -i 'virtualbox-guest-utils'` ]]; then
    SPCACHE=""
fi

VALIDPARTONE=n
VALIDPARTTWO=n
VALIDPARTTHREE=n
nvme0n1p1=null
nvme0n1p2=null
nvme0n1p3=null

lsblk
while [[ ${VALIDPARTONE,,} = n ]]; do
    read -p "Enter the name of the EFI partition (eg. sda1, nvme0n1p1): " PARTONE
    nvme0n1p1=$PARTONE
    if [[ `lsblk | grep $nvme0n1p1` ]]; then
        VALIDPARTONE=y
    else
        echo
        printf "Could not find /dev/$nvme0n1p1, try again"
        echo
    fi
done
while [[ ${VALIDPARTTWO,,} = n ]]; do
    read -p "Enter the name of the ROOT partition (eg. sda2, nvme0n1p2): " PARTTWO
    nvme0n1p2=$PARTTWO
    if [[ `lsblk | grep $nvme0n1p2` ]]; then
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
    if [[ `lsblk | grep $nvme0n1p3` ]]; then
        VALIDPARTTHREE=y
    else
        echo
        printf "Could not find /dev/$nvme0n1p3, try again"
        echo
    fi
done
# Partition names
#lsblk
#read -p "Enter the name of the EFI partition (eg. sda1, nvme0n1p1): " nvme0n1p1
#read -p "Enter the name of the ROOT partition (eg. sda2, nvme0n1p2): " nvme0n1p2
#read -p "Enter the name of the HOME partition (eg. sda3, nvme0n1p3): " nvme0n1p3

# Sync time
timedatectl set-ntp true

# Format partitions
mkfs.fat -F 32 /dev/$nvme0n1p1
mkfs.btrfs -f /dev/$nvme0n1p2
mkfs.btrfs -f /dev/$nvme0n1p3

# Mount the partitions
mount /dev/$nvme0n1p2 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@swap
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@cache
btrfs su cr /mnt/@log
umount /mnt

mount /dev/$nvme0n1p3 /mnt
btrfs su cr /mnt/@home
umount /mnt

# remove "space_cache" if on a VM without disk fully allocated
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@ /dev/$nvme0n1p2 /mnt
mkdir -p /mnt/{boot,swap,home,.snapshots,opt,var/{cache,log}}
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@opt /dev/$nvme0n1p2 /mnt/opt
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@swap /dev/$nvme0n1p2 /mnt/swap
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@snapshots /dev/$nvme0n1p2 /mnt/.snapshots
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@cache /dev/$nvme0n1p2 /mnt/var/cache
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@log /dev/$nvme0n1p2 /mnt/var/log
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@home /dev/$nvme0n1p3 /mnt/home
mount /dev/$nvme0n1p1 /mnt/boot

# Prep
# Install current archlinux keyring and sync packages
pacman -Sy && pacman -S archlinux-keyring --noconfirm --needed && pacman -Syy

# Install base packages (add intel-ucode if you're using an intel CPU or amd-ucode if using amd CPU or none if in a VM w/o passthrough)
pacstrap -K /mnt base base-devel btrfs-progs efibootmgr linux linux-firmware linux-headers linux-lts linux-lts-headers dkms neovim pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber qpwgraph pulsemixer

# Populate fstab
genfstab -Up /mnt >> /mnt/etc/fstab

# Copy current folder to /mnt
cp -r ArchS /mnt/

# chroot into mnt
arch-chroot /mnt ./ArchS/Major/DailyDriver/0.1-archinstall.sh

# Remove ArchS from /mnt/
rm -rf /mnt/ArchS
sleep 1s

# Unmount all drives (-R will remove everything mounted to that path)
umount -R /mnt

# Reboot
shutdown -r now
exit 0
