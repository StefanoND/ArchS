# Works with all bus types, even though VirtIO seems to be the "better" one out-of-the-box, SCSI is better after configuring it

# Here's a step-by-step guide on how to do it

### Click on "Add Hardware", click on "Storage" tab
### In the details tab, select the "Select or create custom Storage"
### Now we'll need to input our Drive's path, I'll choose the path by id. Open the terminal and put this command:
    ls -l /dev/disk/by-id/

### Mine shows like this the SDA is my SATA SSD, my sdb is my SATA HDD and my nvme0n1 is my PCIe SSD (PCIe NVMe):
    lrwxrwxrwx 1 root root  9 mar 12 17:07 ata-KINGSTON_SA400S37240G_50026B77824F5B90 -> ../../sda
    lrwxrwxrwx 1 root root 10 mar 12 17:07 ata-KINGSTON_SA400S37240G_50026B77824F5B90-part1 -> ../../sda1
    lrwxrwxrwx 1 root root  9 mar 12 17:21 ata-ST2000DM008-2FR102_WFL409A4 -> ../../sdb
    lrwxrwxrwx 1 root root 10 mar 12 17:21 ata-ST2000DM008-2FR102_WFL409A4-part1 -> ../../sdb1
    lrwxrwxrwx 1 root root 10 mar 12 17:21 ata-ST2000DM008-2FR102_WFL409A4-part2 -> ../../sdb2
    lrwxrwxrwx 1 root root 13 mar 12 17:07 nvme-eui.002538d321b3afc1 -> ../../nvme0n1
    lrwxrwxrwx 1 root root 15 mar 12 17:07 nvme-eui.002538d321b3afc1-part1 -> ../../nvme0n1p1
    lrwxrwxrwx 1 root root 15 mar 12 17:07 nvme-eui.002538d321b3afc1-part2 -> ../../nvme0n1p2
    lrwxrwxrwx 1 root root 15 mar 12 17:07 nvme-eui.002538d321b3afc1-part3 -> ../../nvme0n1p3
    lrwxrwxrwx 1 root root 13 mar 12 17:07 nvme-Samsung_SSD_980_1TB_S649NX0T349561F -> ../../nvme0n1
    lrwxrwxrwx 1 root root 15 mar 12 17:07 nvme-Samsung_SSD_980_1TB_S649NX0T349561F-part1 -> ../../nvme0n1p1
    lrwxrwxrwx 1 root root 15 mar 12 17:07 nvme-Samsung_SSD_980_1TB_S649NX0T349561F-part2 -> ../../nvme0n1p2
    lrwxrwxrwx 1 root root 15 mar 12 17:07 nvme-Samsung_SSD_980_1TB_S649NX0T349561F-part3 -> ../../nvme0n1p3

### Since I want to passthrough my HDD I'll copy the: "/dev/disk/by-id/ata-ST2000DM008-2FR102_WFL409A4" to QEMU

## In QEMU

    - Add Hardware
      - Check "Select or create custom storage"
        - Paste "/dev/disk/by-id/ata-ST2000DM008-2FR102_WFL409A4" (don't click on "Manage...")
      - Device Type: "Disk device"
      - Bus Type: Any (I recommend SCSI for best performance but it requires a few more steps)
        - Advanced Options (If you chose SCSI)
          - Serial: Leave Empty
          - Cache mode: none
          - Discard mode: unmap

## If you chose VirtIO, SATA or USB just click finish and you're done.

## If you chose SCSI check out my guide: [SCSI Drive Passthrough](https://github.com/StefanoND/ArchS/blob/main/Hypervisor/Config/XML/SCSI_drive_passthrough.md)
