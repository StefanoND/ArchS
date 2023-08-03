# WIP
# Arch Linux
# (U)EFI system

### Change keyboard layout if needed (optional)
    loadkeys pt-latin9

###   To list keymaps available
    localectl list-keymaps

###   For more finetuned you can use grep
    localtectl list-keymaps | grep -i "pt"

### Increase fontsize (optional)
    setfont ter-p20b

# Wifi (If not using cable)

### Connect to WLAN
iwctl --passphrase PASSWORD station wlan0 connect NETWORK

### Check internet connection
ping -c4 www.archlinux.org

# Time

### Sync time
    timedatectl set-ntp true
    
# Partitioning

### Partition your drive

#### To check the correct one use lsblk
    lsblk

### Wipe everything in your drive
    gdisk /dev/nvme0n1 # or /dev/sda

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
### Root partition
    Size: XX
    Type: 8304
    Name: root
### Home partition
    Size: XX
    Type: 8302
    Name: home

#### We'll create a swapfile instead of partition

# Formatting and mounting

### Format partitions
    mkfs.fat -F 32 /dev/nvme0n1p1
    mkfs.btrfs -f /dev/nvme0n1p2
    mkfs.btrfs -f /dev/nvme0n1p3

### Mount the partitions
    mount /dev/nvme0n1p2 /mnt
    btrfs su cr /mnt/@
    btrfs su cr /mnt/@opt
    btrfs su cr /mnt/@swap
    btrfs su cr /mnt/@snapshots
    btrfs su cr /mnt/@cache
    btrfs su cr /mnt/@log
    umount /mnt

    mount /dev/nvme0n1p3 /mnt
    btrfs su cr /mnt/@home
    umount /mnt

    # remove "space_cache" if on a VM without disk fully allocated
    mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@ /dev/nvme0n1p2 /mnt
    mkdir -p /mnt/{boot,swap,home,.snapshots,opt,var/{cache,log}}
    mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@opt /dev/nvme0n1p2 /mnt/opt
    mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@swap /dev/nvme0n1p2 /mnt/swap
    mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots
    mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@cache /dev/nvme0n1p2 /mnt/var/cache
    mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@log /dev/nvme0n1p2 /mnt/var/log
    mount -o compress=zstd:3,space_cache,noatime,ssd,defaults,x-mount.mkdir,subvol=@home /dev/nvme0n1p3 /mnt/home # nvme0n1p3 NOT p2
    mount /dev/nvme0n1p1 /mnt/boot

# Prep

### Install current archlinux keyring and sync packages
    pacman -Sy && pacman -S archlinux-keyring --noconfirm --needed && pacman -Syy

### Install base packages (add intel-ucode if you're using an intel CPU or amd-ucode if using amd CPU or none if in a VM w/o passthrough)
    pacstrap -K /mnt base base-devel btrfs-progs linux linux-firmware linux-headers linux-lts linux-lts-headers dkms neovim

### Populate fstab
    genfstab -Up /mnt >> /mnt/etc/fstab

### chroot into mnt
    arch-chroot /mnt /bin/bash

### Add btrfs and setfont to mkinitcpio's binaries
    sed -i 's/BINARIES=()/BINARIES=(btrfs setfont)/g' /etc/mkinitcpio.conf

#### Add "btrfs" before "filesystems": 
#### HOOKS=(base udev autodetect modconf kms keyboard btrfs keymap consolefont block encrypt filesystems fsck)

### Update mkinitcpio
    mkinitcpio -P

### Create swapfile (Change size to your liking)
#### We'll turn it on later
    btrfs filesystem mkswapfile --size 16G --uuid clear /swap/swapfile

### Install networking, dhcp, and other useful pkgs
    pacman -S networkmanager dhcpcd nvim git curl pacman-contrib bash-completion --noconfirm --needed

### Enable dhcp
    systemctl enable dhcpcd@enpXsX

### To check your network card use the following command
    ip link

### Enable Services
    systemctl enable NetworkManager
    systemctl enable fstrim.timer

# Bootloader

### Make sure we have our efivars for installing the bootloader
    mount -t efivarfs efivarfs /sys/firmware/efi/efivars/

### Install systemd-boot
    bootctl install

### Configure systemd-boot
    nvim /boot/loader/loader.conf

###   Make sure it looks like below
#### loader.conf
    default arch.conf
    timeout 3
    console-mode max
    editor no

### Create arch.conf
    nvim /boot/loader/entries/arch.conf

### Make sure it looks like below
#### arch.conf
    title Arch
    linux /vmlinuz-linux
    initrd /initramfs-linux.img
    # initrd /intel-ucode.img # Add this line if you're using an intel CPU

### Create arch-lts.conf
    nvim /boot/loader/entries/arch-lts.conf

### Make sure it looks like below
#### arch-lts.conf
    title Arch (LTS)
    linux /vmlinuz-linux-lts
    initrd /initramfs-linux-lts.img
    # initrd /intel-ucode.img # Add this line if you're using an intel CPU

### Add the PARTUUID to arch.conf aswell
    RPARTUUID="$(blkid -s PARTUUID -o value /dev/nvme0n1p2)"
    printf "options root=PARTUUID=$RPARTUUID rootflags=subvol=@ rw" >> /boot/loader/entries/arch.conf
    printf "options root=PARTUUID=$RPARTUUID rootflags=subvol=@ rw" >> /boot/loader/entries/arch-lts.conf

