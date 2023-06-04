# This is not a runnable script
#
# Follow the steps of https://github.com/StefanoND/ArchS/blob/main/Troubleshooting/repair_from_live_intsall_media.sh to boot into Live USB (or Live CD) until "# Do what you need to do"
#
# Check everything nvidia related
sudo pacman -Q | grep nvidia
#
# After reviewing what was shown with the command above, uninstall everything nvidia related
sudo pacman -Rsn nvidia-utils lib32-nvidia-utils nvidia-dkms linux-nvidia --noconfirm
#
# If the output says you can't uninstall due to conflicts add them to the uninstall such as
sudo pacman -Rsn nvidia-utils lib32-nvidia-utils nvidia-dkms linux-nvidia gwe --noconfirm
#
# Check for leftovers
sudo pacman -Q | grep nvidia
#
# Recursively remove orphaned packages and their configuration files (READ BEFORE MINDLESSLY REMOVING EVERYTHING)
sudo pacman -Qtdq | sudo pacman -Rns -
#
# In some cases the command above is not enough, run this command to check dependency cycles (aka Circular Dependencies)
# Excessive dependencies (fullfiled more than once), unexplicit optionals, etc (READ THEM CAREFULLY)
sudo pacman -Qqd | sudo pacman -Rsu --print -
#
# After using the command above use this one to remove them
sudo pacman -Qqd | sudo pacman -Rsu -
#
# Follow the steps of https://github.com/StefanoND/ArchS/blob/main/Troubleshooting/repair_from_live_intsall_media.sh to unmount everything (Below "# Do what you need to do")
#
# Reboot into the Live USB again and redo all the mounting steps again.
#
# Reinstall main nvidia driver (remove the conflicting ones: linuxXX-nvidia, etc)
sudo pacman -S nvidia-dkms --noconfirm --needed
#
# Unmount everything again and reboot
# The problem should be solved and you're greeted with your Login Screen
#
# Reinstall remaining apps that requires NVidia stuff (that you removed earlier)
sudo pacman -S nvidia-utils lib32-nvidia-utils gwe --noconfirm --needed
