# WIP
# Arch Linux
# (U)EFI system

### Change keyboard layout if needed (Default is us)
    loadkeys pt-latin9

###   To list keymaps available
    localectl list-keymaps

###   For more finetuned you can use grep
    localtectl list-keymaps | grep -i "pt"

# Time

### Sync time
    timedatectl set-ntp true
    
# Partitioning

### Partition your drive

#### To check the correct one use lsblk
    lsblk

### Wipe everything in your drive
    gdisk /dev/sda

### Press these keys
    x # Expert mode
    z # Zap (A.K.A.) Wipe drive
    Y # Confirm
    Y # Confirm

# Partition Layout

### Change sda to the drive you want
    cgdisk /dev/sda

### Label gpt

### Boot partition
    Size: 2GiB
    Type: EF00
    Name: boot
### Swap partition
    Size: 16GiB
    Type: 8200
    Name: swap
### Root partition
    Size: XX
    Type: 8304
    Name: root
### Home partition
    Size: rest
    Type: 8302
    Name: home
    
# Formatting and mounting

### Format partitions
    mkfs.fat -F 32 /dev/sda1
    mkswap /dev/sda2
    swapon /dev/sda2
    mkfs.btrfs -f /dev/sda3
    mkfs.ext4 /dev/sda4

### Mount the partitions
    mount /dev/sda3 /mnt
    mkdir /mnt/boot
    mkdir /mnt/home
    mount /dev/sda1 /mnt/boot
    mount /dev/sda4 /mnt/home

# Prep
### Install base packages (add intel-ucode if you're using an intel CPU)
    pacstrap -K /mnt base base-devel linux linux-firmware linux-headers linux-lts linux-lts-headers dkms neovim

### Populate fstab
    genfstab -U -p /mnt >> /mnt/etc/fstab

### chroot into mnt
    arch-chroot /mnt /bin/bash

### Usually not required
    mkinitcpio -P

### Install networking, dhcp, and other useful pkgs
    pacman -S networkmanager dhcpcd nano git curl pacman-contrib bash-completion --noconfirm --needed

### Enable dhcp
    systemctl enable dhcpcd@enpXsX.service

### To check your network card use the following command
    ip link

### Enable Network Manager service
    systemctl enable NetworkManager.service

### If you're installing in an SSD, enable trim
    systemctl enable fstrim.timer

# Bootloader

### Make sure we have our efivars for installing the bootloader
    mount -t efivarfs efivarfs /sys/firmware/efi/efivars/

### Install systemd-boot
    bootctl install

### Configure systemd-boot
    nano /boot/loader/loader.conf

###   Make sure it looks like below
#### loader.conf
    default arch.conf
    timeout 3
    console-mode max
    editor no

### Create arch.conf
    nano /boot/loader/entries/arch.conf

### Make sure it looks like below
#### arch.conf
    title Arch
    linux /vmlinuz-linux
    initrd /initramfs-linux.img
    # initrd /intel-ucode.img # Add this line if you're using an intel CPU

### Create arch-lts.conf
    nano /boot/loader/entries/archlts.conf

### Make sure it looks like below
#### arch-lts.conf
    title Arch (LTS)
    linux /vmlinuz-linux-lts
    initrd /initramfs-linux-lts.img
    # initrd /intel-ucode.img # Add this line if you're using an intel CPU

### Add the PARTUUID to arch.conf aswell
    printf "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda3) rw" >> /boot/loader/entries/arch.conf
    printf "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda3) rw" >> /boot/loader/entries/arch-lts.conf

# NVIDIA ONLY

### If you're using NVidia GPU
    pacman -S nvidia-dkms libglvnd nvidia-utils opencl-nvidia lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings --noconfirm --needed

### Enable NVdia stuff, must be in that order
    nano /etc/mkinitcpio.conf

### Uncomment MODULES=() and add nvidia nvidia_modeset nvidia_uvm nvidia_drm
#### /etc/mkinitcpio.conf
    [...]
    MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
    [...]

### Also make sure they're enabled at boot time
    nano /boot/loader/entries/arch.conf

### Add nvidia-drm.modeset=1 at the end of options root=PARTUUID....
#### /boot/loader/entries/arch.conf
    [...]
    options root=PARTUUID=... rw nvidia-drm.modeset=1

### Make a hook for pacman so we can update and build the new drivers or we'll get blank screen on load
### Create hooks folder
    mkdir /etc/pacman.d/hooks

### Add nvidia hook
    nano /etc/pacman.d/hooks/nvidia.hook


