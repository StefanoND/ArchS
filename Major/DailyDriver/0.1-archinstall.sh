#!/bin/bash

MYHOSTNAME="arch"
TIMEZONE="Europe/Lisbon"
USERNAME="archuser"
GROUPNAME="archuser"
SWAPSIZE="16G"
COUNTRIES="Germany,Portugal,Spain,France"
PROTOCOLS="https"
VALIDNIC=n

while [[ ${VALIDNIC,,} = n ]]; do
    ip link
    read -p "Enter the name of the NIC you want to enable dhcp (eg. enp0s3): " enp0s0
    if [[ `ip link | grep $enp0s0` ]]; then
        VALIDNIC=y
    else
        echo
        printf "Could not find $enp0s0, try again"
        echo
    fi
done

# Desktop Environment
# Instal Xorg, sddm and plasma
pacman -S networkmanager dhcpcd neovim git curl pacman-contrib bash-completion xorg-server xorg-apps xorg-xinit xorg-twm xorg-xclock plasma sddm wezterm wezterm-shell-integration wezterm-terminfo cups openssh firewalld acpi acpi_call acpid avahi bluez bluez-utils hplip pciutils reflector --noconfirm --needed

# Set you system time
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# Generate /etc/adjtime
hwclock --systohc --utc

# Use fastest mirrors for our mirrorlist
reflector -c $COUNTRIES -p $PROTOCOLS -a 6 --sort rate --save /etc/pacman.d/mirrorlist

printf "\--save /etc/pacman.d/mirrorlist\n--country $COUNTRIES\n--protocol $PROTOCOLS\n--age 6\n" > /etc/xdg/reflector/reflector.conf

sed -i 's/\\--/--/g' /etc/xdg/reflector/reflector.conf

# Enable reflector timer
systemctl enable reflector.timer

# Update pacman repo cache
pacman -Syy

# Add btrfs and setfont to mkinitcpio's binaries
sed -i 's/BINARIES=()/BINARIES=(btrfs setfont)/g' /etc/mkinitcpio.conf

# Add "btrfs" before "filesystems":
# HOOKS=(base udev autodetect modconf kms keyboard btrfs keymap consolefont block encrypt filesystems fsck)
sed -i 's/HOOKS=(.*/HOOKS=(base udev autodetect modconf kms keyboard btrfs keymap consolefont block encrypt filesystems fsck)/g' /etc/mkinitcpio.conf

# Update mkinitcpio
mkinitcpio -P

# Create swapfile (Change size to your liking)
# We'll turn it on later
btrfs filesystem mkswapfile --size $SWAPSIZE --uuid clear /swap/swapfile

# Create root password
passwd

# Locale
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#en_US ISO-8859-1/en_US ISO-8859-1/g' /etc/locale.gen

# Generate locale
locale-gen

# Set the system language and export it
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

# Set keyboard layout permanent (optional)
echo KEYMAP=pt-latin1 > /etc/vconsole.conf
export KEYMAP=pt-latin1

# Set hostname and localhost (change MYHOSTNAME to your liking at the top of this script)
echo $MYHOSTNAME > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $MYHOSTNAME.localdomain $MYHOSTNAME" >> /etc/hosts

# Change pacman.conf
sed -i "s/#Color/Color\nILoveCandy/g" /etc/pacman.conf
sed -i 's/#[multilib]/[multilib]/g' /etc/pacman.conf
sed -i "s/#Include = \/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/g" /etc/pacman.conf
echo '' >> /etc/pacman.conf
echo '[valveaur]' >> /etc/pacman.conf
echo 'SigLevel = Optional TrustedOnly' >> /etc/pacman.conf
echo 'Server = http://repo.steampowered.com/arch/valveaur' >> /etc/pacman.conf
echo '' >> /etc/pacman.conf

# Update pacman repo cache
pacman -Syy

# Create a new group, rename GROUPNAME to your liking at the top of this script
groupadd $GROUPNAME

# Creates new user, makes 'GROUPNAME' primary group and creates sys,...,storage groups
# Rename USERNAME to your liking at the top of this script
useradd -m -g $GROUPNAME -G sys,lp,kvm,network,power,storage -s /bin/bash $USERNAME

