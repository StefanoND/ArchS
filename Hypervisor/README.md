# Debian 12

## BIOS/UEFI Settings:

### REQUIRED

    Enable IOMMU
    Enable Virtualization (Intel VT-x/Intel VT-d, AMD-VTM/AMD Vi, plain "Virtualization Technology" or something like that)

### OPTIONAL (SECURITY)

    Enable TPM (Recommended)
    Enable Admin/User password
    Enable Secure Boot (Don't even bother if you have NVidia GPU)
        Reset Keys even if you've never used it before

#### If can't boot (or enable) secure boot after installing OS (change /dev/path accordingly)

    efibootmgr -c -d /dev/path -p 1 -L debian-shim -l \\EFI\\debian\\shimx64.efi

## Installation

    Language
    Keyboard
    Change Time & Date
    Software (Proprietary (I have NVidia GPU) + Secure Boot)
    Disk Setup
        LVM with Encryption (16GiB Swap)

[Ventoy and Secure Boot](https://www.ventoy.net/en/doc_secure.html)
