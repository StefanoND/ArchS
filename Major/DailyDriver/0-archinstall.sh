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
    if [[ `lsblk | grep -w $nvme0n1p1` ]]; then
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
# Partition names
#lsblk
#read -p "Enter the name of the EFI partition (eg. sda1, nvme0n1p1): " nvme0n1p1
#read -p "Enter the name of the ROOT partition (eg. sda2, nvme0n1p2): " nvme0n1p2
#read -p "Enter the name of the HOME partition (eg. sda3, nvme0n1p3): " nvme0n1p3

# Sync time
timedatectl set-ntp true
sleep 1s

echo
echo 'Modprobing dm-crypt and dm-mod'
echo
modprobe dm-crypt
sleep 1s
modprobe dm-mod
sleep 1s

echo
echo "Encrypting \"/dev/$nvme0n1p2\", type \"YES\" must be uppercase!"
echo
sleep 1s
cryptsetup luksFormat -v -s 512 -h sha512 /dev/$nvme0n1p2
sleep 1s

echo
echo "Encrypting \"/dev/$nvme0n1p3\", type \"YES\" must be uppercase!"
echo
sleep 1s
cryptsetup luksFormat -v -s 512 -h sha512 /dev/$nvme0n1p3
sleep 1s

echo
echo "Opening \"/dev/$nvme0n1p2\" use your encryption password you setup earlier"
echo
sleep 1s
cryptsetup open /dev/$nvme0n1p2 root
sleep 1s

echo
echo "Opening \"/dev/$nvme0n1p3\" use your encryption password you setup earlier"
echo
sleep 1s
cryptsetup open /dev/$nvme0n1p3 home
sleep 1s

# Format partitions
mkfs.fat -F 32 /dev/$nvme0n1p1
mkfs.btrfs -f /dev/$nvme0n1p2
mkfs.btrfs -f /dev/mapper/root
mkfs.btrfs -f /dev/$nvme0n1p3
mkfs.btrfs -f /dev/mapper/home
sleep 1s

# Mount the partitions
#mount /dev/$nvme0n1p2 /mnt
mount /dev/mapper/root /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@swap
btrfs su cr /mnt/@snapshots
btrfs su cr /mnt/@cache
btrfs su cr /mnt/@log
sleep 1s
umount /mnt

#mount /dev/$nvme0n1p3 /mnt
mount /dev/mapper/home /mnt
btrfs su cr /mnt/@home
sleep 1s
umount /mnt

# # remove "space_cache" if on a VM without disk fully allocated
# mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@ /dev/$nvme0n1p2 /mnt
# mkdir -p /mnt/{boot,swap,home,.snapshots,opt,var/{cache,log}}
# mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@opt /dev/$nvme0n1p2 /mnt/opt
# mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@swap /dev/$nvme0n1p2 /mnt/swap
# mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@snapshots /dev/$nvme0n1p2 /mnt/.snapshots
# mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@cache /dev/$nvme0n1p2 /mnt/var/cache
# mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@log /dev/$nvme0n1p2 /mnt/var/log
# mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@home /dev/$nvme0n1p3 /mnt/home
# mount /dev/$nvme0n1p1 /mnt/boot

# remove "space_cache" if on a VM without disk fully allocated
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@ /dev/mapper/root /mnt
mkdir -p /mnt/{boot,swap,home,.snapshots,opt,var/{cache,log}}
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@opt /dev/mapper/root /mnt/opt
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@swap /dev/mapper/root /mnt/swap
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@snapshots /dev/mapper/root /mnt/.snapshots
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@cache /dev/mapper/root /mnt/var/cache
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@log /dev/mapper/root /mnt/var/log
mount -o compress=zstd:3$SPCACHE,noatime,ssd,defaults,x-mount.mkdir,subvol=@home /dev/mapper/home /mnt/home
mount /dev/$nvme0n1p1 /mnt/boot

# Prep
# Install base packages (add intel-ucode if you're using an intel CPU or amd-ucode if using amd CPU or none if in a VM w/o passthrough)
pacstrap -K /mnt base base-devel btrfs-progs efibootmgr linux linux-firmware linux-headers linux-lts linux-lts-headers dkms neovim pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack pipewire-zeroconf gst-plugin-pipewire wireplumber qpwgraph pulsemixer pciutils usbutils plymouth
sleep 1s

# Populate fstab
genfstab -Up /mnt >> /mnt/etc/fstab
sleep 1s

# Copy current folder to /mnt
cp -r ArchS /mnt/
sleep 1s

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    touch /mnt/hasnvidia.gpu
    echo 'y' > /mnt/hasnvidia.gpu
    sleep 1s
fi

# chroot into mnt
arch-chroot /mnt ./ArchS/Major/DailyDriver/0.1-archinstall.sh
sleep 2s

# Remove ArchS from /mnt
echo
echo 'Removing /mnt/ArchS'
echo
rm -rf /mnt/ArchS
sleep 2s

# Unmount all drives (-R will remove everything mounted to that path)
echo
echo 'Unmounting all drives'
echo
umount -R /mnt/sys
sleep 2s

umount -R /mnt
sleep 2s

echo
echo "Done..."
echo
echo "Press Y to reboot now or N if you plan to manually reboot later."
echo
read REBOOT
if [ ${REBOOT,,} = y ]; then
    shutdown -r now
fi
exit 0
