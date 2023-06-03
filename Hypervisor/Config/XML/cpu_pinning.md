# CPU Pinning

### Add CPUTune section in XML right below "vcpu placement="static"...."
### This will ensure the VM will only use those cores instead of searching and using available cores (which reduces performance)
### The amount of cores depends on what you'll be using the VM for
### If you have a secondary GPU and will only game on the VM, usually 50% of threads is enough
### If just for browsing the internet, 4-8 threads is enough
### Since I'm going to Daily Drive this VM and only have 1 GPU I'll do a single GPU-Passthrough so I'll assign all threads to it
### Physical CPU siblings must be Virtual CPU siblings (Check "Note 2" at the bottom of this page)
### Assign at least threads 0 and 8 in "emulatorpin cpuset" which the host will use.
### Linux likes thread 0 and, in my case, thread 8 is 0's sibling. Check lstopo (need to instal "hwloc") and/or lscpu -e for yours
    <cputune>
      <vcpupin vcpu="0" cpuset="0"/>
      <vcpupin vcpu="1" cpuset="8"/>
      <vcpupin vcpu="2" cpuset="1"/>
      <vcpupin vcpu="3" cpuset="9"/>
      <vcpupin vcpu="4" cpuset="2"/>
      <vcpupin vcpu="5" cpuset="10"/>
      <vcpupin vcpu="6" cpuset="3"/>
      <vcpupin vcpu="7" cpuset="11"/>
      <vcpupin vcpu="8" cpuset="4"/>
      <vcpupin vcpu="9" cpuset="12"/>
      <vcpupin vcpu="10" cpuset="5"/>
      <vcpupin vcpu="11" cpuset="13"/>
      <vcpupin vcpu="12" cpuset="6"/>
      <vcpupin vcpu="13" cpuset="14"/>
      <vcpupin vcpu="14" cpuset="7"/>
      <vcpupin vcpu="15" cpuset="15"/>
      <emulatorpin cpuset="0,8"/>
    </cputune>

## CPU Siblings/Cousins
### CPU Siblings are threads in of the same core, and CPU cousins are threads from different cores
### In the illustration below, thread 0 and thread 8 are siblings be cause they share the same core (Core 1)
### Thread 3 and 11 are siblings be cause they share the same core (Core 4) and so on
### Thread 0 and thread 1 are cousins be cause they're in different cores (Core 1 and 2 respectively)
### Thread 9 and thread 12 are cousins be cause they're in different cores (Core 2 and 5 respectively)
        ____________________________________________________________________________
        |                                    CPU                                    |
        |  ___________________________________ ___________________________________  |
        | |               CCX 1               |             CCX 2                 | |
        | |  ______________   ______________  | ______________   ______________   | |
        | | |    CORE 1    | |    CORE 2    | | |    CORE 5    | |    CORE 6    | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | | | THREAD 0 | | | | THREAD 1 | | | | | THREAD 4 | | | | THREAD 5 | | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | | | THREAD 8 | | | | THREAD 9 | | | | | THREAD12 | | | | THREAD13 | | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | |--------------| |--------------| | |--------------| |--------------| | |
        | |  ______________   ______________  |  ______________   ______________  | |
        | | |    CORE 3    | |    CORE 4    | | |    CORE 7    | |    CORE 8    | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | | | THREAD 2 | | | | THREAD 3 | | | | | THREAD 6 | | | | THREAD 7 | | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | | | THREAD10 | | | | THREAD11 | | | | | THREAD14 | | | | THREAD15 | | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | |--------------| |--------------| | |--------------| |--------------| | |
        | |-----------------------------------|-----------------------------------| |
        |---------------------------------------------------------------------------|

### Note: This is only a visual representation of a 8 Core/16 Thread CPU, it's not an exact match of a real layout
### CPUs with different cores will have different layouts, higher core-count CPUs will have more CCXs
### CPUs without hyperthreading (Simultaneous Multi-Threading SMT for AMD) will have 1 thread per core (instead of 2)

### Note 2: This is only true for physical CPUs, QEMU's virtual CPUs siblings are 0-1, 2-3, 4-5, 6-7, etc
### So to make physical siblings be the same virtual siblings, you'll assign cores 0 and 8 to vcores 0 and 1 respectively,
### cores 1 and 9 to vcores 2 and 3 respectively, cores 2 and 10 to vcores 4 and 5 respectively and so on
#
### If you want full isolation (IE exclusive threads for Host and exclusive threads for VM) you must install cpuset and use the script hook [cset.sh](https://github.com/StefanoND/ArchS/blob/main/Hypervisor/Hooks/cset.sh)
### Use this page as well as cset.sh's comments on how to properly configure it

### Debian
    sudo apt install cpuset -y

### Arch
    sudo pacman -S cpuset --noconfirm --needed
