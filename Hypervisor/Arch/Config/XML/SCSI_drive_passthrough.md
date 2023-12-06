# SCSI drive passthrough (Any storage drive)

### Make sure you have "Enable XML Editing" enabled

### In QEMU select "CPUs" and click on "XML" tab

### Add the "iothreads" section below "vcpu placement" section and above "cputune" section
    <iothreads>1</iothreads>

### Add the "iothreadpin" section in the last line INSIDE "cputune" section
    <iothreadpin iothread="1" cpuset="0-1,8-9"/>

#### Note: in the "cpuset" you should have at least 2 threads, anything higher than 4 threads gives diminishing returns
#### And will affect performance (not much) of the rest of the system
#### I give 4 threads be cause I have threads to spare (Threads from 1 to 2 and from 9 to 10)
#### Note 2: The "-" is the range, the "," is a separator, so 0-3 = 4 threads (0, 1, 2 and 3) and 0,3 = 2 threads (0 and 3).

### The end result should look something like this
    <vcpu placement=....</vcpu>
    <iothreads>1</iothreads>
    <cputune>
      <vcpupin vcpu="0" cpuset="4"/>
      ...
      <iothreadpin iothread="1" cpuset="1-2,9-10"/>
    <cputune>

### Now it's time to add the SCSI Controller
    - Add Hardwade
      - Controller
        - Type: SCSI
        - Model: VirtIO SCSI

### Now click on "XML" and add a "driver" section right below in the second line, below the start of the "controller" section, like this
      <driver queues="4" iothread="1"/>

### It'll look something like this
    <controller type="scsi" index="0" model="virtio-scsi">
      <driver queues="4" iothread="1"/>
      ...
    </controller>

### Note: The "queues" is the amount of threads from "cpuset" in "iothreadpin" ("1-2,9-10" which are a total of 4 threads)

### Now click into your "SCSI Disk X" and click "XML" and change the following line
    <driver name="qemu" type="qcow2" cache="none" discard="unmap"/>

### Add io="native" in the "driver" section"
    <driver name="qemu" type="qcow2" cache="none" io="native" discard="unmap"/>

### Done
