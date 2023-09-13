#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
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
echo "                                  Post-Install Script"
echo
echo
sleep 2s
clear

sleep 1s

cpath=`pwd`

npath=`cat "$cpath"/uepath.txt`

cd $npath

echo
echo "Installing Unreal Engine, this will take a long time, go to sleep, touch grass, come back in a few hours"
echo
#sudo make
Engine/Build/BatchFiles/RunUAT.sh BuildGraph -target="Make Installed Build Linux" -script=Engine/Build/InstalledEngineBuild.xml -set:WithDDC=true -set:HostPlatformOnly=false -set:WithLinux=true -set:WithWin64=true -set:WithMac=false -set:WithAndroid=false -set:WithIOS=false -set:WithTVOS=false

sleep 1s

#echo
#echo "Running make again just to make sure, will take less than a minute this time, if everything went right"
#echo
#sudo make

cp -flr LocalBuilds/Engine/Linux/* ./

# If you're having problems with ShaderCompileWorkers run this command
#cd $npath/Engine/Build/BatchFiles/Linux
#chmod +x Build.sh ShaderCompileWorker Linux Development

echo
echo "Setting proper permissions and ownership"
echo


printf "sudo chown root:unrealengine-users -R ../UnrealEngine5_2"
sudo chown $(logname):$(logname) -R ../UnrealEngine5_2
printf "sudo chmod 700 -R ../UnrealEngine5_2"
sudo chmod 700 -R ../UnrealEngine5_2

#echo "sudo groupadd unrealengine-users"
#sudo groupadd unrealengine-users
#echo "sudo usermod -aG unrealengine-users $(logname)"
#sudo usermod -aG unrealengine-users $(logname)
#printf "sudo chown root:unrealengine-users -R ../UnrealEngine5_2"
#sudo chown root:unrealengine-users -R ../UnrealEngine5_2
#printf "sudo chmod 775 -R ../UnrealEngine5_2"
#sudo chmod 775 -R ../UnrealEngine5_2

sleep 1s

echo
echo "Do you want to create a Symlink in your home folder?"
echo
read SYMLINK
if [[ ${SYMLINK,,} = y ]]; then
    echo
    echo "Creating symlink from \"$npath\" to \"$HOME\""
    echo
    ln -s $npath $HOME
    sleep 1s
    echo
    echo "Adding a Symlink of \"UnrealEditor\" to \"$HOME\""
    echo
    ln -s $HOME/UnrealEngine5_2/Engine/Binaries/Linux/UnrealEditor $HOME
fi

rm "$cpath"/uepath.txt

echo
echo "Done! Run UnrealEditor and wait for all shaders to compile (~5k at 35%, ~900 at 45% and 75% plus the ones in-editor)"
echo

exit 0
