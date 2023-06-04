#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this program as root."
    echo
    exit 1
fi

clear
echo
echo
echo "      _        _                                     ___                               "
echo "     / \   ___| |_ ___ _ __ _ __  _   _ _ __ ___    / _ \ _ __ ___   ___  __ _  __ _   "
echo "    / _ \ / _ \ __/ _ \ '__| '_ \| | | | '_ ' _ \  | | | | '_ ' _ \ / _ \/ _' |/ _' |  "
echo "   / ___ \  __/ ||  __/ |  | | | | |_| | | | | | | | |_| | | | | | |  __/ (_| | (_| |  "
echo "  /_/   \_\___|\__\___|_|  |_| |_|\__,_|_| |_| |_|  \___/|_| |_| |_|\___|\__, |\__,_|  "
echo "                                                                         |___/         "
echo "                        Archlinux Post-Install Setup and Config"
echo
echo
sleep 2s
clear

sleep 1s

# This is a runnable script
#
# This is not for the game itself since it runs natively
# This is for its windows programs: nwtoolset.exe and nwhak.exe (nwmain.exe and nwserver.exe works too but theres a (native) linux version of those)
#
# After running this script you can change it's "My Documents" settings in "/home/USERNAME/.winenwn/drive_c/users/USERNAME/Documents/Neverwinter Nights/"
# To access paths outside the starting path outside the "drive_c" is "/home/USERNAME/.winenwn/dosdevices/z:/" this will take you to the "/" folder
# So to access your home folder it's "/home/USERNAME/.winenwn/dosdevices/z:/home/USERNAME/"
#
# Symlinks doesn't work, I mean, you can still make them, but they won't be seen by the program
#
# Create a new wineprefix
echo
echo "Creating a new wineprefix in \"/home/$(logname)/.winenwn\""
echo
WINEPREFIX=/home/$(logname)/.winenwn winecfg &
echo
echo "Close the winecfg window when it opens"
echo "Press any key when it's closed"
echo
read THISANYKEY
sleep 1s
echo
echo "Setting the new wineprefix as default wine"
echo
printf "WINEPREFIX=/home/$(logname)/.winenwn\n" | sudo tee -a /etc/environment
#
#-------------------------------------------------------------------------------------------------------------
#
# Remove some folders that causes issues with dotNET installationg
#
# Mono
rm -r /home/$(logname)/.winenwn/drive_c/windows/Microsoft.NET
rm /home/$(logname)/.winenwn/drive_c/windows/system32/mscoree.dll
rm /home/$(logname)/.winenwn/drive_c/windows/syswow64/mscoree.dll
sleep 1s
#
# OpenAL
# Remove openal (to fix the installer, will be installed later)
rm /home/$(logname)/.winenwn/drive_c/windows/system32/openal32.dll
rm /home/$(logname)/.winenwn/drive_c/windows/syswow64/openal32.dll
sleep 1s
#
# Fix: extract_cabinet FDICopy failed error (seen with dotnet40 since Proton 5.13-5 as winxp64)
rm /home/$(logname)/.winenwn/drive_c/windows/system32/dxva2.dll
rm /home/$(logname)/.winenwn/drive_c/windows/syswow64/dxva2.dll
rm /home/$(logname)/.winenwn/drive_c/windows/system32/evr.dll
rm /home/$(logname)/.winenwn/drive_c/windows/syswow64/evr.dll
rm /home/$(logname)/.winenwn/drive_c/windows/system32/uiautomationcore.dll
rm /home/$(logname)/.winenwn/drive_c/windows/syswow64/uiautomationcore.dll
sleep 1s
#
# Fix: wine's builtin fusion.dll fails to create legacy assembly directory (https://bugs.winehq.org/show_bug.cgi?id=45930)
mkdir -p /home/$(logname)/.winenwn/drive_c/windows/assembly
sleep 1s
#
#-------------------------------------------------------------------------------------------------------------
#
# Install required apps for dotNET stuff
WINEPREFIX=/home/$(logname)/.winenwn winetricks msxml3 msxml4 msxml6 -q --force
sleep 5s
killall -r mscorsvw.exe
sleep 5s
#
# Change to Windows XP
WINEPREFIX=/home/$(logname)/.winenwn winecfg -v winxp64
sleep 1s
#
# Install dotNET 2.0 Service Pack 2 (Must run separate)
WINEPREFIX=/home/$(logname)/.winenwn winetricks dotnet20sp2 -q --force
sleep 5s
killall -r mscorsvw.exe
sleep 5s
#
# Install dotNET 3.5 Service Pack 1 and dotNET 4.0 (Must run separate)
WINEPREFIX=/home/$(logname)/.winenwn winetricks dotnet35sp1 -q --force
sleep 5s
killall -r mscorsvw.exe
sleep 5s
#
# Install dotNET 4.0 (Must run separate)
WINEPREFIX=/home/$(logname)/.winenwn winetricks dotnet40 -q --force
sleep 5s
killall -r mscorsvw.exe
sleep 5s
#
# Manually trigger rebuild of the Global Assembly Cache (GAC) after .NET 4.0 Framework installation
env WINEPREFIX=$HOME/.winenwn wine "c:\\windows\\Microsoft.NET\\Framework\\v4.0.30319\\ngen.exe" update
sleep 5s
killall -r mscorsvw.exe
sleep 5s
#
# Change to Windows 7
WINEPREFIX=/home/$(logname)/.winenwn winecfg -v win7
sleep 1s
#
# Install dotNET 4.8
WINEPREFIX=/home/$(logname)/.winenwn winetricks dotnet48 xna40 -q --force
sleep 5s
killall -r mscorsvw.exe
sleep 5s
#
# Install all fonts
WINEPREFIX=/home/$(logname)/.winenwn winetricks allfonts -q
sleep 5s
killall -r mscorsvw.exe
killall -r aspnet_regiis.exe
sleep 5s
#
# Install apps (For vcrun2022 it'll ask you to continue installation on two occasions, press "y" and "enter" for both)
WINEPREFIX=/home/$(logname)/.winenwn winetricks dxvk vkd3d openal vcrun2005 vcrun2010 vcrun2012 vcrun2013 vcrun2022 -q --force
sleep 5s
killall -r mscorsvw.exe
killall -r aspnet_regiis.exe
sleep 5s
#
# Change to Windows XP (Again)
WINEPREFIX=/home/$(logname)/.winenwn winecfg -v winxp64
sleep 1s
#
# Instal vcrun2008
WINEPREFIX=/home/$(logname)/.winenwn winetricks vcrun2008 -q --force
sleep 5s
killall -r mscorsvw.exe
killall -r aspnet_regiis.exe
sleep 5s
#
# Configure wine
WINEPREFIX=/home/$(logname)/.winenwn winecfg &
sleep 1s
#
echo
echo "Click on \"Libraries\" tab"
echo "Add the following libraries: d3d9, d3d10core, d3d11, d3d12core, dxgi, comdlg32, dxva2, explorerframe, fntcache, fontsub, gamingtcui, gdiplus, opencl, ucrtbase, vulkan-1"
echo "If you have NVidia GPU and Cuda installed add the following library: nvcuda"
echo
echo "Press any key when you're done"
echo
read ANYKEY
echo
echo "Click on \"Staging\" tab"
echo "Enable \"Enable Environmental Audio Extensions (EAX)\", \"Enable VAAPI as backend for DXVA2 GPU decoding\" and \"Enable GTK3 Theming\"."
echo
echo "Press any key when you're done"
echo
read ANOTHERANYKEY
sleep 1s
echo
echo "Misc stuff, in Graphics you can increase the dpi to 120"
echo "If you run \"WINEPREFIX=/home/$(logname)/.winenwn wine regedit\" and go to \"HKEY_CURRENT_CONFIG->Software->Fonts\" you can change the \"LogPixels\""
echo "Default value is 60 (96) but it's too small when openning \"Creature Properties\" or other Dialogs in toolset."
echo "I personally use 64 (100) which increases their sizes to a more readable size and doesn't clip things"
echo
sleep 1s
echo
echo "For nwnexplorer to work with NWN:EE you nneed to copy the \"nwn_base.key\" from the \"data\" folder to the game's root install folder"
echo "If you downloaded from Steam, it's location is ../Steam/steamapps/common/Neverwinter Nights"
echo "If you downloaded from the Beamdog client, the name of the root install folder is \"00829\""
echo "To point it to the correct location you go in \"Options\" check \"Look for NWN in the followin directory:\" and click on the \"...\" button"
echo "On the window that pops up, you'll expand \"My Computer\" and in it you'll expand \"Z:\""
echo "From there you select the path to your game's root install folder then click \"Ok\" then \"Apply\" then \"Ok\""
echo "Done, the next time you open \"nwnexplorer.exe\" you'll see all NWN:EE's contents"
echo
echo "Note: nwnexplorer.exe can't play any audio due to missing \"fmod.dll\". You can't install through winetricks"
echo "And manually downloading and installing doesn't work. Neither does copy pasting it to the same folder of nwnexplorer.exe"
echo "Or adding it to library through winecfg or using WINEDLLOVERRIDES=\"fmod=b,n\" or using regsvr32.exe (or wine's regsvr32)"
echo "Unless there's another way (that I'm not aware of) you can't use anything that relies on fmod.dll to run"
echo
sleep 1s
echo
echo "Done! You can now run nwtoolset.exe, nwhak.exe, nwnexplorer.exe, etc"
echo "You can even create a .desktop of them"
echo "Also you can add them to your \"/usr/bin\" or \"/usr/local/bin\" folder to open them through the terminal"
echo
sleep 1s
echo
echo "Enjoy!"
echo
sleep 1s
exit 0
