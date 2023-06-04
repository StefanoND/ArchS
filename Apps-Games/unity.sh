# This is not a runnable script
#
# Install Unity Hub (And Editor)
#
# Looks like there's only one method this time
# Download Unity Hub from AUR
paru -S unityhub --noconfirm --needed
#
# Open it, sign in, install a Unity Editor
#
# It's integration with Rider is extremelly easy, after installing rider, create a (unity) project, once it's loaded click on Edit>Preferences
# The "Preferences" window will show up, click on "External Tools" tab
# In the "External Script Editor" change to "Rider XXXX.X.X" where X's are the Rider's version (Mine's currently "Rider 2022.3.2")
# Done, you can create scripts and double-click them and Rider will "automagically" open and load everything up
#
# Note: The installation says to install both of there to fix issues related to empty compier errors
# I didn't install it but I'll leave it here in case it happens to me
# Will update if it does and put alongside unityhub instalation
paru -S libicu50 icu70 --noconfirm --needed
#
# Note 2: If you use Unity 2019.4 or older you must install gconf aswell
#
# Available if you use alerque repo
sudo pacman -S gconf --noconfirm --needed
#
# Available from AUR
paru -S gconf --noconfirm --needed
