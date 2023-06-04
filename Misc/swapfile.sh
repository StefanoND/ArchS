#!/usr/bin/env bash

# Still testing, don use

echo
echo "TESTING, DON'T USE THIS SCRIPT"
echo
sleep 1s

exit 0

memsize=`grep MemTotal /proc/meminfo | grep -Eo '[0-9]{6,12}'`
swapsize=0
hibernate=n
btrfspart=n
fs=k

echo
echo "Is your root (/) a btrfs partition?"
echo "Y - Yes | Anything else - no"
echo
read BTRFS
if [[ ${BTRFS,,} = y ]]; then
    btrfspart=y
    fs=g
fi

echo
echo "You want to enable hibernation?"
echo "Y - Yes | Anything else - No"
echo
read HYBER
hibernate=$HYBER

if [[ $memsize -ge 256000000 ]]; then
    if [[ ${hibernate,,} = y ]]; then
        swapsize=270$fs
    else
        swapsize=4$fs
    fi
elif [[ $memsize -ge 128000000 ]]; then
    if [[ ${hibernate,,} = y ]]; then
        swapsize=135$fs
    else
        swapsize=4$fs
    fi
elif [[ $memsize -ge 64000000 ]]; then
    if [[ ${hibernate,,} = y ]]; then
        swapsize=68$fs
    else
        swapsize=4$fs
    fi
elif [[ $memsize -ge 32000000 ]]; then
    if [[ ${hibernate,,} = y ]]; then
        swapsize=34$fs
    else
        swapsize=4$fs
    fi
elif [[ $memsize -ge 16000000 ]]; then
    if [[ ${hibernate,,} = y ]]; then
        swapsize=17$fs
    else
        swapsize=8$fs
    fi
elif [[ $memsize -ge 8000000 ]]; then
    swapsize=12$fs
elif [[ $memsize -ge 4000000 ]]; then
    swapsize=6$fs
elif [[ $memsize -ge 2000000 ]]; then
    swapsize=3$fs
fi

if [[ ${btrfspart,,} = y ]]; then
    echo
    echo "Creating /swap subvolume"
    echo
    sleep 1s
    sudo btrfs filesystem mkswapfile --size $swapsize  --uuid clear /swapfile
    sleep 1s
    echo
    echo "Enabling the swapfile"
    echo
    sleep 1s
    sudo swapon /swapfile
else
    echo
    echo "Creating /swapfile file"
    echo
    sleep 1s
    sudo dd if=/dev/zero of=/swapfile bs=1M count=$swapsize status=progress
    sleep 1s
    echo
    echo "Setting the right permissions (a world-readable swap file is a huge local vulnerability)"
    echo
    sleep 1s
    sudo chmod 0600 /swapfile
    sleep 1s
    echo
    echo "Formatting it to a swapfile"
    echo
    sleep 1s
    sudo mkswap -U clear /swapfile
    sleep 1s
    echo
    echo "Enabling the swapfile"
    echo
    sleep 1s
    sudo swapon /swapfile
fi
