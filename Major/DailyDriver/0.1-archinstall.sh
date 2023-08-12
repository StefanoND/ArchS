#!/bin/bash

MYHOSTNAME="arch"
TIMEZONE="Europe/Lisbon"
USERNAME="archuser"
GROUPNAME="archuser"
SWAPSIZE="16G"
COUNTRIES="Germany,Portugal,Spain,France"
PROTOCOLS="https"
VALIDNIC=n
VALIDPARTTWO=n
nvme0n1p2=null

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

while [[ ${VALIDNIC,,} = n ]]; do
    ip link
    read -p "Enter the name of the NIC you want to enable dhcp (eg. enp0s3): " enp0s0
    if [[ `ip link | grep -w $enp0s0` ]]; then
        VALIDNIC=y
    else
        echo
        printf "Could not find $enp0s0, try again"
        echo
    fi
done

# Desktop Environment
# Instal Xorg, sddm and plasma
pacman -S networkmanager network-manager-applet dhcpcd neofetch dialog wpa_supplicant ibus mtools dosfstools xdg-user-dirs xdg-utils nfs-utils inetutils bind rsync sof-firmware ipset nss-mdns os-prober terminus-font exa bat gparted filelight xclip brightnessctl xf86-video-amdgpu xf86-video-nouveau xf86-video-intel xf86-video-qxl neovim nano git curl pacman-contrib bash-completion xorg-server xorg-apps xorg-xinit xorg-twm xorg-xclock libxcb plasma sddm sddm-kcm kde-gtk-config wezterm wezterm-shell-integration wezterm-terminfo cups ntp openssh acpi acpi_call acpid avahi bluez bluez-utils hplip reflector wget --noconfirm --needed
sleep 1s

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
sleep 1s

# Add btrfs to modules
sed -i 's/MODULES=()/MODULES=(btrfs vmd)/g' /etc/mkinitcpio.conf

# Add btrfs and setfont to mkinitcpio's binaries
sed -i 's/BINARIES=()/BINARIES=(btrfs setfont)/g' /etc/mkinitcpio.conf

# Add "btrfs" before "filesystems" and remove "fsck":
# HOOKS=(base udev autodetect modconf kms keyboard btrfs keymap encrypt consolefont block filesystems)
sed -i 's/HOOKS=(.*/HOOKS=(base udev autodetect modconf kms keyboard btrfs keymap encrypt consolefont block filesystems)/g' /etc/mkinitcpio.conf

# Compress initramfs image
sed -i 's/#COMPRESSION="zstd"/COMPRESSION="zstd"/g' /etc/mkinitcpio.conf

# Create swapfile (Change size to your liking)
# We'll turn it on later
btrfs filesystem mkswapfile --size $SWAPSIZE --uuid clear /swap/swapfile
sleep 1s

# Create root password
echo
echo 'Root password'
echo
passwd

# Locale
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#en_US ISO-8859-1/en_US ISO-8859-1/g' /etc/locale.gen
sleep 1s

# Generate locale
locale-gen
sleep 1s

# Set the system language and export it
echo LANG=en_US.UTF-8 > /etc/locale.conf
sleep 1s
export LANG=en_US.UTF-8

# Set keyboard layout permanent (optional)
echo KEYMAP=pt-latin1 > /etc/vconsole.conf
sleep 1s
export KEYMAP=pt-latin1

# Set hostname and localhost (change MYHOSTNAME to your liking at the top of this script)
echo $MYHOSTNAME > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $MYHOSTNAME.localdomain $MYHOSTNAME" >> /etc/hosts
sleep 1s

# Change pacman.conf
sed -i "s/#Color/Color\nILoveCandy/g" /etc/pacman.conf
sed -i "s/#ParallelDownloads.*/ParallelDownloads = 15/g" /etc/pacman.conf
sed -i 's/\#\[multilib\]/[multilib]/g' /etc/pacman.conf
sed -i '/^\[multilib\]/a Include = \/etc\/pacman.d\/mirrorlist' /etc/pacman.conf
echo '' >> /etc/pacman.conf
sleep 1s

