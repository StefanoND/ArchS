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

if ! pacman -Q | grep 'netctl'
    then
        echo
        echo "Installing netctl"
        echo
        sleep 1s
        sudo pacman -S netctl --noconfirm --needed
        sleep 1s
fi

if ! test -e /etc/sysctl.d/bridge.conf
    then
        echo
        echo "Disabling netfilter for bridges."
        echo
        sleep 1s
        sudo touch /etc/sysctl.d/bridge.conf
        printf "net.bridge.bridge-nf-call-ip6tables=0\nnet.bridge.bridge-nf-call-iptables=0\nnet.bridge.bridge-nf-call-arptables=0" | sudo tee /etc/sysctl.d/bridge.conf
        echo
        sleep 1s
fi

if ! test -e /etc/modules-load.d/br_netfilter.conf
    then
        echo
        echo "Making netfilter module to load at boot."
        echo
        sleep 1s
        sudo touch /etc/modules-load.d/br_netfilter.conf
        sleep 1s
        printf "br_netfilter" | sudo tee /etc/modules-load.d/br_netfilter.conf
        echo
        sleep 1s
fi

if ! test -e /etc/udev/rules.d/99-bridge.rules
    then
        echo
        echo "Creating rule to run the previous settings when the bridge module is loaded."
        echo
        sleep 1s
        sudo touch /etc/udev/rules.d/99-bridge.rules
        sleep 1s
        printf "ACTION==\"add\", SUBSYSTEM==\"module\", KERNEL==\"br_netfilter\", RUN+=\"/sbin/sysctl -p /etc/sysctl.d/bridge.conf\"" | sudo tee /etc/udev/rules.d/99-bridge.rules
        echo
        sleep 1s
fi

