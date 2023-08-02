# Not a runnable script file
# --------------------------------------------------------------------------------------------------------------------
# Check for problems
sudo systemctl --failed
sudo journalctl -p 3 -xb
#
# --------------------------------------------------------------------------------------------------------------------
#
# Recursively remove orphans and their configuration files (READ BEFORE MINDLESSLY ACCEPTING EVERYTHING)
sudo pacman -Qtdq | sudo pacman -Rns -
#
# --------------------------------------------------------------------------------------------------------------------
#
# In (most) some cases the command above is not enough, run this command to check dependency cycles (aka Circular Dependencies)
# Excessive dependencies (fullfiled more than once), unexplicit optionals, etc
# READ THEM CAREFULLY
sudo pacman -Qqd | sudo pacman -Rsu --print -
#
# After using the command above use this one to remove them
sudo pacman -Qqd | sudo pacman -Rsu -
#
# --------------------------------------------------------------------------------------------------------------------
#
# Configure Any Player (When it closes upon openning a video)
#
# Check if their Output and Codecs are using the correct drivers.
#
# "VDPAU Output" for Nvidia
# "Intel Output" for Intel (I don't know if that's the correct name)
# "Mesa Output" for AMD (I don't know if that's the correct name)
#
# --------------------------------------------------------------------------------------------------------------------
#
# Remove package ignoring dependencies (Don't shutdown/reboot before meeting those requirements)
# This is usually done when you want to install something that are modified versions of the package or installing from another source
# Or maybe even for updating the packages themselves but a dependency somehow is stopping it from happening
sudo pacman -Rdd <package-name>
#
# --------------------------------------------------------------------------------------------------------------------
#
# Check devices
sudo blkid
# Write down the numbers in UUID="XXXXXXXXXXXXXXXX"
#
# Automount with fstab
sudo nano /etc/fstab
#
UUID= /mnt/HDD ext4 user,users,exec,rw,suid,dev,nofail,x-gvfs-show,noatime 0 0
UUID= /mnt/SSD ext4 user,users,exec,rw,suid,dev,discard,nofail,x-gvfs-show,noatime 0 0
UUID= /mnt/HDD ntfs user,users,exec,rw,suid,dev,uid=USER,gid=USER,nofail,x-gvfs-show,noatime 0 0
UUID= /mnt/SSD ntfs user,users,exec,rw,suid,dev,uid=USER,gid=USER,discard,nofail,x-gvfs-show,noatime 0 0
#
# Note: You can change "auto" to the disk type if you know, (if formated by linux it's probably ext4, if formated by windows it's probably ntfs)
# Note2: You only have to add "uid=" and "gid=" if your doesn't automatically apply permission (such as NTFS)
#
# --------------------------------------------------------------------------------------------------------------------
#
# Create swap file, if you search the internet, it has become a religion, where each person says something different
# But the consensus seems to be the ones below:
#
# If you have 8GiB or less RAM. The SWAP size should be RAM * 1.5 (So 8GiB * 1.5 = 12GiB)
#
# If you have 16GiB or more RAM. The SWAP size should be around 4GiB-8GiB:
#     No SWAP file you may (extremely rarely) get Out-of-Memory (OOM) errors and more than this is unnecessary unless you want to enable hibernation.
#
# If you want to enable hibernation. The SWAP size should be a little higher than your RAM (5% is good enough)
#     In the arch wiki it's saying that SWAP size lower than RAM has a big CHANCE of success (though not 100%)
#     I still wouldn't recomend having a SWAP size lower than your RAM (unlesss you really don't have space in your HDD/SSD)
#
# With these informations in mind, do your calculation.
#
# I have 32GiB of RAM and don't want Hibernation so I'll set my SWAP size to 4GiB
#
# If you have a SWAP partition and want your SWAP file to have 16GiB, subtract your SWAP partition size from it
# So if your swap partition is 4GiB, subtract it from the 16GiB you'll assign, to you'll assing 12GiB to your SWAP file
#
# The value should be in Mebibytes, so in my case 4000 (or 12000 in the above example).
# You can use "k" instead of "000", so 4k in my case (or 12k in the above example).
#
# For non-btrfs
    dd if=/dev/zero of=/swapfile bs=1M count=4k status=progress
    # Set permissions
    chmod 0600 /swapfile
    # Format it to swap
    mkswap -U clear /swapfile
    # Enable swapfile
    swapon /swapfile
#
# For btrfs
    # In this case I can use "g" instead of "k"
    btrfs filesystem mkswapfile --size 4g --uuid clear /swapfile
    # Enable swapfile
    swapon /swapfile