# Update pacman repo cache
pacman -Syy
sleep 1s

# Create a new group, rename GROUPNAME to your liking at the top of this script
groupadd $GROUPNAME
sleep 1s

# Creates new user, makes 'GROUPNAME' primary group and creates sys,...,storage groups
# Rename USERNAME to your liking at the top of this script
useradd -m -g $GROUPNAME -G sys,lp,kvm,network,power,storage -s /bin/bash $USERNAME
sleep 1s

# Let's do some stuff in the user account before adding password
sudo -u $USERNAME bash -c 'systemctl --user enable pipewire'
sudo -u $USERNAME bash -c 'systemctl --user enable pipewire-pulse'
sudo -u $USERNAME bash -c 'pulsemixer --create-config'
sudo -u $USERNAME bash -c 'kwriteconfig5 --file kdesurc --group super-user-command --key super-user-command sudo'
sleep 1s

# Give a password to it, rename USER to the one you set above
echo
printf "$USERNAME password"
echo
passwd $USERNAME

# Bootloader
# Make sure we have our efivars for installing the bootloader
mount -t efivarfs efivarfs /sys/firmware/efi/efivars/
sleep 1s

# Enable services
systemctl enable dhcpcd@$enp0s0
systemctl enable NetworkManager
systemctl enable fstrim.timer
systemctl enable cups.service
systemctl enable avahi-daemon
systemctl enable sshd
systemctl enable bluetooth
systemctl enable acpid
systemctl enable ntpd
systemctl enable sddm
systemctl enable systemd-timesyncd.service
systemctl enable btrfs-scrub@-.timer
systemctl enable btrfs-scrub@home.timer
systemctl start systemd-timesyncd.service
sleep 1s

# Install systemd-boot
bootctl --path=/boot install
sleep 1s

# Configure systemd-boot
printf "default arch.conf\ntimeout 2\nconsole-mode max\neditor no\n" > /boot/loader/loader.conf

printf "title Arch\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\n" > /boot/loader/entries/arch.conf
printf "title Arch (LTS)\nlinux /vmlinuz-linux-lts\ninitrd /initramfs-linux-lts.img\n" > /boot/loader/entries/arch-lts.conf
printf "title Arch (Xanmod RT)\nlinux /vmlinuz-linux-xanmod-rt\ninitrd /initramfs-linux-xanmod-rt.img\n" > /boot/loader/entries/arch-xanmod-rt.conf
sleep 1s

if grep 'vendor' /proc/cpuinfo | uniq | grep -i -o amd; then
    pacman -S amd-ucode --noconfirm
    printf "initrd /amd-ucode.img\n" >> /boot/loader/entries/arch.conf
    printf "initrd /amd-ucode.img\n" >> /boot/loader/entries/arch-lts.conf
    printf "initrd /amd-ucode.img\n" >> /boot/loader/entries/arch-xanmod-rt.conf
    sleep 1s
fi
if grep 'vendor' /proc/cpuinfo | uniq | grep -i -o intel; then
    pacman -S intel-ucode --noconfirm
    printf "initrd /intel-ucode.img\n" >> /boot/loader/entries/arch.conf
    printf "initrd /intel-ucode.img\n" >> /boot/loader/entries/arch-lts.conf
    printf "initrd /intel-ucode.img\n" >> /boot/loader/entries/arch-xanmod-rt.conf
    sleep 1s
fi

