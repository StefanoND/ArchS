#!/usr/bin/env bash

if ! [ $EUID -ne 0 ] ]]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
    exit 1
fi

echo
echo "Create and setup a VM first"
echo
echo "Press Y if you've already done it"
echo
read CREATEDVM
if [[ ${CREATEDVM,,} = y ]]; then
    echo
else
    exit 0
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

vmname=null
cpuisolate=null
hostgovernor=null

while [[ ${vmname,,} == null ]] || [[ ${vmname,,} == "" ]]; do
   echo
   echo "What's the VM's name?"
   echo
   read OSNAME

    if [[ ${OSNAME,,} == null ]] || [[ ${OSNAME,,} == "" ]]; then
        echo
        echo "You must give a name!"
        echo
        sleep 1s
    else
        vmname=$OSNAME
    fi
done

sleep 1s

echo
echo "Do you want to isolate your VM CPU cores from your host?"
echo "Y - yes | Anything else - no"
echo
read CPUISO
cpuisolate=$CPUISO

sleep 1s

echo
echo "Do you want to change the governor to performance when turning on the VM"
echo "And changing it back to ondemand when turning off the VM?"
echo
echo "Y - yes | Anything else - no"
echo
read HOSTGOV
hostgovernor=$HOSTGOV

beginpath=/etc/libvirt/hooks/qemu.d/"$vmname"/prepare/begin
endpath=/etc/libvirt/hooks/qemu.d/"$vmname"/release/end
cpath=`pwd`
hpath="$cpath"/Hooks

sleep 1s

if [[ -d /etc/libvirt/ ]] && ! [[ -d /etc/libvirt/hooks ]]; then
    sudo mkdir -p /etc/libvirt/hooks
fi
if ! [[ -d /usr/share/vgabios ]]; then
    sudo mkdir /usr/share/vgabios
fi
fi
if ! [[ -d "$beginpath" ]]; then
    sudo mkdir -p "$beginpath"
fi
if ! [[ -d "$endpath" ]]; then
    sudo mkdir -p "$endpath"
fi
if [[ -f /etc/libvirt/hooks/qemu ]]; then
    sudo mv /etc/libvirt/hooks/qemu /etc/libvirt/hooks/qemu.old
fi
if [[ -f "$beginpath"/vfio-startup.sh ]]; then
    sudo mv "$beginpath"/vfio-startup.sh "$beginpath"/vfio-startup.sh.old
fi
if [[ -f "$endpath"/vfio-teardown.sh ]]; then
    sudo mv "$endpath"/vfio-teardown.sh "$endpath"/vfio-teardown.sh.old
fi
if [[ -f "$beginpath"/cpu_mode_performance.sh ]]; then
    sudo mv "$beginpath"/cpu_mode_performance.sh "$beginpath"/cpu_mode_performance.sh.old
fi
if [[ -f "$endpath"/cpu_mode_ondemand.sh ]]; then
    sudo mv "$endpath"/cpu_mode_ondemand.sh "$endpath"/cpu_mode_ondemand.sh.old
fi
if [[ -f "$beginpath"/cset.sh ]]; then
    sudo mv "$beginpath"/cset.sh "$beginpath"/cset.sh.old
fi
if [[ -f "$endpath"/cset.sh ]]; then
    sudo mv "$endpath"/cset.sh "$endpath"/cset.sh.old
fi
if [[ -f "$beginpath"/better_hugepages.sh ]]; then
    sudo mv "$beginpath"/better_hugepages.sh "$beginpath"/better_hugepages.sh.old
fi
if [[ -f /etc/systemd/system/libvirt-nosleep@.service ]]; then
    sudo rm /etc/systemd/system/libvirt-nosleep@.service
fi

chmod +x "$hpath"/*.sh
chmod +x "$hpath"/qemu
chmod +x "$hpath"/libvirt-nosleep@.service
sleep 1s

sudo cp "$hpath"/libvirt-nosleep@.service /etc/systemd/system
sudo cp "$hpath"/vfio-startup.sh "$beginpath"
sudo cp "$hpath"/vfio-teardown.sh "$endpath"
sudo cp "$hpath"/better_hugepages.sh "$beginpath"
sudo cp "$hpath"/qemu /etc/libvirt/hooks
sleep 1s

if [[ ${hostgovernor,,} = y ]]; then
    sudo cp "$hpath"/cpu_mode_performance.sh "$beginpath"
    sudo cp "$hpath"/cpu_mode_ondemand.sh "$endpath"
    sleep 1s
fi

if [[ ${cpuisolate,,} = y ]]; then
    sudo cp "$hpath"/cset.sh "$beginpath"
    sudo cp "$hpath"/cset.sh "$endpath"
    sleep 1s
fi

sudo cp "$hpath"/dev-hugepages.mount /etc/systemd/system
sleep 1s

sudo systemctl restart libvirtd
sleep 1s

echo
echo "Done"
echo

exit 0
