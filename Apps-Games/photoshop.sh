# This is not a runnable script
#
# I've decided to use photoshop exclusively in a Windows VM, unless it can be done in less than 1 min in Linux
#
# ---------------------------------------------------------------------------------------------------------------#
# DISCLAIMER: I DO NOT CONDONE THE USE OF PHOTOSHOP WITHOUT AN ACTIVE ADOBE SUBSCRIPTION THAT INCLUDES IT OR     #
# WITHOUT ANY OTHER MEANS THAT ALLOWS YOU LEGALLY TO USE IT BY DEFINED ADOBE.                                    #
# ---------------------------------------------------------------------------------------------------------------#
#
# ---------------------------------------------------------------------------------------------------------------#
# CREDITS:                                                                                                       #
# ---------------------------------------------------------------------------------------------------------------#
# Photoshop in Linux: https://github.com/MiMillieuh/Photoshop-CC2022-Linux                                       #
# Make Pen Pressure work: /r/winehq/comments/iq7530/comment/j8415ma/?utm_source=share&utm_medium=web2x&context=3 #
# ---------------------------------------------------------------------------------------------------------------#
#
# Follow install instructions in the Link Provided above
# The Author and I recommend using Photoshop 2021 for stable production environment
#
# Downgrade Wine to 7.22 before running Photoshop for the first time
# Download from here https://archive.archlinux.org/packages/w/wine-staging/
# This is direct link: https://archive.archlinux.org/packages/w/wine-staging/wine-staging-7.22-1-x86_64.pkg.tar.zst
# CD into the folder it was downloaded to, probably downloads
cd ~/Downloads
#
# Uninstall Wine
sudo pacman -Rdd wine-staging
#
# Install wine 7.22
sudo pacman -U wine-staging-7.22-1-x86_64.pkg.tar.zst --noconfirm --needed
#
# Make sure you have these opencl packages installed (Included in "2-dependencies.sh" script)
sudo pacman -S opencl-headers opencl-nvidia opencl-clhpp --noconfirm --needed
#
# Open it's wineprefix's winecfg
WINEPREFIX=/path/to/Adobe-Photoshop/ winecfg
#
# Go to libraries and add the following overrides (All "native then builtin") :
d3d9, d3d10core, d3d11, d3d12, dxgi, dxva2, fntcache, fontsub. gdiplus, opencl and vulkan-1
#
# In staging tab enable "Enable VAAPI as backend for DXVA2 GPU decoding" (GTK3 Theming doesn't do anything)
# Apply and ok
#
# Reboot wine
WINEPREFIX=/path/to/Adobe-Photoshop/ wineboot
#
# Open photoshop and enable OpenCL in "Edit->Preferences->Performance->Advanced Settings..."
# Close photoshop
#
# Uninstall wine 7.22
sudo pacman -Rdd wine-staging
#
# Install latest wine version
sudo pacman -S wine-staging --noconfirm --needed
#
# Done!
#
# To use a Tablet with Pen Pressure you'll need to disable "Windows Ink" in Photoshop
# Create a .txt file and write "UseSystemStylus 0" in there
touch ~/PSUserConfig.txt
echo "UseSystemStylus 0" | tee ~/PSUserConfig.txt
#
# Now you have to copy it to Photoshop's Settings (Change "PATH/TO" and "USERNAME" accordingly)
cp ~/PSUserConfig.txt /PATH/TO/Adobe-Photoshop/drive_c/users/USERNAME/AppData/Roaming/Adobe/Adobe Photoshop 2021/Adobe Photoshop 2021 Settings
#
# This makes Photoshop to at least recognize the existence of Pen Pressure but it kinda works
# To fix it we have to uninstall the proprietary Tablet Driver (Whether from Wacom, Huion or Other Brand) or Digimend Drivers
# And install OpenTabletDriver (The non "-git" version)
paru -S opentabletdriver --noconfirm --needed
#
# Open the OpenTabletDriver app
# In the "Output" tab click on the dropdown on the bottom-left corner and select "Artist Mode"
# In the "Pen Settings" tab in the "Tip Binding" section click the "..." button
# In the new window that pops us, click the top dropdown and select "Linux Artist Mode"
# Click "Apply", "Apply" and "Save"
# After all this is done, pen pressure will work
# You may configure OpenTabletDriver to your liking as long as you don't change the settings above
#
# Done
#
# Update: If you add photoshop to lutris and use proton-ge as wine version you can use Liquify with GPU Acceleration. Scrubby Zoom works aswell.
#
#
#
# Note: To use the "Liquify" filter you MUST disable "Use Graphics Processor" in "Edit->Preferences->Performance" or it'll crash
# You can enable it again once you're done using it
#
# Scrubby Zoom doesn't seem to work, don't know why.
