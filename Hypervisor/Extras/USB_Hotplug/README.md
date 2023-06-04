# Auto Hotplug USB Devices into VM
## Auto Hotplug is a way to be able to connect and disconnect USBs and the VM detect these change without having to manually pass them through (after some configuration)

First let's "install" the the script. This will just put the "usb-libvirt-hotplug.sh" script in its own folder in /opt

The "usb-libvirt-hotplug.sh" script is the one responsible for attaching and detaching the devices to/from the VM

Make 1-hotplug.sh script executable

    chmod +x 1-hotplug.sh

Run 1-hotplug.sh script

    sudo ./1-hotplug.sh
#
Now that we "installed" the above script, it'll do nothing on it's own, it needs to be run and receive inputs or else it won't even be called

For that we create a udev (udevadm) rule that will call the script and add the inputs needed for it to work

This script will create the udev rule in /etc/udev/rules.d named "90-usb-libvirt-hotplug.rules" if it isn't created yet and add the parameters for the input

The parameters are the Vendor ID of the USB device, the Model ID of the USB device and the name of the VM

What I recommend is, plug all USB devices you have into your Host Machine

To find the Vendor ID and Model ID of you USB devices, run "lsusb" it'll print all devices currently attached to your Host machine

It'll look like this

    Bus 006 Device 002: ID 0951:1666 Kingston Technology DataTraveler 100 G3/G4/SE9 G2/50
    Bus 006 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
    Bus 005 Device 004: ID 0c45:8508 Microdia USB DEVICE
    Bus 005 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 004 Device 002: ID 05e3:0616 Genesys Logic, Inc. hub
    Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
    Bus 003 Device 006: ID ee25:6611  USB  Keypad
    Bus 003 Device 005: ID 256c:006d HUION Huion Tablet
    Bus 003 Device 003: ID 05e3:0610 Genesys Logic, Inc. Hub
    Bus 003 Device 004: ID 1b1c:1ba6 Corsair CORSAIR SLIPSTREAM WIRELESS USB Receiver
    Bus 003 Device 002: ID 05e3:0610 Genesys Logic, Inc. Hub
    Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
    Bus 001 Device 005: ID 046d:0825 Logitech, Inc. Webcam C270
    Bus 001 Device 003: ID 046d:0ac4 Logitech, Inc. G535 Wireless Gaming Headset
    Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

In the ID part there are two "codes" separated by a colon ( : )

These are the Vendor and Model ID, the first one is the Vendor IF the second one is the Model ID

So I know that "Corsair [...] WIRELESS USB Receiver" is my Mouse and "Logitech [...] Headset" is my Headset, so

    My mouse's Vendor ID is: 1b1c, and Model ID is: 1ba6
    My headset's Vendor ID is: 046d, and Model ID is: 0ac4

Ignore the Linux Foundation X.X root hub and Genesys Logic, Inc. hub, they're linux's and the VM crashes if you try to pass them through

Also ignore your keyboard, it crashes the VM aswell

Now in the script it'll ask 3 things, the device's Vendor ID, Model ID and VM name, input them and the script will do the rest

This script can be run multiple times if you have more USB devices to add, the script gives you an option to rerun after each USB device you add

Make 2-adddevice.sh executable

    chmod +x 2-adddevice.sh

Run 2-adddevice.sh to configure devices

    sudo ./2-adddevice.sh