#
# Auto mount it
sudo nano /etc/fstab
# Add this line, the swapfile must be specified by its location, since you're following this guide, it's /swapfile
/swapfile none swap defaults 0 0
# Increase Swappiness
sudo nano /etc/sysctl.d/99-swappiness.conf
# Put
vm.swappiness=10
# Reboot
# check if it was applied
cat /proc/sys/vm/swappiness
#
# If you encrypted your root (/) drive, everything inside it is encrypted aswell, and if you followed this guide
# The swapfile is inside the root (/) drive.
https://wiki.archlinux.org/title/Dm-crypt/Swap_encryption
#
# --------------------------------------------------------------------------------------------------------------------
#
sudo nano /etc/default/grub
# Change timeout to 5
sudo update-grub
#
# --------------------------------------------------------------------------------------------------------------------
#
# Make GUID Available for remote desktop
sudo nano /etc/ssh/sshd_config
# UNCOMMENT/CHANGE TO MATCH THESE
------------------------------------------------
X11Forwarding yes
AllowTcpForwarding yes
X11UseLocalhost yes
X11DisplayOffset 10
------------------------------------------------
#
# ------------------------------------------------------------------------------------------
#
# Check your device VID:PID with "lsusb" command it'll show a list of devices that looks like this: "Bus xxx device xxx: ID <VID:PID> Device Name"
# Write down the <VID>:<PID> (for example 256c:006d)
lsusb
# Create/modify "50-tablet.conf" file
sudo nano /etc/X11/xorg.conf.d/50-tablet.conf
#
# Put/Replace everything for this (changing VID:PID section with actual info from "lsusb")
# With the above example it would look like this: MatchUSBID "256c:006d", with the quotation marks
-----------------------------------------------
Section "InputClass"
    Identifier "Tablet"
    Driver "wacom"
    MatchDevicePath "/dev/input/event*"
    MatchUSBID "<VID>:<PID>"
EndSection
----------------------------------------------
# REBOOT
# Edit it in Settings>Input>Tablet
# REBOOT
# Change "stylus" to it's actuall name use below command to check
xinput --list
# The name should be 'HUION Huion Tablet stylus' WITH THOSE SINGLE QUOTATIONS
# So it'll look like
xsetwacom set 'HUION Huion Tablet stylus' rotate HALF
# Turn these on
xsetwacom --set 'HUION Huion Tablet stylus' TabletPCButton on
xsetwacom --set 'HUION Huion Tablet stylus' PressureRecalibration on
#
# ----------------------------------------------------------------------------------------------------------------------------------------------
#
# After installing samba and rebooting the system, add a user and password with the command below
sudo smbpasswd -a theusername
#
# --------------------------------------------------------------------------------------------------------------------
#
# Ventoy
#
# Mount USB drive into your PC
#
# -------------------------------------------------------
# INSTALL
# -------------------------------------------------------
#
# Install ventoy
#
# Install ventoy into your drive, use “lsblk” to find it,
# the entire device like this /dev/sdb not /dev/sdb3
sudo ventoy -i /dev/sde
#
# Use -u instead of -i to update or -I to reinstall
# -------------------------------------------------------
#
# Create a folder in "/mnt" called ventoy
sudo mkdir /mnt/ventoy
#
# Mount your USB stick (The biggest partition, the other has around 32M) to ventoy folder
sudo mount /dev/sdb1 /mnt/ventoy
#
# Copy .iso contents into it
cp /path/to/<your.iso> /mnt/ventoy && sync
#
# Wait for it to finish and unmount, WAIT FOR IT TO COMPLETELY UNMOUNT
sudo umount /mnt/ventoy
#
# --------------------------------------------------------------------------------------------------------------------
#
# Creating Bootable Media
#
# Replace "/path/to/iso" to the full path to the .iso you want to use
# Replace "DEVICE" to the deice path, use "lsblk" (must be the entire drive: "sdb" not "sdb1")
sudo dd bs=4M if=/path/to/iso of=DEVICE status=progress oflag=sync
#
# --------------------------------------------------------------------------------------------------------------------
#
# NVIDIA Stuff
#
# Configure nvidia settings
sudo nvidia-settings
#
# Click on "X Server Display Configuration" tab and click on "Advanced"
# Make sure all your displays have "Force Full Composition Pipeline" (And "Allow G-SYNC[...]" if supported) checked
# Click on "Save to X Configuration File" and save changes to "/etc/X11/mhwd.d/nvidia.conf"
#
# Everything else is just personal preference but I recommend setting "Image Settings" to "High Performance" in "OpenGL Settings" tab
# And "Preferred Mode" to "Prefer Maximum Performance" in "PowerMizer" tab
#
# Sometimes when quitting the settings it'll say you didn't apply your changes, if you have actually applied the changes you can ignore this warning
#
# --------------------------------------------------------------------------------------------------------------------
# 3D Mouse
#
# Have to read first before doing something
https://wiki.archlinux.org/title/3D_Mouse#Open_source_drivers
