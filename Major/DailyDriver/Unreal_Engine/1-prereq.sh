#!/usr/bin/env bash

# https://github.com/StefanoND/Manjaro/blob/main/Misc/UnrealEngine.txt

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

if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    if ! grep -iq "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json" /etc/environment; then
        echo
        echo "Assigning \"VK_ICD_FILENAMES\" to \"nvidia_icd.json\""
        echo
        printf "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json" | sudo tee -a /etc/environment
    sleep 1s
    fi
    echo
    echo "Removing vulkan for non-NVidia GPUs to avoid conflicts"
    echo
    sudo pacman -Rsn lib32-vulkan-radeon vulkan-radeon lib32-vulkan-intel vulkan-amdgpu-pro amf-amdgpu-pro --noconfirm
    sleep 1s
fi
if ! grep -iq "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d" /etc/environment; then
    echo
    echo "Assigning \"VK_LAYER_PATH\" to \"explicit_layer.d\""
    echo
    printf "VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d" | sudo tee -a /etc/environment
    sleep 1s
fi

sleep 1s

paru -S dotnet-runtime dotnet-host dotnet-sdk dotnet-sdk-6.0 bash-completion babeltrace2 libicu53 --noconfirm --needed --sudoloop

if ! grep -iq "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1" /etc/environment; then
    echo
    echo "Enabling Globalization Invariant"
    echo
    printf "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1\n" | sudo tee -a /etc/environment
    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
    sleep 1s
fi
if ! grep -iq "DOTNET_CLI_TELEMETRY_OPTOUT=1" /etc/environment; then
    echo
    echo "Disabling DotNet telemetry"
    echo
    printf "DOTNET_CLI_TELEMETRY_OPTOUT=1\n" | sudo tee -a /etc/environment
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    sleep 1s
fi

echo
echo "Done!"
echo
echo "Press Y to reboot now or N if you plan to manually reboot later."
echo
read REBOOT
if [ ${REBOOT,,} = y ]; then
    reboot
fi

exit 0
