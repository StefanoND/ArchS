#!/usr/bin/env bash

if ! [ $EUID -ne 0 ]; then
    echo
    echo "Don't run this script as root."
    echo
    sleep 1s
    exit 1
fi

if ! groups|grep wheel>/dev/null;then
    echo
    echo "You need to be a member of the wheel to run me!"
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

sleep 1s

if test -e /etc/libvirt/ && ! test -e /etc/libvirt/hooks; then
    echo "mkdir -p /etc/libvirt/hooks"
    sudo mkdir -p /etc/libvirt/hooks
fi

if ! test -e /usr/share/vgabios; then
    echo "mkdir /usr/share/vgabios"
    sudo mkdir /usr/share/vgabios
fi
if test -e /etc/libvirt/hooks/qemu; then
    echo "mv /etc/libvirt/hooks/qemu /etc/libvirt/hooks/qemu_last_backup"
    sudo mv /etc/libvirt/hooks/qemu /etc/libvirt/hooks/qemu_last_backup
fi
if ! test -e /etc/libvirt/hooks/qemu.d; then
    echo "mkdir -p /etc/libvirt/hooks/qemu.d"
    sudo mkdir -p /etc/libvirt/hooks/qemu.d
fi
if ! test -e /etc/libvirt/hooks/qemu.d/$vmname; then
    echo "mkdir -p /etc/libvirt/hooks/qemu.d/$vmname"
    sudo mkdir -p /etc/libvirt/hooks/qemu.d/$vmname
fi
if ! test -e /etc/libvirt/hooks/qemu.d/$vmname/prepare; then
    echo "mkdir -p /etc/libvirt/hooks/qemu.d/$vmname/prepare"
    sudo mkdir -p /etc/libvirt/hooks/qemu.d/$vmname/prepare
fi
if ! test -e /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin; then
    echo "mkdir -p /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin"
    sudo mkdir -p /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin
fi
if ! test -e /etc/libvirt/hooks/qemu.d/$vmname/release; then
    echo "mkdir -p /etc/libvirt/hooks/qemu.d/$vmname/release"
    sudo mkdir -p /etc/libvirt/hooks/qemu.d/$vmname/release
fi
if ! test -e /etc/libvirt/hooks/qemu.d/$vmname/release/end; then
    echo "mkdir -p /etc/libvirt/hooks/qemu.d/$vmname/release/end"
    sudo mkdir -p /etc/libvirt/hooks/qemu.d/$vmname/release/end
fi
if test -e /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/vfio-startup.sh; then
    echo "mv /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/vfio-startup.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/vfio-startup.sh.old"
    sudo mv /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/vfio-startup.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/vfio-startup.sh.old
fi
if test -e /etc/libvirt/hooks/qemu.d/$vmname/release/end/vfio-teardown.sh; then
    echo "mv /etc/libvirt/hooks/qemu.d/$vmname/release/end/vfio-teardown.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end/vfio-teardown.sh.old"
    sudo mv /etc/libvirt/hooks/qemu.d/$vmname/release/end/vfio-teardown.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end/vfio-teardown.sh.old
fi
if test -e /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/cpu_mode_performance.sh; then
    echo "mv /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/cpu_mode_performance.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/cpu_mode_performance.sh.old"
    sudo mv /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/cpu_mode_performance.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/cpu_mode_performance.sh.old
fi
if test -e /etc/libvirt/hooks/qemu.d/$vmname/release/end/cpu_mode_ondemand.sh; then
    echo "mv /etc/libvirt/hooks/qemu.d/$vmname/release/end/cpu_mode_ondemand.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end/cpu_mode_ondemand.sh.old"
    sudo mv /etc/libvirt/hooks/qemu.d/$vmname/release/end/cpu_mode_ondemand.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end/cpu_mode_ondemand.sh.old
fi
if test -e /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/cset.sh; then
    echo "mv /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/cset.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/cset.sh.old"
    sudo mv /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/cset.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/cset.sh.old
fi
if test -e /etc/libvirt/hooks/qemu.d/$vmname/release/end/cset.sh; then
    echo "mv /etc/libvirt/hooks/qemu.d/$vmname/release/end/cset.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end/cset.sh.old"
    sudo mv /etc/libvirt/hooks/qemu.d/$vmname/release/end/cset.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end/cset.sh.old
fi
if test -e /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/better_hugepages.sh; then
    echo "mv /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/better_hugepages.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/better_hugepages.sh.old"
    sudo mv /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/better_hugepages.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/better_hugepages.sh.old
fi
if test -e /etc/systemd/system/libvirt-nosleep@.service; then
    echo "rm /etc/systemd/system/libvirt-nosleep@.service"
    sudo rm /etc/systemd/system/libvirt-nosleep@.service
fi

cpath=`pwd`
hpath="$cpath"/Hooks

sleep 1s
chmod +x $hpath/*.sh
chmod +x $hpath/qemu
chmod +x $hpath/libvirt-nosleep@.service
sleep 1s

echo "cp $hpath/libvirt-nosleep@.service /etc/systemd/system"
sudo cp $hpath/libvirt-nosleep@.service /etc/systemd/system
echo "cp $hpath/vfio-startup.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin"
sudo cp $hpath/vfio-startup.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin
echo "cp $hpath/vfio-teardown.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end"
sudo cp $hpath/vfio-teardown.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end
echo "cp $hpath/better_hugepages.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin"
sudo cp $hpath/better_hugepages.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin
echo "cp $hpath/qemu /etc/libvirt/hooks"
sudo cp $hpath/qemu /etc/libvirt/hooks

if [[ ${hostgovernor,,} = y ]]; then
    echo "cp $hpath/cpu_mode_performance.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin"
    sudo cp $hpath/cpu_mode_performance.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin
    echo "cp $hpath/cpu_mode_ondemand.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end"
    sudo cp $hpath/cpu_mode_ondemand.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end
fi

if [[ ${cpuisolate,,} = y ]]; then
    echo "cp $hpath/cset.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin"
    sudo cp $hpath/cset.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin
    echo "cp $hpath/cset.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end"
    sudo cp $hpath/cset.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end
fi


echo "cp $hpath/dev-hugepages.mount /etc/systemd/system"
sudo cp $hpath/dev-hugepages.mount /etc/systemd/system

sudo systemctl restart libvirtd

sleep 1s
echo
echo "Done"
echo
sleep 1s
exit 0
