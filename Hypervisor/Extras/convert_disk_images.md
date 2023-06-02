# Convert Disk Images

### To change the disk format you need the "qemu-img convert" command, followed by the arguments

### The most important arguments are -f (as in (file) format) and -O (as in output) (Upper Case O, not number 0)
### If you don't use the -f flag, it'll try to automatically detect the file format.

### When using the flags you have to specify by inputting the file formart, those are:

    NAME              | Format
    ---------------------------
    QCOW2 (KVM, Xen)  | qcow2
    QED (KVM)         | qed
    raw               | raw
    VDI (VirtualBox)  | vdi
    VHD (Hyper-V)     | vpc
    VMDK (VMware)     | vmdk

## After the flags you have to input the source file you want to convert and the output file you want it to be converted to

### So if you want to convert a qcow2 file to a raw file you type in the following command
    qemu-img convert -f qcow2 -O raw image.qcow2 image.img

### If they're in different locations (such as your libvirt folder) you can type in like this
    qemu-img convert -f qcow2 -O raw /var/lib/libvirt/images/image.qcow2 /var/lib/libvirt/images/image.img

### NOTE: The conversion progress will increase as the file size increases
### NOTE2: If you get permission denied, rerun the command as sudo

## If you're converting the img file of an existing VM you'll have configure your VM to point to the new img

### In your Virtual Disk tab (SATA Disk 1, VirtIO Disk 1, etc) click on XML and change two parameters:

    <driver name="qemu" type="qcow2" cache="writeback" discard="unmap"/>
    <source file="/var/lib/libvirt/images/image.qcow2"/>

### In <driver> section, change the type to raw and in <source file> change the extension to img so it'll look like this:

    <driver name="qemu" type="raw" cache="writeback" discard="unmap"/>
    <source file="/var/lib/libvirt/images/image.img"/>

#
  
### You can also use "virsh edit vm_name" if you know how to use it