### Make sure it looks like below
#### nvidia.hook
    [Trigger]
    Operation=Install
    Operation=Upgrade
    Operation=Remove
    Type=Package
    Target=nvidia

    [Action]
    Depends=mkinitcpio
    When=PostTransaction
    Exec=/usr/bin/mkinitcpio -P
# End of NVIDIA ONLY
# Update bootctl and check status

### Update bootctl
    bootctl update

### Check bootctl status
    bootctl status

# Create root password
    passwd

# Locale
### Generate locale uncomment the locales you want
#### You can press "/" and the name of the locale to search for it
    nano /etc/locale.gen

### Generate locale
    locale-gen

### Set the system language
    echo LANG=en_US.UTF-8 > /etc/locale.conf

### Export it aswell
    export LANG=en_US.UTF-8

### Set keyboard layout permanent (Not needed for US keyboard, change pt-latin9 to your layout)
    echo KEYMAP=pt-latin9 > /etc/vconsole.conf

# Set hostname (change MYHOSTNAME to your liking)
    echo MYHOSTNAME > /etc/hostname

# Time
### Set you system time
    ln -sf /usr/share/zoneinfo/Europe/Lisbon /etc/localtime

### Generate /etc/adjtime
    hwclock --systohc --utc

# Pacman
### Make a backup of your mirrorlist
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old

# Use fastest mirrors for our mirrorlist
    rankmirrors -n 20 /etc/pacman.d/mirrorlist.old > /etc/pacman.d/mirrorlist

# Change pacman.conf
    nano /etc/pacman.conf

###   Uncomment Multilib, add Valve repo to pacman.conf
###   Uncomment Color and add ILoveCandy if you want
####   pacman.conf
    Color       # Colored terminal
    ILoveCandy  # Pacman progressbar
    [...]
    [multilib]  # 32-bit support
    SigLevel = PackageRequired
    Include = /etc/pacman.d/mirrorlist
    [...]
    [valveaur]  # Valve AUR
    SigLevel = Optional TrustedOnly
    Server = http://repo.steampowered.com/arch/valveaur

### Update pacman repo cache
    pacman -Syy

# Users and groups

### Create a new group, rename GROUP to your liking
    groupadd GROUP

### Creates new user, makes 'GROUP' primary group and creates sys,...,storage groups
### Change the GROUP to be the same as GROUP above
### Rename USER to your liking
    useradd -m -g GROUP -G sys,lp,kvm,network,power,wheel,storage -s /bin/bash USER

### Give a password to it, rename USER to the one you set above
    passwd USER

# Visudo

### Grant sudo privileges to wheel, remove the "#" before "%wheel"
### And defaults to using the root password to run sudo commands
### instead of users' password
    EDITOR=nano visudo

### visudo
    %wheel ALL=(ALL:ALL) ALL
    [...]
    Defaults insults # Replace "Sorry, try again." with humorous insults.
    Defaults rootpw # Will require root password for sudo command
    Defaults timestamp_type=global # All terminals "share the same timeout" for sudo password

# Audio

### Install pipewire and its stuff (Remove conflicting)
    pacman -S pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber qpwgraph pulsemixer --noconfirm --needed

# Desktop Environment
### Instal Xorg, sddm and plasma
    pacman -S xorg-server xorg-apps xorg-xinit xorg-twm xorg-xclock plasma sddm --noconfirm --needed

### Enable sddm service
    systemctl enable sddm.service

### Install a terminal
    pacman -S wezterm wezterm-shell-integration wezterm-terminfo --noconfirm --needed

# Local config

### Let's do some stuff in the user account, change USER to the one you created earlier
    sudo -u USER bash

### Enable pipewire
    systemctl --user enable pipewire

### Enable pipewire-pulse
    systemctl --user enable pipewire-pulse

### Create config file of pulsemixer ($HOME/.config/pulsemixer.cfg)
    pulsemixer --create-config

### Make GUI apps use sudo instead of su
    kwriteconfig5 --file kdesurc --group super-user-command --key super-user-command sudo

### Leave USER go back to root
    exit

### Leave chroot
    exit

# Finalizing

### Unmount all drives
### -R will remove everything mounted to that path
    umount -R /mnt

### Reboot
    shutdown -r now

### Login and change the layout of X11
### Set your keyboard layout on X11
    localectl set-x11-keymap pt

### To check for available keymaps use
    localectl list-x11-keymap-layouts

### Reboot to apply changes

# Done
