# Rocky Linux 9.2

## BIOS/UEFI Settings:

### REQUIRED

    Enable IOMMU
    Enable Virtualization (Intel VT-x/Intel VT-d, AMD-VTM/AMD Vi, plain "Virtualization Technology" or something like that)

### OPTIONAL (SECURITY)

    Enable TPM (Recommended)
    Enable Admin/User password
    Enable Secure Boot (Reset Keys even if you've never used it before)

## Installation

    Change Keyboard
    Change Time & Date
    Install Destination
        /boot - 1GiB
        /boot/efi - 1 GiB
        swap - none (Enabled if 16GB or lower RAM, ENCRYPTED)
        / - 16 GiB (Encrypted)
        /home - Rest (Encrypted)
    KDUMP Disabled
    Network & Host Name - Any
    Root Password/Account Disabled
    User - Admin/Sudo account (password required)

## Initial Setup

    Accept License
    Keep KDUMP disabled
