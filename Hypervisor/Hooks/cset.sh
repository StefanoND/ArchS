#!/usr/bin/env bash

#
# Original author: Rokas Kupstys <rokups@zoho.com>
# Heavily modified by: Danny Lin <danny@kdrag0n.dev>
#
# This hook uses the `cset` tool to dynamically isolate and unisolate CPUs using
# the kernel's cgroup cpusets feature. While it's not as effective as
# full kernel-level scheduler and timekeeping isolation, it still does wonders
# for VM latency as compared to not isolating CPUs at all. Note that vCPU thread
# affinity is a must for this to work properly.
#
# Original source: https://rokups.github.io/#!pages/gaming-vm-performance.md
#
# Target file locations:
#   - $SYSCONFDIR/hooks/qemu.d/vm_name/prepare/begin/cset.sh
#   - $SYSCONFDIR/hooks/qemu.d/vm_name/release/end/cset.sh
# $SYSCONFDIR is usually /etc/libvirt.
#

# Since I want to assign my Host and VM each to a different CCX: I'll leave the first CCX to my Host and the second to my VM
# Fo a visual representation you can install "hwloc" and run "lstopo" for a visual representation of what I just said
# Since the 1st CCX have the cores 0-3 and threads 8-11 and the 2nd CCX have the cores 4-7 and threads are 12-15
# I'll fill HOST_CORES and VIRT_CORES accordingly
#
# For the masks: use this calulator: https://bitsum.com/tools/cpu-affinity-calculator/
# Copy the last numbers/letters into the masks for example
#
# I have 16 threads so I select all CPUs from 0 to 15
# The output was 0x000000000000FFFF, so I put the last characters in my TOTAL_CORES_MASK (In this case FFFF)
#
# For the HOST_CORES_MASK I select the CPUs 0 to 3 and 8 to 11
# The output was 0x0000000000000F0F, so I put the last characters in my HOST_CORES_MASK (In this case F0F)
TOTAL_CORES='0-15'
TOTAL_CORES_MASK=FFFF           # 0-15
HOST_CORES='0-3,8-11'           # Cores reserved for host
HOST_CORES_MASK=F0F             # 0-3,8-11
VIRT_CORES='4-7,12-15'          # Cores reserved for virtual machine(s)

VM_NAME="$1"
VM_ACTION="$2/$3"

function shield_vm() {
    cset -m set -c $TOTAL_CORES -s machine.slice
    cset -m shield --kthread on --cpu $VIRT_CORES
}

function unshield_vm() {
    cset -m shield --reset
}

# For convenient manual invocation
if [[ "$VM_NAME" == "shield" ]]; then
    shield_vm
    exit
elif [[ "$VM_NAME" == "unshield" ]]; then
    unshield_vm
    exit
fi

if [[ "$VM_ACTION" == "prepare/begin" ]]; then
    echo "libvirt-qemu cset: Reserving CPUs $VIRT_CORES for VM $VM_NAME" > /dev/kmsg 2>&1
    shield_vm > /dev/kmsg 2>&1

    # the kernel's dirty page writeback mechanism uses kthread workers. They introduce
    # massive arbitrary latencies when doing disk writes on the host and aren't
    # migrated by cset. Restrict the workqueue to use only cpu 0.
    echo $HOST_CORES_MASK > /sys/bus/workqueue/devices/writeback/cpumask
    echo 0 > /sys/bus/workqueue/devices/writeback/numa

    echo "libvirt-qemu cset: Successfully reserved CPUs $VIRT_CORES" > /dev/kmsg 2>&1
elif [[ "$VM_ACTION" == "release/end" ]]; then
    echo "libvirt-qemu cset: Releasing CPUs $VIRT_CORES from VM $VM_NAME" > /dev/kmsg 2>&1
    unshield_vm > /dev/kmsg 2>&1

    # Revert changes made to the writeback workqueue
    echo $TOTAL_CORES_MASK > /sys/bus/workqueue/devices/writeback/cpumask
    echo 1 > /sys/bus/workqueue/devices/writeback/numa

    echo "libvirt-qemu cset: Successfully released CPUs $VIRT_CORES" > /dev/kmsg 2>&1
fi