### Check if it worked
    cat /boot/loader/entries/arch-lts.conf
    cat /boot/loader/entries/arch.conf

# NVIDIA ONLY

### If you're using NVidia GPU
    pacman -S nvidia-dkms libglvnd nvidia-utils opencl-nvidia lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings --noconfirm --needed

### Enable NVdia stuff, must be in that order
    nvim /etc/mkinitcpio.conf

### Uncomment MODULES=() and add nvidia nvidia_modeset nvidia_uvm nvidia_drm
#### /etc/mkinitcpio.conf
    [...]
    MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
    [...]

### Also make sure they're enabled at boot time
    nvim /boot/loader/entries/arch.conf

### Add nvidia-drm.modeset=1 at the end of options root=PARTUUID....
#### /boot/loader/entries/arch.conf
    [...]
    options root=PARTUUID=... rw nvidia-drm.modeset=1

### Make a hook for pacman so we can update and build the new drivers or we'll get blank screen on load
### Create hooks folder
    mkdir /etc/pacman.d/hooks

### Add nvidia hook
    nvim /etc/pacman.d/hooks/nvidia.hook


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

### Update bootctl and enable auto-update service
    bootctl update
    systemctl enable systemd-boot-update.service

### Check bootctl status
    bootctl status

# Create root password
    passwd

# Locale
### Generate locale uncomment the locales you want
#### You can press "/" and the name of the locale to search for it
    # nvim /etc/locale.gen
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
    sed -i 's/#en_US ISO-8859-1/en_US ISO-8859-1/g' /etc/locale.gen

### Generate locale
    locale-gen

### Set the system language and export it
    echo LANG=en_US.UTF-8 > /etc/locale.conf
    export LANG=en_US.UTF-8

### Set keyboard layout permanent (optional)
    echo KEYMAP=pt-latin9 > /etc/vconsole.conf
    export KEYMAP=pt-latin9

# Set hostname and localhost (change MYHOSTNAME to your liking)
    echo MYHOSTNAME > /etc/hostname
    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1       localhost" >> /etc/hosts
    echo "127.0.1.1 MYHOSTNAME.localdomain MYHOSTNAME" >> /etc/hosts

# Time
### Set you system time
    ln -sf /usr/share/zoneinfo/Europe/Lisbon /etc/localtime

### Generate /etc/adjtime
    hwclock --systohc --utc

# Pacman
### Make a backup of your mirrorlist
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old

### Use fastest mirrors for our mirrorlist
    rankmirrors -n 20 /etc/pacman.d/mirrorlist.old > /etc/pacman.d/mirrorlist

### Change pacman.conf
    # nvim /etc/pacman.conf
    sed -i "s/\#Color/Color\nILoveCandy/g" /etc/pacman.conf
    sed -i 's/#[multilib]/[multilib]/g' /etc/pacman.conf
    sed -i 's/#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/g' /etc/pacman.conf
    echo '' >> /etc/pacman.conf
    echo '[valveaur]' >> /etc/pacman.conf
    echo 'SigLevel = Optional TrustedOnly' >> /etc/pacman.conf
    echo 'Server = http://repo.steampowered.com/arch/valveaur' >> /etc/pacman.conf

###   Uncomment Multilib, add Valve repo to pacman.conf
###   Uncomment Color and add ILoveCandy if you want
####   pacman.conf
    # Color       # Colored terminal
    # ILoveCandy  # Pacman progressbar
    # [...]
    # [multilib]  # 32-bit support
    # Include = /etc/pacman.d/mirrorlist
    # [...]
    # [valveaur]  # Valve AUR
    # SigLevel = Optional TrustedOnly
    # Server = http://repo.steampowered.com/arch/valveaur

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
    EDITOR=nvim sudo -E visudo

### visudo
    # %wheel ALL=(ALL:ALL) ALL
    # [...]
    # Defaults insults # Replace "Sorry, try again." with humorous insults.
    # Defaults rootpw # Will require root password for sudo command
    # Defaults timestamp_type=global # All terminals "share the same timeout" for sudo password
    # Defaults passwd_timeout=0 # I'm not your parent

# Audio

### Install pipewire and its stuff (Remove conflicting)
    pacman -S pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber qpwgraph pulsemixer --noconfirm --needed

# Desktop Environment
### Instal Xorg, sddm and plasma
    pacman -S xorg-server xorg-apps xorg-xinit xorg-twm xorg-xclock plasma sddm --noconfirm --needed

### Install terminal and other pkgs
    pacman -S wezterm wezterm-shell-integration wezterm-terminfo cups openssh firewalld acpi acpi_call acpid avahi bluez bluez-utils hplip --noconfirm --needed

### Enable services
    systemctl enable sddm
    systemctl enable cups.service
    systemctl enable avahi-daemon
    systemctl enable sshd
    systemctl enable firewalld
    systemctl enable bluetooth
    systemctl enable acpid

# Local config

### Let's do some stuff in the user account, change USER to the one you created earlier
    sudo -u USER bash

### Enable pipewire and pipewire-pulse
    systemctl --user enable pipewire
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

### Turn on swap
    sudo swapon /swap/swapfile

### Reboot to apply changes
    shutdown -r now

# Done
