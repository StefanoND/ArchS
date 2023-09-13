# Debian 12

## BIOS/UEFI Settings:

### REQUIRED

    Enable IOMMU
    Enable Virtualization (Intel VT-x/Intel VT-d, AMD-VTM/AMD Vi, plain "Virtualization Technology" or something like that)

### OPTIONAL (SECURITY)

    Enable TPM (Recommended)
    Enable Admin/User password
    Enable Secure Boot (Reset Keys even if you've never used it before)

## Installation

    Language
    Keyboard
    Change Time & Date
    Software (Proprietary (I have NVidia GPU) + Secure Boot)
    Disk Setup
        LVM with Encryption (16GiB Swap)
