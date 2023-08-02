# This is not a runnable script
#
# -------------------
# PROTON
# -------------------
#
# It contains a patch to store game prefixes in the main Steam Library under $HOME/.local/share/Steam/steamapps/compatdata.
# It helps with isolation of game prefixes between users and works around issues with shared libraries on NTFS partitions due to drive symlinks.
# To enable it, set the PROTON_USER_COMPAT_DATA env variable to 1.
#
# -------------------
# STEAM
# -------------------
#
# Individual game's launch options
#
# Turn on Gamemode
gamemoderun %command%
#
# Turn on MangoHUD
mangohud %command%
#
# If the above doesn't work use this instead
LD_PRELOAD=$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libgamemodeauto.so.0 %command%
#
# Enable FSR on any game
WINE_FULLSCREEN_FSR=1 %command%
#
# DXVK-async processes compiling shaders asynchronously from the rendering process so you do not get stutters while waiting for the shaders to be compiled.
DXVK_ASYNC=1 %command%
#
# NOTE: If you're using more than one argument you don't need to put multiple "%command%"s
# Just put the arguments first and only one "%command%" at the end, like so:
DXVK_ASYNC=1 WINE_FULLSCREEN_FSR=1 gamemoderun %command%
#
# NOTE2: If you're using both arguments that requires the "%command%" and that doesn't, you put the ones that requires first, then the rest
# For example:
DXVK_ASYNC=1 WINE_FULLSCREEN_FSR=1 gamemoderun %command% -freq 144 -tickrate 128 +cl_cmdrate 128 +cl_updaterate 128 +cl_forcepreload 1
#
# If you put any argument that doesn't use "%command%" (like "gamemoderun -freq 144 %command%") the game will not launch
#
# --------------------------------------------------------------------------------------------------------------------
# If need to add CD Key and the game doesn't auto show option to put CD-Key, change "CDKEY" to the actual CD Key and "APPID" to the Steam's Game ID
protontricks -c 'wine cmd /C reg add "HKEY_CURRENT_USER\Software\Futuremark\3DMark" /v "KeyCode" /t REG_SZ /d "CDKEY"' APPID
# --------------------------------------------------------------------------------------------------------------------
#
# -------------------
# Steam Tinker Launch (STL)
# -------------------
#
# Only works with Native Linux games
#
# Use this command (and only this command) in the  launch options
steamtinkerlaunch %command%
#
# After this Run the game, a new window will pop up, click "Skip" to go to game or click on "Main Menu" to start tinkering
#
# Add tweaks
git clone https://github.com/frostworx/steamtinkerlaunch-tweaks.git && cd steamtinkerlaunch-tweaks/tweaks
sudo mkdir /usr/share/steamtinkerlaunch/tweaks
sudo cp * /usr/share/steamtinkerlaunch/tweaks/
#
# If you see a bunch of xxxxx.conf inside "/usr/share/steamtinkerlaunch/tweaks" it's properly installed
#
# -------------------
# LUTRIS
# -------------------
#
# In lutris Add environments
# Change "USERNAME" to your username
WINEUSERNAME = USERNAME
GST_PLUGIN_SYSTEM_PATH_1_0 = /home/USERNAME/.steam/root/compatibilitytools.d/GE-ProtonX-XX/files/lib64/gstreamer-1.0:/home/USERNAME/.steam/root/compatibilitytools.d/GE-ProtonX-XX/files/lib/gstreamer-1.0
# PER GAME change USERNAME to your username and GAME to the Game's directory name
WINE_GST_REGISTRY_DIR = /home/USERNAME/Games/GAME/gstreamer1.0
WINE_GST_REGISTRY_DIR = /mnt/HDD/manjaro/games/launchers/lutris/GAME/gstreamer1.0
WINE_GST_REGISTRY_DIR = /mnt/SSD/manjaro/games/launchers/lutris/GAME/gstreamer1.0
#
# -------------------
# vkBasalt
# -------------------
#
# If you installed vkBasalt you should have vkBasalt.conf.exmplae in /usr/share/vkBasalt remove the .example from it
sudo mv /usr/share/vkBasalt/vkBasalt.conf.example /usr/share/vkBasalt/vkBasalt.conf
# 
# After that, make it the default config directory
export VKBASALT_CONFIG_FILE=/usr/share/vkBasalt/vkBasalt.conf
#
# Reboot
sudo shutdown -r now
#
# You can configure it the way you like it but it should be working as is (even the Shader and Texture reshade if you installed them aswell)
# If you want to configure "on-fly", enable it in the game's argument and run the game
# Once the game's loaded you can access the config menu by pressing the "HOME" button
#
# To enable vkBasalt you can use the following argument
ENABLE_VKBASALT=1
#
# If you're on steam
ENABLE_VKBASALT=1 %command%