# Let's do some stuff in the user account before adding password
sudo -u $USERNAME bash -c 'systemctl --user enable pipewire'
sudo -u $USERNAME bash -c 'systemctl --user enable pipewire-pulse'
sudo -u $USERNAME bash -c 'pulsemixer --create-config'
sudo -u $USERNAME bash -c 'kwriteconfig5 --file kdesurc --group super-user-command --key super-user-command sudo'

# Give a password to it, rename USER to the one you set above
passwd $USERNAME

# Bootloader
# Make sure we have our efivars for installing the bootloader
mount -t efivarfs efivarfs /sys/firmware/efi/efivars/

# Enable services
systemctl enable dhcpcd@$enp0s0
systemctl enable NetworkManager
systemctl enable fstrim.timer
systemctl enable cups.service
systemctl enable avahi-daemon
systemctl enable sshd
systemctl enable firewalld
systemctl enable bluetooth
systemctl enable acpid
systemctl enable sddm

# Install systemd-boot
bootctl install

# Configure systemd-boot
printf "default arch.conf\ntimeout 3\nconsole-mode max\neditor no\n" > /boot/loader/loader.conf

printf "title Arch\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\n" > /boot/loader/entries/arch.conf
printf "title Arch\nlinux /vmlinuz-linux-lts\ninitrd /initramfs-linux-lts.img\n" > /boot/loader/entries/arch-lts.conf

if sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
    printf "initrd /amd-ucode.img\n" >> /boot/loader/entries/arch.conf
    printf "initrd /amd-ucode.img\n" >> /boot/loader/entries/arch-lts.conf
fi
if sudo grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
    printf "initrd /intel-ucode.img\n" >> /boot/loader/entries/arch.conf
    printf "initrd /intel-ucode.img\n" >> /boot/loader/entries/arch-lts.conf
fi

printf "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/$nvme0n1p2) rootflags=subvol=@ rw\n" >> /boot/loader/entries/arch.conf
printf "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/$nvme0n1p2) rootflags=subvol=@ rw\n" >> /boot/loader/entries/arch-lts.conf

# NVIDIA ONLY
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    pacman -S nvidia-dkms libglvnd nvidia-utils opencl-nvidia lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings --noconfirm --needed

    # Enable NVdia modules, must be in that order
    sed -i 's/#MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g' /etc/mkinitcpio.conf

    # Add nvidia-drm.modeset=1 at the end of options root=PARTUUID....
    sed -i "s/options root=PARTUUID=.*/options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/$nvme0n1p2) rootflags=subvol=@ rw nvidia-drm.modeset=1/g" /boot/loader/entries/arch.conf
    sed -i "s/options root=PARTUUID=.*/options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/$nvme0n1p2) rootflags=subvol=@ rw nvidia-drm.modeset=1/g" /boot/loader/entries/arch-lts.conf

    # Make a hook for pacman so we can update and build the new drivers or we'll get blank screen on load
    # Create hooks folder
    mkdir -p /etc/pacman.d/hooks

    # Add nvidia hook
    printf "[Trigger]\nOperation=Install\nOperation=Upgrade\nOperation=Remove\nType=Package\nTarget=nvidia\n\n[Action]\nDepends=mkinitcpio\nWhen=PostTransaction\nExec=/usr/bin/mkinitcpio -P\n" > /etc/pacman.d/hooks/nvidia.hook
fi
# Update bootctl and enable auto-update service
bootctl update
systemctl enable systemd-boot-update.service

# Visudo
echo
echo "Uncomment %wheel and add Defaults"
echo '%wheel ALL=(ALL:ALL) ALL'
echo 'Defaults insults'
echo 'Defaults rootpw'
echo 'Defaults timestamp_type=global'
echo 'Defaults passwd_timeout=0'
read -p "Open sudoers now?" c
EDITOR=nvim sudo -E visudo

usermod -aG wheel $USERNAME

echo 'Done'
echo
echo 'Exit chroot'
echo 'exit'
echo
echo 'Unmount everything'
echo 'umount -R /mnt'
echo
echo 'Reboot'
echo 'shutdown -r now'
exit
