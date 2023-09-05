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

echo
echo "Starting"
echo

winenwnpath=/mnt/SSD_WORK/NWN/.winenwn
wnprfpath="$winenwnpath"

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
if ! test -e $wnprfpath; then
    echo
    echo "Creating a new wineprefix in \"$wnprfpath\""
    echo
    WINEPREFIX=$wnprfpath winecfg &
    echo
    echo "Close the winecfg window when it opens"
    echo "Press any key when it's closed"
    echo
    read THISANYKEY
sleep 1s
fi
if ! grep -i "WINEPREFIX=$wnprfpath" /etc/environment; then
    echo
    echo "Setting the new wineprefix as default wine"
    echo
    printf "WINEPREFIX=$wnprfpath\n" | sudo tee -a /etc/environment
fi
#
#-------------------------------------------------------------------------------------------------------------
#
# Remove some folders that causes issues with dotNET installationg
#
# Mono
rm -r $wnprfpath/drive_c/windows/Microsoft.NET
rm $wnprfpath/drive_c/windows/system32/mscoree.dll
rm $wnprfpath/drive_c/windows/syswow64/mscoree.dll
#
# OpenAL
# Remove openal (to fix the installer, will be installed later)
rm $wnprfpath/drive_c/windows/system32/openal32.dll
rm $wnprfpath/drive_c/windows/syswow64/openal32.dll
#
# Fix: extract_cabinet FDICopy failed error (seen with dotnet40 since Proton 5.13-5 as winxp64)
rm $wnprfpath/drive_c/windows/system32/dxva2.dll
rm $wnprfpath/drive_c/windows/syswow64/dxva2.dll
rm $wnprfpath/drive_c/windows/system32/evr.dll
rm $wnprfpath/drive_c/windows/syswow64/evr.dll
rm $wnprfpath/drive_c/windows/system32/uiautomationcore.dll
rm $wnprfpath/drive_c/windows/syswow64/uiautomationcore.dll
#
# Fix: wine's builtin fusion.dll fails to create legacy assembly directory (https://bugs.winehq.org/show_bug.cgi?id=45930)
mkdir -p $wnprfpath/drive_c/windows/assembly
sleep 1s
#
#-------------------------------------------------------------------------------------------------------------
#
# Install required apps for dotNET stuff
WINEPREFIX=$wnprfpath winetricks msxml3 msxml4 msxml6 -qf
sleep 10s
killall -r mscorsvw.exe
sleep 10s
#
# Change to Windows XP
WINEPREFIX=$wnprfpath winecfg -v winxp64
sleep 1s
#
# Install dotNET 2.0 Service Pack 2 (Must run separate)
WINEPREFIX=$wnprfpath winetricks dotnet20sp1 -qf
sleep 10s
killall -r mscorsvw.exe
sleep 10s
#
# Install dotNET 3.5 Service Pack 1 and dotNET 4.0 (Must run separate)
WINEPREFIX=$wnprfpath winetricks dotnet35sp1 -qf
sleep 10s
killall -r mscorsvw.exe
sleep 10s
#
# Install dotNET 4.0 (Must run separate)
WINEPREFIX=$wnprfpath winetricks dotnet40 -qf
sleep 10s
killall -r mscorsvw.exe
sleep 10s
#
# Manually trigger rebuild of the Global Assembly Cache (GAC) after .NET 4.0 Framework installation
env WINEPREFIX=$HOME/.winenwn wine "c:\\windows\\Microsoft.NET\\Framework\\v4.0.30319\\ngen.exe" update
sleep 10s
killall -r mscorsvw.exe
sleep 10s
#
# Change to Windows 7
WINEPREFIX=$wnprfpath winecfg -v win7
sleep 1s
#
# Install dotNET 4.8
WINEPREFIX=$wnprfpath winetricks dotnet48 xna40 -qf
sleep 10s
killall -r mscorsvw.exe
sleep 10s
#
# Install all fonts
WINEPREFIX=$wnprfpath winetricks allfonts -q
sleep 10s
killall -r mscorsvw.exe
killall -r aspnet_regiis.exe
sleep 10s
#
# Install apps (For vcrun2022 it'll ask you to continue installation on two occasions, press "y" and "enter" for both)
WINEPREFIX=$wnprfpath winetricks dxvk vkd3d openal vcrun2005 vcrun2010 vcrun2012 vcrun2013 vcrun2022 -qf
sleep 10s
killall -r mscorsvw.exe
killall -r aspnet_regiis.exe
sleep 10s
#
# Change to Windows XP (Again)
WINEPREFIX=$wnprfpath winecfg -v winxp64
sleep 1s
#
# Instal vcrun2008
WINEPREFIX=$wnprfpath winetricks vcrun2008 -qf
sleep 10s
killall -r mscorsvw.exe
killall -r aspnet_regiis.exe
sleep 10s
#
# Instal DirectX 9
WINEPREFIX=$wnprfpath winetricks dxdiag -qf
sleep 10s
killall -r mscorsvw.exe
killall -r aspnet_regiis.exe
sleep 10s
#
# Instal Visual Basic Runtime 6
WINEPREFIX=$wnprfpath winetricks vbrun6 -qf
sleep 10s
killall -r mscorsvw.exe
killall -r aspnet_regiis.exe
sleep 10s
#
# Change to Windows 10
WINEPREFIX=$wnprfpath winecfg -v win7
sleep 1s
#
# Configure wine
WINEPREFIX=$wnprfpath winecfg &
sleep 1s
#
echo
echo "Click on \"Libraries\" tab"
echo "Add the following libraries with load order \"Native then builtin\": api-ms-win-crt-conio-l1-1-0, api-ms-win-crt-heap-l1-1-0, api-ms-win-crt-locale-l1-1-0, api-ms-win-crt-math-l1-1-0, api-ms-win-crt-runtime-l1-1-0, api-ms-win-crt-stdio-l1-1-0, api-ms-win-crt-time-l1-1-0, atl100, atl110, atl120, atl140, comdlg32, concrt140, crypt32, d3d9, d3d10core, d3d11, d3d12core, devenum, dinput, dinput8, dsound, dxgi, dxva2, explorerframe, fntcache, fontsub, gamingtcui, gdiplus, msvcp100, msvcp110, msvcp120, msvcp140, msvcr100, msvcr110, msvcr120, msvcr140, opencl, ucrtbase, vcomp100, vcomp110, vcomp120, vcomp140, vcruntime140, vulkan-1"
echo
echo "Add the following libraries with load order \"Disabled\": mshtml"
echo
echo "DON'T CLOSE WINECFG YET"
echo
echo "Press any key when you're done"
echo
read ANYKEY
sleep 1s
echo
echo "Misc stuff, in Graphics you can increase the dpi to 120"
echo "If you run \"WINEPREFIX=$wnprfpath wine regedit\" and go to \"HKEY_CURRENT_CONFIG->Software->Fonts\" you can change the \"LogPixels\""
echo "Default value is 60 (96) but it's too small when openning \"Creature Properties\" or other Dialogs in toolset."
echo "I personally use 64 (100) which increases their sizes to a more readable size and doesn't clip things"
echo
sleep 1s
echo
echo "Close winecfg now"
echo "Press any button after closing it"
echo
read ANYOTHERBUTTON
echo
echo "Wait 5 seconds"
echo
sleep 1s
echo
echo "Wait 4 seconds"
echo
sleep 1s
echo
echo "Wait 3 seconds"
echo
sleep 1s
echo
echo "Wait 2 seconds"
echo
sleep 1s
echo
echo "Wait 1 second"
echo
sleep 1s
echo
echo "Rebooting wine"
echo
WINEPREFIX=$wnprfpath wineboot
echo
echo
echo
echo "Done"
echo
echo
echo
sleep 1s
echo
echo "Before opening NWN Explorer:"
echo "For nwnexplorer to work with NWN:EE you need to copy the \"nwn_base.key\" from the \"data\" folder to the game's root install folder"
echo "If you downloaded from Steam, it's location is ../Steam/steamapps/common/Neverwinter Nights"
echo "If you downloaded from the Beamdog client, the name of the root install folder is \"00829\""
echo
echo "Open NWN Explorer:"
echo "To point it to the correct location you go in \"Options\" check \"Look for NWN in the followin directory:\" and click on the \"...\" button"
echo "On the window that pops up, you'll expand \"My Computer\" and in it you'll expand \"Z:\" (NOT \"/\")"
echo "From there you select the path to your game's root install folder then click \"Ok\" then \"Apply\" then \"Ok\""
echo "Done, the next time you open \"nwnexplorer.exe\" you'll see all NWN:EE's contents"
echo
echo "Note: nwnexplorer.exe need fmod.dll to play audio, use the one included in this folder, extract it and place the \"fmod.dll\" in the same folder as nwnexplorer.exe"
echo
sleep 1s
echo
echo "Done! You can now run nwtoolset.exe, nwhak.exe, nwnexplorer.exe, etc"
echo "You can even create a .desktop of them"
echo "Also you can add them to your \"/usr/bin\" or \"/usr/local/bin\" folder to open them through the terminal"
echo
sleep 1s
echo
echo "Check out Lexicon on how to use VSCode to program"
echo "https://nwnlexicon.com/index.php?title=NWN:EE_Script_Editing_Tutorial"
echo
sleep 1s
echo
echo "Enjoy!"
echo
sleep 1s
exit 0