printf "options cryptdevice=UUID=$(blkid -s UUID -o value /dev/$nvme0n1p2):root root=UUID=$(blkid -s UUID -o value /dev/mapper/root) rootflags=subvol=@ rw\n" >> /boot/loader/entries/arch.conf
printf "options cryptdevice=UUID=$(blkid -s UUID -o value /dev/$nvme0n1p2):root root=UUID=$(blkid -s UUID -o value /dev/mapper/root) rootflags=subvol=@ rw\n" >> /boot/loader/entries/arch-lts.conf
printf "options cryptdevice=UUID=$(blkid -s UUID -o value /dev/$nvme0n1p2):root root=UUID=$(blkid -s UUID -o value /dev/mapper/root) rootflags=subvol=@ rw\n" >> /boot/loader/entries/arch-xanmod-rt.conf

# NVIDIA ONLY
if [[ -f /hasnvidia.gpu ]]; then
    pacman -S nvidia-dkms libglvnd nvidia-utils opencl-nvidia lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings --noconfirm --needed
    sleep 1s

    # Enable NVdia modules, must be in that order
    sed -i 's/MODULES=(btrfs vmd)/MODULES=(btrfs vmd nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g' /etc/mkinitcpio.conf
    sleep 1s

    # Add nvidia-drm.modeset=1 at the end of options root=PARTUUID....
    sed -i "s/options cryptdevice=UUID=.*/options cryptdevice=UUID=$(blkid -s UUID -o value /dev/$nvme0n1p2):root root=UUID=$(blkid -s UUID -o value /dev/mapper/root) rootflags=subvol=@ rw nvidia-drm.modeset=1/g" /boot/loader/entries/arch.conf
    sed -i "s/options cryptdevice=UUID=.*/options cryptdevice=UUID=$(blkid -s UUID -o value /dev/$nvme0n1p2):root root=UUID=$(blkid -s UUID -o value /dev/mapper/root) rootflags=subvol=@ rw nvidia-drm.modeset=1/g" /boot/loader/entries/arch-lts.conf
    sed -i "s/options cryptdevice=UUID=.*/options cryptdevice=UUID=$(blkid -s UUID -o value /dev/$nvme0n1p2):root root=UUID=$(blkid -s UUID -o value /dev/mapper/root) rootflags=subvol=@ rw nvidia-drm.modeset=1/g" /boot/loader/entries/arch-xanmod-rt.conf

    # Make a hook for pacman so we can update and build the new drivers or we'll get blank screen on load
    # Create hooks folder
    mkdir -p /etc/pacman.d/hooks
    sleep 1s

    # Add nvidia hook
    printf "[Trigger]\nOperation=Install\nOperation=Upgrade\nOperation=Remove\nType=Package\nTarget=nvidia\n\n[Action]\nDepends=mkinitcpio\nWhen=PostTransaction\nExec=/usr/bin/mkinitcpio -P\n" > /etc/pacman.d/hooks/nvidia.hook
    sleep 1s
fi

# Update mkinitcpio
mkinitcpio -P
sleep 1s

# Update bootctl and enable auto-update service
bootctl --path=/boot update
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
sleep 1s

# Appending group "Wheel" to $USERNAME
usermod -aG wheel $USERNAME
sleep 1s

if ! [[ -d /home/$USERNAME/Documents ]]; then
    mkdir -p /home/$USERNAME/Documents
    sleep 1s
    chown -R $USERNAME:$GROUPNAME /home/$USERNAME/Documents
fi

echo
printf "Copying /ArchS to /home/$USERNAME/Documents/"
echo
cp -r /ArchS /home/$USERNAME/Documents/
sleep 1s

echo
printf "Giving ownership of \"/home/$USERNAME/Documents/ArchS\" to User: $USERNAME Group: $GROUPNAME"
echo
chown -R $USERNAME:$GROUPNAME /home/$USERNAME/Documents/ArchS
sleep 1s

echo
echo "Enabling autodefrag"
echo
sed -i 's/subvolid=/autodefrag,subvolid=/g' /etc/fstab

# Remove hasnvidia.gpu from /mnt
rm -f /hasnvidia.gpu
sleep 2s

exit 0
