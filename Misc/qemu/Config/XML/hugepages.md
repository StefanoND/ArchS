# Hugepages

## This is not needed anymore since QEMU uses Transparent Hugepages.

### If your VM manager (or QEMU version) doesn't use/have/support THP, you'll have to setup Static Hugepages, google it.   
### Note: The script hook [better_hugepages.sh](https://github.com/StefanoND/ArchS/blob/main/Hypervisor/Hooks/better_hugepages.sh) is for THP, it doesn't do anything for Static HugePages.