if ! test -e /etc/netctl/kvm-bridge
    then
        sudo touch /etc/netctl/kvm-bridge
        echo
        echo "Creating the KVM Bridge."
        echo
        sleep 1s
        ip addr
        sleep 1s
        answereth=n
        answertap=n
        answerbr=n
        answerdm=n
        netdevice=null
        tapdevice=null
        domainame=null
        bridgename=null
        ipaddress=192.168.100.1
        netmask=255.255.255.0
        gateway=192.168.100.255
        dns=192.168.100.255
        rangestart=192.168.100.128
        rangeend=192.168.100.254
        while [ ${answereth,,} = n ]
            do
                echo
                echo "What's your main network device? Should start with \"enp\""
                echo
                sleep 1s
                read ETH
                sleep 1s
                echo
                echo "Is \"$ETH\", correct?"
                echo
                read answereth
                if [ ${answereth,,} = y ]
                    then
                        netdevice=$ETH
                fi
        done
        sleep 1s
        while [ ${answertap,,} = n ]
            do
                echo
                echo "What's your tap network device created by qemu? Should start with \"virbr\""
                echo
                sleep 1s
                read TAP
                sleep 1s
                echo
                echo "Is \"$TAP\", correct?"
                echo
                read answertap
                if [ ${answertap,,} = y ]
                    then
                        tapdevice=$TAP
                fi
        done
        sleep 1s
        while [ ${answerbr,,} = n ]
            do
                echo
                echo "What name should the bridged connection have? (Recommended br10)"
                echo
                sleep 1s
                read BRNAME
                sleep 1s
                echo
                echo "Is \"$BRNAME\" the desired name you want to give the bridged connection?"
                echo
                read answerbr
                if [ ${answerbr,,} = y ]
                    then
                        bridgename=$BRNAME
                fi
        done
        sleep 1s
        while [ ${answerdm,,} = n ]
            do
                echo
                echo "What name should the DNS Domain have? (Recommended virbr1)"
                echo
                sleep 1s
                read DMNAME
                sleep 1s
                echo
                echo "Is \"$DMNAME\" the desired name you want to give the DNS domain?"
                echo
                read answerdm
                if [ ${answerdm,,} = y ]
                    then
                        domainame=$DMNAME
                fi
        done
        sleep 1s
        echo
        echo "Configuring \"kvm-bridge\""
        echo
        sleep 1s
        printf "Description=\"Bridge Interface $bridgename : $netdevice,$tapdevice\"\nInterface=$bridgename\nConnection=bridge\nBindsToInterfaces=($netdevice $tapdevice)\n" | sudo tee /etc/netctl/kvm-bridge
        sleep 1s
        echo
        echo "Do you want to use DHCP or Static IP? Press 1 for DHCP or 2 for Static IP"
        read IPTYPE
        if [ ${IPTYPE,,} = 1 ]
            then
                printf "IP=dhcp\n" | sudo tee -a /etc/netctl/kvm-bridge
                sleep 1s
                echo
                echo "Do you also want to enable DHCP for IPv6?"
                echo
                read IPV6DHCP
                if [ ${IPV6DHCP,,} = 1 ]
                    then
                        printf "IP6=dhcp" | sudo tee -a /etc/netctl/kvm-bridge
                fi
        elif [ ${IPTYPE,,} = 2 ]
            then
                printf "IP=static" | sudo tee -a /etc/netctl/kvm-bridge
                sleep 1s
                echo
                echo "What's the IP address you want to give to the bridged connection? (Recommended $ipaddress)"
                echo
                read RADDRESS
                ipaddress=$RADDRESS
                echo
                sleep 1s
                echo
                echo "What's the Gateway address you want to give to the bridged connection? (Recommended $gateway)"
                echo
                read RGATEWAY
                gateway=$RGATEWAY
                echo
                sleep 1s
                echo
                echo "What's the DNS address you want to give to the bridged connection? (Recommended same as gateway: $gateway)"
                echo
                read RDNS
                dns=$RDNS
                echo
                sleep 1s
                echo
                echo "What's the Netmask you want to give to the bridged connection? (Recommended same as gateway: $netmask)"
                echo
                read RNETMASK
                netmask=$RNETMASK
                echo
                sleep 1s
                echo
                echo "What's the starting range of your ip address you want to give to the bridged connection? (Recommended same as gateway: $rangestart)"
                echo
                read RRANGESTART
                rangestart=$RRANGESTART
                echo
                sleep 1s
                echo
                echo "What's the ending range of your ip address you want to give to the bridged connection? (Recommended same as gateway: $rangeend)"
                echo
                read RRANGEEND
                rangeend=$RRANGEEND
                echo
                sleep 1s
                printf "Address='$ipaddress/24'\n" | sudo tee -a /etc/netctl/kvm-bridge
                printf "Address='$gateway'\n" | sudo tee -a /etc/netctl/kvm-bridge
                printf "Address='$dns'\n" | sudo tee -a /etc/netctl/kvm-bridge
                echo
                sleep 1s
                echo
                echo "Do you want your bridged connection to use the MAC address of $netdevice?"
                echo "Press Y for yes or No for the bridged connection to have it's own unique MAC address"
                echo
                read MAC
                if [ ${MAC,,} = y ]
                    then
                        cat /sys/class/net/$netdevice/address | sudo tee -a /etc/netctl/kvm-bridge
                        echo
                fi
                sleep 1s
                echo
                echo "Ignore (R)STP and activate the bridge immediately"
                echo
                printf "\n\nSkipForwardingDelay=yes\n" | sudo tee -a /etc/netctl/kvm-bridge
                echo
                sleep 1s
                echo
                echo "Do you want to enable a static IP on wired interface wether the cable is connected or not?"
                echo "Press Y for yes or N for no"
                echo
                read SKIP
                if [ ${SKIP,,} = y ]
                    then
                        printf "SkipNoCarrier=yes\n" | sudo tee -a /etc/netctl/kvm-bridge
                        echo
                fi
        fi
        if ! test -e /home/$(logname)/bridged-network.xml
            then
                touch /home/$(logname)/bridged-network.xml
                printf "<network>\n  <name>$bridgename</name>\n  <forward mode=\"nat\">\n    <nat>\n      <port start=\"1024\" end=\"65535\"/>\n    </nat>\n  </forward>\n  <bridge name=\"$domainame\" stp=\"on\" delay=\"0\"/>\n  <domain name=\"$bridgename\"/>\n  <ip address=\"$ipaddress\" netmask=\"$netmask\">\n    <dhcp>\n      <range start=\"$rangestart\" end=\"$rangeend\"/>\n    </dhcp>\n  </ip>\n</network>" | tee /home/$(logname)/bridged-network.xml
        fi
        sleep 1s
        echo
        echo "Defining Virtual Network"
        echo
        sudo virsh net-define /home/$(logname)/bridged-network.xml
        sleep 1s
        echo
        echo "Starting Virtual Network"
        echo
        sudo virsh net-start $bridgename
        sleep 1s
        echo
        echo "Making Virtual Network start at boot"
        echo
        sudo virsh net-autostart $bridgename
        sleep 1s
        echo
        echo "Disabling $netdevice"
        echo
        sudo ip link set $netdevice down
        sleep 5s
        echo
        echo "Starting kvm-bridge"
        echo
        sudo netctl start kvm-bridge
        sleep 1s
        echo
        echo "Enabling kvm-bridge"
        echo
        sudo systemctl enable netctl-auto@kvm-bridge.service
        sudo netctl enable kvm-bridge
        sudo systemctl daemon-reload
        sleep 1s
        echo
        echo "Disable your connection from auto connecting"
        echo "Go to System Settings->Connections->$netdevice click on \"General Configuration\" tab and uncheck \"Connect Automatically with priority\""
        echo
        echo "After that click on \"$bridgename\" and \"General Configuration\" tab, check \"Connect automatically with priotity\" and type \"-100\""
        echo "Then click on \"Bridge\" tab, select \"$netdevice (802-3-ethernet)\" and click on \"Edit\""
        echo "Click the \"General Configuration\" tab, check \"Connect automatically with priotity\" and type \"-100\""
        echo "Save and apply all changes"
        echo
        echo "If you're having trouble applying changes"
        echo "Run \"sudo netctl stop kvm-bridge\" and then \"sudo netctl start kvm-bridge\""
        echo "You should now be able to make the changes mentioned above"
        echo
        echo "Press any button when you're done"
        read ANYBUTTON
        sleep 1s
        echo
        echo "To use the bridged network in your VM create a new NIC or Edit existing"
        echo "\"Network source:\" select \"Bridge device...\""
        echo "\"Device Name:\" must be \"$bridgename\""
        echo "\"Device model:\" choose \"virtio\""
        echo "If the NIC MAC address doesn't match the MAC address of the network copy-paste it"
        echo "Open Virtual Machine Manager click on Edit->Connection Details, click on \"$bridgename\" and click on \"XML\" tab"
        echo "Copy the \"mac address\" to your VM NIC's mac address"
        echo "Press any key when you're done"
        read ANYKEYDONE
        echo
        echo "Done"
        echo
else
    sudo netctl start kvm-bridge
fi

sleep 1s
echo
echo "Done..."
echo
sleep 1s
echo
echo "Press Y to reboot now or N if you plan to manually reboot later."
echo
read REBOOT
if [ ${REBOOT,,} = y ]; then
    reboot
fi
exit 0
