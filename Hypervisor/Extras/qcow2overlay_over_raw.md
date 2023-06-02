Copy paste from [RO1](https://unix.stackexchange.com/users/335636/ro1) in [Stack Exchange](https://unix.stackexchange.com/questions/464507/how-to-apply-qcow2-snapshot-to-overlay-raw-disk-image)'s post
#
Once you convert the raw disk to qcow2 format, use "qemu-img" for creating a snapshot from base image.

qemu-img create -f qcow2 -b Image.qcow2 Image_Snapshot.qcow2

The snapshot will have a size of around 200 KB. Further you will need to install new Guest VM which uses snapshot as its disk image.

virt-install --virt-type=kvm --name=Name --ram 2048 --vcpus=2 --virt-type=kvm --hvm --network network=default --graphics vnc --disk Image_Snapshot.qcow2 --boot=hd --noautoconsole

Now you can start your new Guest VM.
And the snapshot will store only the changes in base image, thus saving a lot of space on your host machine :)
#
Note, you can add to an existing VM aswell, you can also use the GUI to add it.
