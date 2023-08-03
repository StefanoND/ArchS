#!/bin/bash

SRCPATH="$(cd $(dirname $0) && pwd)"

# Partition names
lsblk
read -p "Enter the name of the DRIVE you want to partition (eg. nvme0n1): " nvme0n1
read -p "Enter the name of the EFI partition (eg. nvme0n1p1): " nvme0n1p1
read -p "Enter the name of the ROOT partition (eg. nvme0n1p2): " nvme0n1p2
read -p "Enter the name of the HOME partition (eg. nvme0n1p3): " nvme0n1p3

# Increase fontsize (optional)
setfont ter-p20b

# Sync time
timedatectl set-ntp true

# Partitioning
# Wipe everything in your drive
gdisk /dev/$nvme0n1 # or /dev/sda
# x z Y Y

# Layout
# Change sda to the drive you want
cgdisk /dev/$nvme0n1

### Label gpt

# Boot partition
#    Size: 2GiB
#    Type: EF00
#    Name: boot
# Root partition
#    Size: XX
#    Type: 8304
#    Name: root
# Home partition
#    Size: XX
#    Type: 8302
#    Name: home

# We'll create a swapfile instead of partition

# Formatting and mounting
# Format partitions
mkfs.fat -F 32 /dev/$nvme0n1p1
mkfs.btrfs -f /dev/$nvme0n1p2
mkfs.btrfs -f /dev/$nvme0n1p3

### Mount the partitions
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
mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@ /dev/$nvme0n1p2 /mnt
mkdir -p /mnt/{boot,swap,home,.snapshots,opt,var/{cache,log}}
mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@opt /dev/$nvme0n1p2 /mnt/opt
mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@swap /dev/$nvme0n1p2 /mnt/swap
mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@snapshots /dev/$nvme0n1p2 /mnt/.snapshots
mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@cache /dev/$nvme0n1p2 /mnt/var/cache
mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@log /dev/$nvme0n1p2 /mnt/var/log
mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@home /dev/$nvme0n1p3 /mnt/home
mount /dev/$nvme0n1p1 /mnt/boot

# Prep
# Install current archlinux keyring and sync packages
pacman -Sy && pacman -S archlinux-keyring --noconfirm --needed && pacman -Syy

# Install base packages (add intel-ucode if you're using an intel CPU or amd-ucode if using amd CPU or none if in a VM w/o passthrough)
pacstrap -K /mnt base base-devel btrfs-progs linux linux-firmware linux-headers linux-lts linux-lts-headers dkms neovim pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber qpwgraph pulsemixer

# Populate fstab
genfstab -Up /mnt >> /mnt/etc/fstab

# chroot into mnt
arch-chroot /mnt ."${SRCPATH}"/0.1-archinstall.sh

# Unmount all drives (-R will remove everything mounted to that path)
umount -R /mnt

# Reboot
shutdown -r now
exit 0
