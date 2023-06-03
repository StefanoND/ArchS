# Hugepages

## This is not needed anymore since QEMU uses Transparent Hugepages.

## If your VM manager (or QEMU version) doesn't use/have/support THP, follow the guide below to add Static Hugepages.

### To enable Static Hugepages you must add the following line to "/etc/fstab"
    hugetlbfs /dev/hugepages hugetlbfs defaults

### And in QEMU, add the following "memoryBacking" section above "vcpu placement" section
    <memoryBacking>
      <hugepages/>
    </memoryBacking>
    
## Note: The script hook [better_hugepages.sh](https://github.com/StefanoND/ArchS/blob/main/Hypervisor/Hooks/better_hugepages.sh) is for THP, it doesn't do anything for Static HugePages.
