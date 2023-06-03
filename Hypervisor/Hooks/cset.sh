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

# Since I want to assign my most of my threads to the VM: I'll leave the first core (0) and sibling (8) Host and the rest to my VM
# For some reason Linux really likes core 0, so giving it to VM will cause a severe performance hit
# And we leave it's sibling thread (8) aswell for performance reasons as well.
#
# Try to keep all threads in the same CCX as possible and prefer the second CCX (or non-first if you have more than two CCX).
# Fo a visual representation you can install "hwloc" and run "lstopo" for a visual representation of what I just said.
#
# If using over 50% of threads, prefer using all threads of one CCX to start using the threads of another CCX
# If using less than 50% of threads, keep all threads in the same CCX
#
# Using "lstopo" you'll have a better understanding of what I'm saing.
#
# What you'll want to look for are the "P#X" where the X is the thread number
#
# For the masks: use this calulator: https://bitsum.com/tools/cpu-affinity-calculator/
# Copy the last numbers/letters into the masks for example
#
# I have 16 threads so I select all CPUs from 0 to 15
# The output was 0x000000000000FFFF, so I put the last characters in my TOTAL_CORES_MASK (In this case FFFF)
#
# For the HOST_CORES_MASK I select the CPUs 0 and 8
# The output was 0x0000000000000101, so I put the last characters in my HOST_CORES_MASK (In this case 101)
TOTAL_CORES='0-15'
TOTAL_CORES_MASK=FFFF           # 0-15
HOST_CORES='0,8'                # Cores reserved for host
HOST_CORES_MASK=101             # 0,8
VIRT_CORES='1-7,9-15'           # Cores reserved for virtual machine(s)

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
