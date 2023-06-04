# This is not a runanble script
#
# If you installed a new kernel, installed a custom kernel, messed up something, removed something by mistake, etc
# And now you're greeted with a blank/black screen at login. You can access it fom a Live USB (or Live CD)
#
# Every time I write "Live USB" I also mean Live CD (if that's your case)
#
# Plug your Live USB into your PC reboot
# I'll boot with proprietary drivers since I'm using NVidia GPU
#
# Once you're in, open the terminal and type:
sudo blkid
#
# Look for the partition that has your installation (Usually it's called "root", look for something like this: PARTLABEL="root")
# Now look for the beginning of this line, it should have /dev/sda2 or /dev/sdb2 or something like this
# If you're using an NVMe drive like me, it'll look something like this /dev/nvme0n1 or something like this, mine's /dev/nvme0n1p2.
#
# Now you'll need to mount a bunch of stuff of your respective /dev/DEVICE
#
# Mount the main device change "/dev/nvme0n1p2" to your device
sudo mount /dev/nvme0n1p2 /mnt
#
# For a BTRFS partition you must mount the subvolume instead
sudo mount -o subvol=@ /dev/nvme0n1p2 /mnt
#
# Now you'll need to mount the dev, sys and proc folders so the next commands won't complain about having no directory
sudo mount --bind /dev /mnt/dev
sudo mount --bind /sys /mnt/sys
sudo mount --bind /proc /mnt/proc
#
# ----------------------------------------------------------------------------------------------------------------------
# This section is optional, if you don't need to do anything with the bootloader you don't have to follow this section
#
# There's two ways of doing this, one is if your installation is EFI and the other isn't
#
# To check if you have an EFI system, do the following
#
# WARNING: This part is the ENTIRE device without the last (partition) numbers
# So they must look like this: /dev/sda, /dev/sba, /dev/nvme0n1 and NOT like this /dev/sda1, /dev/sba3, /dev/nvme0n1p5
#
# Change the /dev/nvme0n1 to your device
sudo fdisk -l /dev/nvme0n1 | grep EFI
#
# Your system is EFI if it shows something like this:
Partition 3 does not start on physical sector boundary.
/dev/nvme0n1p1       4096     618495     614400   300M EFI System
#
# Your sistem isn't EFI if it shows something like this (or doesn't show anything at all):
Partition 3 does not start on physical sector boundary.
#
# Mount the boot partition accordingly
#
# Non-EFI
sudo mount /dev/nvme0n1p1 /mnt/boot
#
# EFI
sudo mount /dev/nvme0n1p1 /mnt/boot/efi
###########################################
# ----------------------------------------------------------------------------------------------------------------------
# 
# After mounting everything let's chroot into it (be extra careful since you're sudo now)
sudo chroot /mnt
#
# Do what you need to do
#
# When you're done, unmount everything you mounted and reboot, shutdown, etc
sudo umount /mnt/dev
sudo umount /mnt/sys
sudo umount /mnt/proc
sudo umount /mnt/boot # Only if you mounted it
sudo umount /mnt/boot/efi # Only if you mounted it
sudo umount /mnt
