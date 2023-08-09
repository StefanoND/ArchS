# Display SDL

### To use SDL acceleration, you must change your Display Spice to be the same as below (Change USERNAME to yours)

    <graphics type="sdl">
      <gl enable="yes"/>
    </graphics>

### At the beginning change <domain type="kvm"> to

    <domain xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0" type="kvm">

### At the end, before </domain> add these command lines (Change USERNAME to yours)

    <qemu:commandline>
      <qemu:env name="DISPLAY" value=":0"/>
      <qemu:env name="XAUTHORITY" value="/home/USERNAME/.Xauthority"/>
    </qemu:commandline>

### Audio must be like this

    <sound model="ich9">
      <codec type="micro"/>
      <audio id="1"/>
      <address type="pci" domain="0x0000" bus="0x00" slot="0x1b" function="0x0"/>
    </sound>
    <audio id="1" type="pulseaudio" serverName="/run/user/1000/pulse/native">
      <input mixingEngine="no"/>
      <output mixingEngine="no"/>
    </audio>

### You must also remove everything that uses SpiceVMC whic are the USB redirectors ( #1, #2, etc ), Spice Channel ( com.redhat.spice.0 spice agent )
