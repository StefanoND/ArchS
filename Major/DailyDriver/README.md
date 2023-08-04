# WIP
# Arch Linux
# (U)EFI system

## systemd-boot btrfs KDE + i3

# Load keyboard layout (replace pt with de, fr, es if needed)
    loadkeys pt-latin1

# Increase font size (optional)
    setfont ter-p20b

# Check drive
    lsblk

# Wipe drive
    gdisk /dev/nvme0n1

### Type these keys followed by Enter/Return after each one in that order (case sensitive)
    x # Expert mode
    z # Zap/Wipe drive
    Y # Confirm
    Y # Confirm

# Create partitions
    cgdisk /dev/nvme0n1

### Boot
    Size: 2GiB
    Type: EF00
    Name: boot

### Root
    Size: XX
    Type: 8304
    Name: root

### Home
    Size: XX
    Type: 8302
    Name: home

# Sync get latest arhclinux-keyring and install git

### Sync pkgs download archlinux-keyring and force resync pkgs
    pacman -Syy && pacman -S archlinux-keyring --noconfirm && pacman -Syy

### Install git
    pacman -S git --noconfirm

### Clone this repo
    git clone https://github.com/StefanoND/ArchS.git
    cd ArchS/Major/DailyDriver

### Start the script
    ./0-archinstall.sh
